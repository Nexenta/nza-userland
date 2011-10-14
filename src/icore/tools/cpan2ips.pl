#!/usr/bin/env perl

# Based on ideas of cpan2tgz by Jason Woodward <woodwardj@jaos.org>
# http://software.jaos.org/

use strict;
use warnings FATAL => 'all';
use integer;
use Data::Dumper;
use Getopt::Long qw(:config no_ignore_case);
use File::Copy;
use File::Basename;
use Cwd;
use CPAN;

sub blab {
    print 'cpan2ips: ', @_, "\n";
}
sub warning {
    blab 'WARNING: ', @_;
    sleep 2;
}
sub fatal {
    blab 'FATAL: ', @_;
    exit 1;
}
sub my_chdir {
    my ($path) = @_;
    chdir $path or fatal "Can't chdir() to `$path': $!";
}
sub my_mkdir {
    my ($path, $mode) = @_;
    if (defined $mode) {
        mkdir $path, oct($mode)
            or fatal "Can't create dir `$path' with mode `$mode': $!";
    } else {
        mkdir $path
            or fatal "Can't create dir `$path': $!";
    }
}
sub uniq {
    my ($array_ref) = @_;
    my %hash = map { $_, 1 } @$array_ref;
    @$array_ref = keys %hash;
}

sub shell_exec {
    my ($cmd) = @_;
    blab "executing `$cmd'";
    system($cmd);
    if ($? == -1) {
        fatal "failed to execute: $!";
    } elsif ($? & 127) {
        fatal (printf "child died with signal %d, %s coredump",
            ($? & 127),  ($? & 128) ? 'with' : 'without')
    } else {
        my $rc = $? >> 8;
        if ($rc != 0) {
            warning "child exited with value $rc";
        }
    }
}
sub write_file {
    my ($filename, $content) = @_;
    blab "Writing file `$filename'";
    if (open FD, '>', $filename) {
        print FD $content;
        close FD;
    } else {
        fatal "Can't write to file `$filename': $!"
    }
}
sub get_output {
    my ($cmd) = @_;
    blab "absorbing `$cmd'";
    if (open OUT, "$cmd |") {
        my @lines = <OUT>;
        close OUT;
        chomp @lines;
        warning "Empty output from `$cmd'" unless @lines;
        return \@lines;
    } else {
        fatal "Can't execute `$cmd': $!"
    }
}
sub get_output_line {
    return (@{get_output @_})[0];
}

sub trim {
    # works with refs:
    $$_ =~ s/^\s*(.*)\s*$/$1/ foreach @_;
}


my $PERL_MODS_DIR = getcwd;

our $HAS_YAML = 1;
eval "no warnings 'all'; use YAML;"; if ($@) { $HAS_YAML = 0 }

my %MODS_CACHE = ();
if ( opendir(my $perl_modules, $PERL_MODS_DIR) ) {
    $MODS_CACHE{$_} = 1 foreach grep  { ! m/^\.+$/ } readdir($perl_modules);
    closedir($perl_modules);
} else {
    fatal "Can't read directory `$PERL_MODS_DIR': $!";
}

my @modules = @ARGV;
foreach my $mod ( @modules ) {
    if (exists $MODS_CACHE{$mod}) {
        blab "$mod already incorporated";
    } else {
        do_package($mod);
    }
}

