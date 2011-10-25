#!/usr/bin/env perl

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
    print 'py2ips: ', @_, "\n";
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




my $pyversion = get_output_line 'python --version 2>&1';
if ($pyversion =~ /Python +(\d)\.(\d)\..+/) {
    $pyversion = "$1$2";
    blab "Python: $pyversion"
} else {
    fatal "Can't parse Python version"
}

foreach my $pkg (@ARGV) {
    # http://pypi.python.org/packages/source/T/TurboKid/TurboKid-1.0.5.tar.gz#md5=ba70daf5aa7121affdea8e7632a3b353
    $pkg = (split /#/, $pkg)[0];

    my $archive = basename $pkg;
    my $url_dir = dirname $pkg;
    blab "Working on $pkg";

    my ($pkg_name, $pkg_version, $arch);
    if ($archive =~ /^(.+)-([^-]+)\.(tar\..+|zip)$/) {
        $pkg_name = $1;
        $pkg_version = $2;
        $arch = $3;
    } else {
        fatal "Can't parse archive name: $archive"
    }

    my $pkg_name_lc = lc $pkg_name;
    blab "Package name: $pkg_name";


    my_mkdir $pkg_name_lc;
    my_chdir $pkg_name_lc;

    my_mkdir '__srcdir__';
    my_chdir '__srcdir__';
    shell_exec qq/wget -O "$archive" "$pkg"/;
    my $sha1sum = get_output_line qq/sha1sum "$archive" | cut -d ' ' -f 1/;

    if ($arch =~ /zip/) {
        shell_exec qq/unzip "$archive"/;
        fatal "Can't find sources (from zip)" unless -d "${pkg_name}-${pkg_version}";
        shell_exec "mv ${pkg_name}-${pkg_version}/* .";
    } else {
        shell_exec qq/tar xf "$archive" --strip-component 1/
    }
    shell_exec qq/python setup.py egg_info/;



    my_chdir '../__srcdir__';
    shell_exec qq!python setup.py install --root=../__destdir__ --prefix=/usr !;

    # FIXME: versions (kid >= 0.9.6)
    my @pkg_deps = ();
    if ( -f "$pkg_name.egg-info/requires.txt") {
        @pkg_deps =
         map { s/^([-\w]+).*/$1/; lc $_ }
         grep { /^\w/ }
         @{get_output "cat $pkg_name.egg-info/requires.txt"}
    }
    blab "Dependencies: ", (join ', ', @pkg_deps);

    my $pkg_summary = '';
    for my $dir ( ("$pkg_name.egg-info", '.') ) {
        if ( -f "$dir/PKG-INFO") {
           $pkg_summary = get_output_line "grep Summary: $dir/PKG-INFO | sed 's/Summary: *//'";
           last;
        }
    }
    my_chdir '..';
    $pkg_summary =~ s/\.+$//;

    my $ips_manifest = <<MANIFEST;
<transform file path=usr.*/man/.+ -> default mangler.man.stability uncommitted>
set name=pkg.fmri value=pkg:/library/python-2/${pkg_name_lc}-$pyversion@\$(IPS_COMPONENT_VERSION),\$(BUILD_VERSION)
set name=info.classification value="org.opensolaris.category.2008:Development/Python"
set name=pkg.summary value="$pkg_summary"
MANIFEST
    $ips_manifest .= "\n";

    $ips_manifest .= "depend fmri=pkg:/runtime/python-$pyversion type=require\n";
    $ips_manifest .= "depend fmri=pkg:/library/python-2/${_}-$pyversion type=require\n"
        foreach @pkg_deps;

    $ips_manifest .= "\n";

    $ips_manifest .= join "\n",
        (map { s![^/]+-packages!vendor-packages!; $_ }
        @{get_output
            "cd __destdir__ && \
            gfind * -type d -printf 'dir path=%p\\n' \
            gfind * -type f -printf 'file path=%p\\n' \
            gfind * -type l -printf 'link path=%p target=%l\\n' \
            "});

    $ips_manifest .= "\n";

    my $makefile = <<MAKEFILE;
include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  $pkg_name
COMPONENT_VERSION  =  $pkg_version
COMPONENT_SRC      =  \$(COMPONENT_NAME)-\$(COMPONENT_VERSION)
COMPONENT_ARCHIVE  =  \$(COMPONENT_SRC).$arch
COMPONENT_ARCHIVE_HASH = sha1:$sha1sum
COMPONENT_ARCHIVE_URL  = $url_dir/\$(COMPONENT_ARCHIVE)

include \$(WS_TOP)/make-rules/prep.mk
include \$(WS_TOP)/make-rules/ips.mk
include \$(WS_TOP)/make-rules/setup.py.mk

build:      \$(BUILD_32)
install:    \$(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       \$(TEST_32)

BUILD_PKG_DEPENDENCIES = \$(BUILD_TOOLS)

include \$(WS_TOP)/make-rules/depend.mk

MAKEFILE

    shell_exec "rm -rf __srcdir__ __destdir__";

    write_file "$pkg_name_lc-$pyversion.p5m", $ips_manifest;
    write_file 'Makefile', $makefile;

    my_chdir '..';
}

exit 0;