sub do_package
{
    my ($module_name) = @_;
    return unless $module_name;

    my $module =  CPAN::Shell->expand('Module', $module_name)
                || CPAN::Shell->expand('Bundle', $module_name)
                || CPAN::Shell->expand('Distribution', $module_name);
    fatal "Failed to find module: $module_name\n" unless $module;

    blab "Processing `$module_name'";

    my $pack;
    if ($module->can('distribution')) {
        $pack = $module->distribution;
    } else {
        $pack = $CPAN::META->instance('CPAN::Distribution', $module->cpan_file());
    }
    fatal "Failed to initialize CPAN::Distribution object for $module_name: $!" unless $pack;

    $pack->get();
    
    my $cpan_file   = $module->cpan_file();
    my $cpan_dir    = 'http://search.cpan.org/CPAN/authors/id/' . (dirname $cpan_file);
    my $mod_id      = $module->id();
    my $cpan_file_basename  = basename $cpan_file;
    $cpan_file_basename =~ /^(.+)-([^-]+)\.tar\.(.+)$/ ||  fatal "Can't parse $cpan_file_basename";
    my ($cpan_name, $pkg_version, $tar_comp) = ($1, $2, $3);
    my $pkg_name = lc $cpan_name;

    blab "CPAN file: $cpan_file";
    blab "Package name: $pkg_name";
    blab "Package version: $pkg_version";

    if (exists $MODS_CACHE{$mod_id} || exists $MODS_CACHE{$pkg_name}) {
        blab "Module `$mod_id' already in queue or incorporated";
        return $pkg_name;
    } else {
        $MODS_CACHE{$mod_id}   = 1;
        $MODS_CACHE{$pkg_name} = 1;
    }

    if ($pack->isa_perl()) {
        blab "Skipping `$mod_id': it is a Perl core module";
        return;
    }
    eval { $pack->make() or die $!; };
    if ($@) {
        if (!($!{ENOTTY} && $HAS_YAML)) {
            fatal "make ERROR [$module_name]: $!\n";
        }
    }

    my @mod_deps = ();
    if (my $deps = $pack->prereq_pm()) {
        @mod_deps = grep { $_ && m/\w+/; }
        map { defined $MODS_CACHE{$_} ? undef : $_ }
        map { eval "no warnings 'all'; use $_;"; if ($@) { $_ } }
        map { m/requires$/ ? keys %{$deps->{$_}} : $_ }
        keys %{$deps};
    }
    blab "Required for `$mod_id' modules: ", (join ', ', @mod_deps);

    my @pkg_deps = ();
    foreach (@mod_deps) {
        my $dep_pkg_name = do_package($_);
        push @pkg_deps, $dep_pkg_name if $dep_pkg_name;
    }
    uniq \@pkg_deps;
    blab "Required for `$pkg_name' packages: ", (join ', ', @pkg_deps);


    my $tmp_dest_dir = "/tmp/cpan2ips-$pkg_name";
    my $pack_dir = $pack->dir();
    if ( -f "$pack_dir/Build" ) {
        shell_exec "cd $pack_dir && ./Build install_vendor destdir=$tmp_dest_dir";
    } else {
        shell_exec "cd $pack_dir && make install_vendor DESTDIR=$tmp_dest_dir";
    }
    fatal "Build failed" unless -d $tmp_dest_dir;


    my $pkg_summary = get_output_line "cd $pack_dir && [ -f META.yml ] && grep abstract: META.yml | sed 's,abstract: *,,'";
    my $ips_manifest = <<MANIFEST;
<transform file path=usr.*/man/.+ -> default mangler.man.stability uncommitted>
set name=pkg.fmri value=pkg:/library/perl-5/$pkg_name@\$(IPS_COMPONENT_VERSION),\$(BUILD_VERSION)
set name=info.classification value="org.opensolaris.category.2008:Development/Perl"
set name=pkg.summary value="$pkg_summary (Perl module)"
MANIFEST

    $ips_manifest .= join "\n", (grep !/(\.packlist|perllocal.pod)$/,
        @{get_output
            "cd $tmp_dest_dir && \
            gfind * -type d -printf 'dir path=%p\\n' \
            gfind * -type f -printf 'file path=%p\\n' \
            gfind * -type l -printf 'link path=%p target=%l\\n' \
            "});

    $ips_manifest .= "\n";
    $ips_manifest .= "depend fmri=pkg:/library/perl-5/$_ type=require\n"
        foreach @pkg_deps;

    shell_exec "rm -rf $tmp_dest_dir";

    my $sha1sum = get_output_line "sha1sum $CPAN::Config->{'keep_source_where'}/authors/id/$cpan_file | cut -d ' ' -f 1";
    my $makefile = <<MAKEFILE;
include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  $cpan_name
COMPONENT_VERSION  =  $pkg_version
COMPONENT_SRC      =  \$(COMPONENT_NAME)-\$(COMPONENT_VERSION)
COMPONENT_ARCHIVE  =  \$(COMPONENT_SRC).tar.$tar_comp
COMPONENT_ARCHIVE_HASH = sha1:$sha1sum
COMPONENT_ARCHIVE_URL  = $cpan_dir/\$(COMPONENT_ARCHIVE)

include \$(WS_TOP)/make-rules/prep.mk
include \$(WS_TOP)/make-rules/ips.mk
include \$(WS_TOP)/make-rules/makemaker.mk

build:      \$(BUILD_32)
install:    \$(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       \$(TEST_32)

BUILD_PKG_DEPENDENCIES = \$(BUILD_TOOLS)

include \$(WS_TOP)/make-rules/depend.mk

MAKEFILE

    my_mkdir "$PERL_MODS_DIR/$pkg_name";
    write_file "$PERL_MODS_DIR/$pkg_name/$pkg_name.p5m", $ips_manifest;
    write_file "$PERL_MODS_DIR/$pkg_name/Makefile", $makefile;

    return $pkg_name;
}

exit 0;

