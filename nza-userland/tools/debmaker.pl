#!/usr/bin/env perl

#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license
# at http://www.opensource.org/licenses/CDDL-1.0
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each file.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright (C) 2012, Nexenta Systems, Inc. All rights reserved.
#

use 5.010;
use strict;
use warnings FATAL => 'all';
use integer;
use Cwd;
use File::Basename;
use File::Copy;
use File::Path 'mkpath';
use Data::Dumper;
use Getopt::Long qw(:config no_ignore_case);
use POSIX qw(strftime);
use Text::Wrap;

sub blab {
    print 'debmaker: ', @_, "\n";
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
sub my_symlink {
    my ($src, $dst) = @_;
    my_mkdir(dirname $dst);
    symlink $src, $dst
        or fatal "Can't create symlink `$src' -> `$dst': $!"
}
sub my_hardlink {
    my ($src, $dst) = @_;

    # even if we can't create hardlink in package, we should have a directory
    # to be able to create hardlink in preinstall phase:
    my_mkdir(dirname $dst);

    # For hardlink creation target file must be accessible:
    my $pwd = getcwd;
    my $dir = dirname $dst;
    my_chdir $dir;
    my $success = link $src, $dst;
    my_chdir $pwd;
    # be more tolerant, cause it may be hardlink to isaexec
    warning "Can't create hardlink `$src' -> `$dst': $!" unless $success;
    return $success;
}
sub my_copy {
    my ($src, $dst) = @_;
    my_mkdir(dirname $dst);
    copy $src, $dst
        or fatal "Can't copy `$src' to `$dst': $!";
}
sub my_chown {
    my ($u, $g, $path) = @_;
    my $uid = getpwnam $u;
    my $gid = getgrnam $g;
    chown $uid, $gid, $path
         or fatal "Can't chown ($u.$g) `$path': $!";
}
sub my_chmod {
    my ($mode, $path) = @_;
    chmod oct($mode), $path
        or fatal "Can't chmod ($mode) `$path': $!";
}
sub my_mkdir {
    my ($path, $mode) = @_;
    my $err;
    if (defined $mode) {
        mkpath($path, {mode => oct($mode), error => \$err})
    } else {
        mkpath($path, {error => \$err})
    }
    if (@$err) {
        foreach my $diag (@$err) {
            my ($dir, $message) = %$diag;
            if ($dir) {
                warning "Failed to create dir `$dir': $message"
            } else {
                warning "$message"
            }
        }
        fatal "Failed to create directory `$path'"
    }
}

sub uniq {
    foreach (@_) {
        my %hash = map { $_, 1 } @$_;
        @$_ = keys %hash;
    }
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

sub as_array {
    my ($ref) = @_;
    return (ref $ref) ? @{$ref} : ($ref);
}

sub my_join ($$) {
    my ($glue, $ref) = @_;
    return join ($glue, as_array $ref);
}

sub get_command_line {
    my ($map_ref, $hash_ref) = @_;
    my $res = '';
    foreach my $k (keys %$map_ref) {
        if (exists $$hash_ref{$k}) {
            foreach (as_array $$hash_ref{$k}) {
                $res .= " $$map_ref{$k} '$_'";
            }
        }
    }
    return $res;
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
sub write_script {
    my ($filename, $content) = @_;
    $content = "#!/sbin/sh\nset -e\n$content";
    write_file $filename, $content;
    my_chmod '0555', $filename;
}

sub get_output {
    my ($cmd) = @_;
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


# Expected input for @PROTO_DIRS:
# -d /root/oi-build/components/elinks/build/prototype/i386/mangled
# -d /root/oi-build/components/elinks/build/prototype/i386
# -d .
# -d /root/oi-build/components/elinks
# -d elinks-0.11.7
# (like debian/tmp)
my @PROTO_DIRS = ();


# -D MACH32=i86 -D COMPONENT_VERSION=1.2.3 etc =>
# $DEFINES{'MACH32'}='i86', $DEFINES{'COMPONENT_VERSION'}='1.2.3' etc
my %DEFINES = ();


# Where to create debs prototypes
# (like debian/pkg-name)
my $OUTDIR = '';

# If true, will use manifests from command line
# to resolve dependencies:
my $BOOTSTRAP = 0;

my $MAINTAINER = 'Nexenta Systems <maintainer@nexenta.com>';
my $VERSION = '0.0.0';
my $ARCH = 'solaris-i386';
my $SOURCE = 'xxx'; # only for *.changes
my $DISTRIB = 'nza-userland';

# Mapping file => IPS FMRI, filled on bootstrap:
my %PATHS = ();

GetOptions (
    'd=s' => \@PROTO_DIRS,
    'O=s' => \$OUTDIR,
    'V=s' => \$VERSION,
    'A=s' => \$ARCH,
    'M=s' => \$MAINTAINER,
    'S=s' => \$SOURCE,
    'N=s' => \$DISTRIB,
    'bootstrap!' => \$BOOTSTRAP,
    'D=s' => \%DEFINES,
    'help|h' => sub {usage()},
) or usage();

# underscore is not allowed in dpkg names,
# but some sources have it (e. g. Tree-DAG_Node):
$SOURCE =~ s/_/-/g;


sub usage {
    print <<USAGE;
Usage: $0 [options] -O <output dir> -d <proto dir> [-d <proto dir> ... ] manifests

Options:

    -d <proto dir>     where to find files (like debian/tmp)

    -O <output dir>    where to create package structure and debs,
                       <output dir>/pkg-name and
                       <output dir>/pkg-name*.deb will be created
    -D var=value       define a variable to substitute in manifest,
                       e. g. -D MACH32=i86 -D COMPONENT_VERSION=1.2.3

    -V <version>       version of created packages (default is `$VERSION'),
                       may be 'ips' to use the same as for IPS system.

    -A <architecture>  package architecture, default is `$ARCH'

    -S <source name>   package source name to make reprepro happy
                       with *.changes files, default is `$SOURCE'

    -N <dist name>     distribution  name to make reprepro happy
                       with *.changes files, default is `$DISTRIB'

    -M <maintainer>    Package maintainer - mandatory for debs,
                       default is `$MAINTAINER'
   
    --bootstrap        Search for dependencies within listed manifests,
                       not within installed system (for bootstraping)
                       ** not implemented yet **

    -h, --help         Show help info

USAGE
    exit 1;
}

sub parse_keys {
    my ($line) = @_;
    # parse:
    # name=pkg.summary value="advanced text-mode WWW browser"
    # into:
    # 'name' => pkg.summary
    # 'value' => "advanced text-mode WWW browser"
    # http://stackoverflow.com/questions/168171/regular-expression-for-parsing-name-value-pairs
    my %pairs = ();
    while ($line =~ s/((?:\\.|[^= ]+)*)=("(?:\\.|[^"\\]+)*"|(?:\\.|[^ "\\]+)*)//) {
        my ($k, $v) = ($1, $2);
        $v =~ s/^"(.+)"$/$1/;
        $v =~ s/^'(.+)'$/$1/;

        if (not exists $pairs{$k}) {
            # most keys are unique, keep its values as scalars
            $pairs{$k} = $v;
        } else {
            # upgrade to array ref if it was a scalar:
            $pairs{$k} = [$pairs{$k}] unless ref $pairs{$k};
            push @{$pairs{$k}}, $v;
        }
    }
    return \%pairs;
}

sub read_manifest {
    my ($filename) = @_;
    my %data = ();
    $data{'dir'} = [];
    $data{'file'} = [];
    $data{'link'} = [];
    $data{'hardlink'} = [];
    $data{'depend'} = [];
    $data{'legacy'} = [];
    $data{'group'} = [];
    $data{'user'} = [];
    $data{'license'} = [];
    $data{'driver'} = [];

    if (open IN, '<', $filename) {
        while (<IN>) {
            study; chomp;
            if (/^set +/) {
                my $pairs = parse_keys $_;
                $data{$$pairs{'name'}} = $$pairs{'value'};
            } elsif (/^file +(\S+) +/) {
                my $maybe_src = $1;
                my $pairs = parse_keys $_;
                $$pairs{'src'} = $maybe_src if $maybe_src ne 'NOHASH';
                push @{$data{'file'}}, $pairs;
            } elsif (/^license +(\S+) +/) {
                my $maybe_src = $1;
                my $pairs = parse_keys $_;
                $$pairs{'src'} = $maybe_src if $maybe_src !~ /=/;
                push @{$data{'license'}}, $pairs;
            } elsif (/^(user|group|legacy|depend|hardlink|link|dir|driver) +/) {
                my $action = $1;
                my $pairs = parse_keys $_;
                push @{$data{$action}}, $pairs;
            } elsif (/^\s*$/) {
                # Skip empty lines
            } elsif (/^\s*#/) {
                # Skip comments
            } else {
                warning "Unknown action: `$_'";
            }
        }
        close IN;
        return \%data;
    } else {
        fatal "Can't open `$filename': $!";
    }
}

sub get_debpkg_names {
#    pkg:/web/browser/elinks@0.11.7,5.11-1.1
# => web-browser-elinks
#        browser-elinks
#                elinks
#   Also works for "original_name"=pkg:/web/browser/elinks:usr/bin/Elinks
    my ($fmri) = @_;
    my @names = ();
    if ($fmri =~ m,^(?:pkg:/)?([^:@]+)(?:[:@].+)?$,) {
        my $pkg = $1;
        my @parts = split /\//, $pkg;
        while (@parts) {
            push @names, (join '-', @parts);
            shift @parts;
        }
        return @names;
    } else {
        fatal "Can't parse FMRI to get dpkg name: `$fmri'";
    }
}
sub get_debpkg_name {
    return (get_debpkg_names @_)[0]
}

sub get_ips_version {
#    pkg:/web/browser/elinks@0.11.7,5.11-1.1
# => 0.11.5-5.11-1.1
    my ($fmri) = @_;
    if ($fmri =~ m,^(?:pkg:/)?[^@]+@(.+)$,) {
        my $ips = $1;
        $ips =~ s/[,:]/-/g;
        return $ips;
    } else {
        fatal "Can't parse FMRI to get IPS version: `$fmri'";
    }
}

sub get_pkg_section {
    my ($pkgname) = @_;
    if ($pkgname =~ m,^([^-@]+)-.*,) {
        return (split /-/, $pkgname)[0];
    } elsif ($pkgname =~ m,^pkg:/([^/]+)/.*,) {
        return $1;
    } else {
        fatal "Can't get section for package `$pkgname'"
    }
}

sub get_dir_size {
    my ($path) = @_;
    # We get size just after files are copied
    # and need sync() to get proper sizes:
    return get_output_line "sync && du -sk $path | cut -f 1";
}

sub find_pkgs_with_paths {
    my @paths = @_;
    s,^/+,,g foreach @paths;
    my $dpkg = get_output "dpkg-query --search -- @paths | cut -d: -f1";
    return $dpkg;
}

#FIXME : If we have 64-bit library, we have 32-bit as well, so check only 32-bit:
my @librarypaths = qw(/lib /usr/lib /usr/gnu/lib);
sub guess_required_deps {
    my ($path) = @_;
    my $elfs = get_output "gfind $path -type f -exec file {} \\; | ggrep ELF | cut -d: -f1";
    my @deps = ();
    my @libraries = ();
    if (@$elfs) {
        my $libs = get_output "elfdump -d @$elfs | ggrep -E '(NEEDED|SUNW_FILTER)' | awk '{print \$4}' | sort -u";
        my $rpath = get_output "elfdump -d @$elfs | grep RPATH | awk '{print \$4}' | gsed  's,:,\\n,g' | sort -u | grep -v usr/sfw/lib";
        blab "rpath: @$rpath";
        push @librarypaths, @$rpath;
        uniq \@librarypaths;
        blab 'Required libs: ' . join(', ', @$libs);
        blab 'Library search paths: ' . join(', ', @librarypaths);
        foreach my $l (@$libs) {
            my $found = '';
            foreach my $p (@librarypaths) {
                if (-e "$p/$l") {
                    $found = "$p/$l";
                    last;
                }
            }
            if ($found) {
                blab "found $found";
                push @libraries, $found;
            } else {
                # FIXME : What is library is in package being built?
                warning "Could not find library $l";
            }
        }
        my $pkgs = find_pkgs_with_paths @libraries;
        push @deps, @$pkgs;
    }
    return \@deps;
}

sub get_shlib {
    my ($dir, $pkg) = @_;
    my $res = '';
    $pkg = basename $dir unless $pkg;

    my $libs = get_output "gfind $dir -type f -name '*.so.*'";
    if (@$libs) {
        my $sonames = get_output "elfdump -d @$libs | ggrep SONAME | awk '{print \$4}' | sort -u";
        $res = join "\n", map { /^(.+)\.so\.(.+)$/; "$1 $2 $pkg" } @$sonames;
    }
    return $res;
}

if (!$OUTDIR) {
    fatal "Output dir is not set. Use -D option."
}
if (! -d $OUTDIR) {
    fatal "Not a directory: `$OUTDIR'"
}

# Walk through all manifests
# and collect files, symlinks, hardlink
# mapping them to package names:
if ($BOOTSTRAP) {
    blab "Bootstrap: collecting paths ...";
    foreach my $manifest_file (@ARGV) {
        my $manifest_data = read_manifest $manifest_file;
        my $fmri = $$manifest_data{'pkg.fmri'};
        my @items = ();
        if (my @files = @{$$manifest_data{'file'}}) {
            push @items, @files;
        }
        if (my @symlinks = @{$$manifest_data{'link'}}) {
            push @items, @symlinks;
        }
        if (my @hardlinks = @{$$manifest_data{'hardlink'}}) {
            push @items, @hardlinks;
        }
        foreach my $item (@items) {
            my $path = $$item{'path'};
            if (exists $PATHS{$path}) {
                warning "`$path' already present in `$PATHS{$path}' and now found in `$fmri' (manifest `$manifest_file')"
            } else {
                $PATHS{$path} = $fmri;
            }
        }
    }
    blab 'Bootstrap: ' . (keys %PATHS) . ' known paths'
}


my %changes = ();
$changes{'Date'} = strftime '%a, %d %b %Y %T %z', localtime; # Sat, 11 Jun 2011 17:08:17 +0200
$changes{'Architecture'} = $ARCH;
$changes{'Format'} = '1.8';
$changes{'Maintainer'} = $MAINTAINER;
$changes{'Source'} = lc $SOURCE;
$changes{'Version'} = $VERSION;
$changes{'Distribution'} = $DISTRIB;

#TODO: last Hg commit?:
$changes{'Changes'} = 'Everything has changed';

$changes{'Description'} = '';
$changes{'Checksums-Sha1'} = '';
$changes{'Checksums-Sha256'} = '';
$changes{'Files'} = '';
$changes{'Binary'} = '';


foreach my $manifest_file (@ARGV) {
    blab "****** Manifest: `$manifest_file'";
    my $manifest_data = read_manifest $manifest_file;
    my @provides = get_debpkg_names $$manifest_data{'pkg.fmri'};
    my $debname = shift @provides; # main name (web-browser-elinks)
    my $debsection = get_pkg_section $debname;
    my $debpriority = $$manifest_data{'pkg.priority'} // 'optional';
    my @replaces = ();
    my @zones = ();
    @zones = as_array $$manifest_data{'variant.opensolaris.zone'}
        if exists $$manifest_data{'variant.opensolaris.zone'};

    foreach my $l (@{$$manifest_data{'legacy'}}) {
        push @provides, get_debpkg_name $$l{'pkg'};
    }
    my $pkgdir = "$OUTDIR/$debname";
    blab "Main package name: $debname";

    my $ipsversion = get_ips_version $$manifest_data{'pkg.fmri'};
    my $debversion = undef;
    if ($VERSION eq 'ips') {
        blab "Using IPS version scheme: $ipsversion";
        $debversion = $ipsversion;
    } else {
        blab "Using given version: $VERSION";
        $debversion = $VERSION;
    }

    my $basedir_prolog = 
         'if [ -z "$BASEDIR" ]; then' . "\n"
       . "  BASEDIR=/\n"
       . "else\n"
       . '  BASEDIR=`cd $BASEDIR && pwd`' . "\n"
       . "fi\n\n"
       . 'if [ $BASEDIR != / ]; then' . "\n"
       . '  CHROOT="chroot $BASEDIR"' . "\n"
       . '  _drv_basedir="-b $BASEDIR"' . "\n"
       . "else\n"
       . "  CHROOT=\n"
       . "  _drv_basedir=\n"
       . "fi\n\n"
       ;
    my $preinst  = $basedir_prolog;
    my $postinst = $basedir_prolog;
    my $prerm    = $basedir_prolog;
    my $postrm   = $basedir_prolog;

    my $postinst_configure = '';
    my $prerm_remove = '';

    my @groups = @{$$manifest_data{'group'}};
    my @users  = @{$$manifest_data{'user'}};

    if (@groups) {
        foreach my $g (@groups) {
            my $cmd = 'if ! $CHROOT getent group ' . $$g{'groupname'} . ' >/dev/null; then' . "\n";
            $cmd .= qq| echo 'Adding group "$$g{'groupname'}"'\n|;
            $cmd .= ' $CHROOT groupadd ';
            $cmd .= get_command_line {
                'gid' => '-g'
                }, $g;
            $cmd .= " $$g{'groupname'} || true\n";
            $cmd .= "fi\n";
            $postinst_configure .= $cmd;
        }
    }
    if (@users) {
        foreach my $u (@users) {
            my $cmd = 'if ! $CHROOT getent passwd ' . $$u{'username'} . ' >/dev/null; then' . "\n";
            $cmd .= qq| echo 'Adding user "$$u{'username'}"'\n|;
            $cmd .= ' $CHROOT useradd ';
            # map action attributes to options for 'useradd':
            $cmd .= get_command_line {
                'uid' => '-u',
                'group' => '-g',
                'gcos-field' => '-c',
                'home-dir' => '-d',
                'uid' => '-u',
                'login-shell' => '-s',
                'group-list' => '-G',
                'inactive' => '-f',
                'expire' => '-e',
                }, $u;
            $cmd .= " $$u{'username'} || true\n";
            $cmd .= "fi\n";
            $postinst_configure .= $cmd;
        }
    }

    my_mkdir $pkgdir;

# pkg(5):
#     disable_fmri
#     refresh_fmri
#     restart_fmri
#     suspend_fmri  Each of these actuators take the value of an FMRI of
#         a service instance to operate upon during the package
#         installation or removal.  disable_fmri causes the
#         mentioned FMRI to be disabled prior to action removal, per
#         the disable subcommand to svcadm(1M).  refresh_fmri and
#         restart_fmri cause the given FMRI to be refreshed or
#         restarted after action installation or update, per the
#         respective subcommands of svcadm(1M).  Finally,
#         suspend_fmri causes the given FMRI to be disabled
#         temporarily prior to the action install phase, and then
#         enabled after the completion of that phase.
    my @disable_fmri = ();
    my @refresh_fmri = ();
    my @restart_fmri = ();
    my @suspend_fmri = ();

    if (my @dirs = @{$$manifest_data{'dir'}}) {
        blab "Making dirs ...";
        foreach my $dir (@dirs) {
            my $dir_name = "$pkgdir/$$dir{'path'}";
            my_mkdir $dir_name, $$dir{'mode'};
            if (grep($$dir{'owner'} eq $$_{'username'}, @users) ||
                grep($$dir{'group'} eq $$_{'groupname'}, @groups))
            {
                my $cmd = "chown $$dir{'owner'}:$$dir{'group'} '/$$dir{'path'}'";
                warning "will chown in postinstall: $cmd";
                $postinst_configure .= $cmd . " || true\n";
            } else {
                my_chown $$dir{'owner'}, $$dir{'group'}, $dir_name;
            }
            push @replaces, get_debpkg_name $$dir{original_name} if exists $$dir{original_name};

            push @disable_fmri, as_array $$dir{disable_fmri} if exists $$dir{disable_fmri};
            push @refresh_fmri, as_array $$dir{refresh_fmri} if exists $$dir{refresh_fmri};
            push @restart_fmri, as_array $$dir{restart_fmri} if exists $$dir{restart_fmri};
            push @suspend_fmri, as_array $$dir{suspend_fmri} if exists $$dir{suspend_fmri};
        }
    }

    my @conffiles = ();
    if (my @files = @{$$manifest_data{'file'}}) {
        blab "Copying files ...";
        foreach my $file (@files) {
            my $dst = "$pkgdir/$$file{'path'}";
            my $src =  $$file{'src'} // $$file{'path'};
            # find $src in @PROTO_DIRS:
            my $src_dir = undef;
            foreach my $d (@PROTO_DIRS) {
                # http://stackoverflow.com/questions/2238576/what-is-the-default-scope-of-foreach-loop-in-perl
                if ( -f "$d/$src") {
                    $src_dir = $d;
                    last
                }
            }
            fatal "file `$src' not found in given dirs: ", join(', ', @PROTO_DIRS)
                unless $src_dir;

            $src = "$src_dir/$src";
            my_copy $src, $dst;
            my_chmod $$file{'mode'}, $dst;
            if (grep($$file{'owner'} eq $$_{'username'}, @users) ||
                grep($$file{'group'} eq $$_{'groupname'}, @groups))
            {
                my $cmd = "chown $$file{'owner'}:$$file{'group'} '/$$file{'path'}'";
                warning "will chown in postinstall: $cmd";
                $postinst_configure .= $cmd . " || true\n";
            } else {
                my_chown $$file{'owner'}, $$file{'group'}, $dst;
            }

            if ((exists $$file{'preserve'}) and ($$file{'preserve'} ne 'false')) {
                push @conffiles, $$file{'path'}
            }
            push @replaces, get_debpkg_name $$file{original_name} if exists $$file{original_name};

            push @disable_fmri, as_array $$file{disable_fmri} if exists $$file{disable_fmri};
            push @refresh_fmri, as_array $$file{refresh_fmri} if exists $$file{refresh_fmri};
            push @restart_fmri, as_array $$file{restart_fmri} if exists $$file{restart_fmri};
            push @suspend_fmri, as_array $$file{suspend_fmri} if exists $$file{suspend_fmri};
        }
    }

    if (my @hardlinks = @{$$manifest_data{'hardlink'}}) {
        blab "Creating hardlinks ...";
        my @hl_script = ();
        foreach my $link (@hardlinks) {
            if (!my_hardlink $$link{'target'}, "$pkgdir/$$link{'path'}") {
                warning "Adding code to create hardlink at post-install phase";
                push @hl_script, $link;
            }
        }
        if (@hl_script) {
            $postinst .= 'if [ "$1" = configure ]; then' . "\n";
            $postrm  .= 'if [ "$1" = remove ]; then' . "\n";
            foreach my $l (@hl_script) {
                my $d = dirname $$l{path};   $d = "/$d" unless $d =~ /^\//;
                my $b = basename $$l{path};
                my $p = $$l{'path'};         $p = "/$p" unless $p =~ /^\//;
                my $t = $$l{'target'};
                $postinst .= " if ! [ -f \${BASEDIR}$p ]; then\n";
                $postinst .= "  cd \${BASEDIR}$d && ln $t $b || true\n";
                $postinst .= " fi\n";
                $postrm  .= " rm $p || true\n";
            }
            $postinst .= "fi\n";
            $postrm  .= "fi\n";
        }
    }
    if (my @symlinks = @{$$manifest_data{'link'}}) {
        blab "Creating symlinks ...";
        foreach my $link (@symlinks) {
            if (exists $$link{'mediator'}) {
                blab "$$link{'path'} has a mediator, update-aternatives will be used";
                my $l = $$link{'path'}; $l = "/$l" unless $l =~ /^\//;
                my $n = basename $l;
                # FIXME : should be absolute: 
                my $p = $$link{'target'}; $p = "/$p" unless $p =~ /^\//;
                # FIXME : mediator-{version,implementation,priority}
                # cannot be mapped to update-alternatives
                $postinst_configure .=
                    '$CHROOT update-alternatives --install ' . "$l $n $p 10 || true\n"; # FIXME : random priority ;-)
                # FIXME : too many FIXMEs
                $prerm .= 'if [ "$1" = remove ]; then $CHROOT update-alternatives --remove ' . "$n $p || true; fi\n";
            } else {
                my_symlink $$link{'target'}, "$pkgdir/$$link{'path'}";
            }
        }
    }

    # http://src.opensolaris.org/source/xref/pkg/gate/src/modules/actions/driver.py
    if (my @drivers = @{$$manifest_data{'driver'}}) {
        blab "Adding code to register drivers ...";
        $postinst_configure .= 'if [ -z "$2" ]; then' . "\n";
        foreach my $d (@drivers) {
            my $cmd = 'add_drv -v $_drv_basedir';
            $cmd .= "-i '" . my_join(' ', $$d{'alias'}) . "'" if exists $$d{'alias'};
            $cmd .= "-c '" . my_join(' ', $$d{'class'}) . "'" if exists $$d{'class'};
            $cmd .= "-m '" . my_join(',', $$d{'perms'}) . "'" if exists $$d{'perms'};
            $cmd .= "-P '" . my_join(',', $$d{'privs'}) . "'" if exists $$d{'privs'};
            $cmd .= "-p '" . my_join(' ', $$d{'policy'}) . "'" if exists $$d{'policy'};
            $cmd .= " $$d{name}";
            blab $cmd;
            $postinst_configure .= $cmd . " || true\n";
            $postinst_configure .= "update_drv \$_drv_basedir -v -a -m '$$d{'clone_perms'}' clone || true\n"
                if  exists $$d{'clone_perms'};

            $prerm_remove .= "rem_drv $$d{name} || true\n";

            if (exists $$d{'devlink'}) {
                foreach my $devlink (as_array($$d{'devlink'})) {
                    $devlink =~ s/\\t/\t/g;
                    $postinst_configure .= "if ! grep -q '$devlink' \$BASEDIR/etc/devlink.tab; then\n";
                    $postinst_configure .= "  echo '$devlink' >> \$BASEDIR/etc/devlink.tab\n";
                    $postinst_configure .= "fi\n";
                    $prerm_remove .= "sed -i.dpkg-old '/$devlink/d' \$BASEDIR/etc/devlink.tab || true\n";
                }
            };
        }
        $postinst_configure .= 'fi # new install' . "\n";
    }


    if (my @license = @{$$manifest_data{'license'}}) {
        # FIXME: install in usr/share/doc/<pkg>/copyright
        # what are the owner, permissions?
        # multiple licenses?
    }
    my $installed_size = get_dir_size $pkgdir;

    my @depends = ();
    my @predepends = ();
    my @recommends = ();
    my @suggests = ();
    my @conflicts = ();
    blab "Getting dependencies ...";
    foreach my $dep (@{$$manifest_data{'depend'}}) {
        if ($$dep{'fmri'} ne '__TBD') {
            my $dep_pkg = get_debpkg_name $$dep{'fmri'};
            blab "Dependency: $dep_pkg ($$dep{'type'})";
            push @depends,    $dep_pkg if $$dep{'type'} eq 'require';
            push @predepends, $dep_pkg if $$dep{'type'} eq 'origin';
            push @suggests,   $dep_pkg if $$dep{'type'} eq 'optional';
            push @conflicts,  $dep_pkg if $$dep{'type'} eq 'exclude';
        }
    }
    push @depends, @{guess_required_deps($pkgdir)};

    uniq \@depends, \@replaces, \@provides, \@predepends, \@recommends, \@suggests, \@conflicts;
    uniq \@restart_fmri, \@refresh_fmri, \@suspend_fmri, \@disable_fmri;
    # When a program and a library are in the same package:
    @depends = grep {($_ ne $debname) && !($_ ~~ @provides)} @depends;


    my $control = '';
    $control .= "Package: $debname\n";
    $control .= "Source: $changes{Source}\n";
    $control .= "Version: $debversion\n";
    $control .= "Section: $debsection\n";
    $control .= "Priority: $debpriority\n";
    $control .= "Maintainer: $MAINTAINER\n";
    $control .= "Architecture: $ARCH\n";
    $control .= "Category: $DISTRIB\n";
    # Specify zone only is @zones has one zone: global or nonglobal:
    $control .= "Zone: $zones[0]\n" if scalar(@zones) == 1;


    $control .= "Description: $$manifest_data{'pkg.summary'}\n";
    $changes{'Description'} .= "\n $debname - $$manifest_data{'pkg.summary'}";

    $control .= wrap(' ', ' ', $$manifest_data{'pkg.description'}) . "\n"
        if exists $$manifest_data{'pkg.description'};

    $control .= 'Provides: '    . join(', ', @provides)   . "\n" if @provides;
    $control .= 'Depends: '     . join(', ', @depends)    . "\n" if @depends;
    $control .= 'Pre-Depends: ' . join(', ', @predepends) . "\n" if @predepends;
    $control .= 'Recommends: '  . join(', ', @recommends) . "\n" if @recommends;
    $control .= 'Suggests: '    . join(', ', @suggests)   . "\n" if @suggests;
    $control .= 'Conflicts: '   . join(', ', @conflicts)  . "\n" if @conflicts;
    $control .= 'Replaces: '    . join(', ', @replaces)   . "\n" if @replaces;

    $control .= "Installed-Size: $installed_size\n";

    $control .= "Origin: $$manifest_data{'info.upstream_url'}\n"
        if exists $$manifest_data{'info.upstream_url'};
    $control .= "X-FMRI: $$manifest_data{'pkg.fmri'}\n";
    $control .= "X-Upstream-Version: $DEFINES{'COMPONENT_VERSION'}\n";

    if (exists $$manifest_data{'info.source_url'}
        && $$manifest_data{'info.source_url'} !~ /^file:/
    ) {
        $control .= "X-Source-URL: $$manifest_data{'info.source_url'}\n"
    }

    my_mkdir "$pkgdir/DEBIAN";

    my $check_smf = <<'CHECK_SMF';
HAVE_SMF=no
if [ $BASEDIR = / ]; then
    SMF_INCLUDE=/lib/svc/share/smf_include.sh
    if [ -f $SMF_INCLUDE ]; then
        source $SMF_INCLUDE
        if smf_present; then
            HAVE_SMF=yes
        fi
    fi
fi
CHECK_SMF

    if (@suspend_fmri) {
        $preinst .= $check_smf;
        $preinst .= 'if [ "$HAVE_SMF" = yes ]; then' . "\n";
        $preinst .= ' if [ "$1" = install ] || [ "$1" = upgrade ]; then' . "\n";
        $preinst .= "  svcadm -v disable -t @suspend_fmri || true\n";
        $preinst .= " fi\n";
        $preinst .= "fi\n";

        $postinst_configure .= "  svcadm -v enable @suspend_fmri || true\n";
    }

    if (@disable_fmri) {
        $prerm .= 'if [ "$1" = "remove" ]; then' . "\n";
        $prerm .= " svcadm disable @disable_fmri || true\n";
        $prerm .= "fi\n";
    }
    if (@refresh_fmri || @restart_fmri) {
        $postinst_configure .= $check_smf;
        $postinst_configure .= 'if [ "$HAVE_SMF" = yes ]; then' . "\n";
        $postinst_configure .= "  svcadm -v refresh @refresh_fmri || true\n" if @refresh_fmri;
        $postinst_configure .= "  svcadm -v restart @restart_fmri || true\n" if @restart_fmri;
        $postinst_configure .= "fi\n";

        # on upgrade services will be touched in postinst,
        # so, catch only removing:
        $postrm .= 'if [ "$1" = remove ]; then' . "\n";
        $postrm .= "  svcadm -v refresh @refresh_fmri || true\n" if @refresh_fmri;
        $postrm .= "  svcadm -v restart @restart_fmri || true\n" if @restart_fmri;
        $postrm .= "fi\n";
    }


    if ($postinst_configure) {
        $postinst .= 'if [ "$1" = configure ]; then' . "\n\n";
        $postinst .= $postinst_configure;
        $postinst .= "\nfi # configure\n"
    }
    if ($prerm_remove) {
        $prerm .= 'if [ "$1" = remove ]; then' . "\n\n";
        $prerm .= $prerm_remove;
        $prerm .= "\nfi # remove\n"
    }

    write_script "$pkgdir/DEBIAN/preinst",  $preinst  if $preinst;
    write_script "$pkgdir/DEBIAN/prerm",    $prerm    if $prerm;
    write_script "$pkgdir/DEBIAN/postinst", $postinst if $postinst;
    write_script "$pkgdir/DEBIAN/postrm",   $postrm   if $postrm;

    write_file "$pkgdir/DEBIAN/control", $control;
    write_file "$pkgdir/DEBIAN/conffiles", (join "\n", @conffiles) . "\n" if @conffiles;

    my $shlibs = get_shlib $pkgdir;
    write_file "$pkgdir/DEBIAN/shlibs", $shlibs if $shlibs;

    my $pkg_deb = "${pkgdir}_${debversion}_${ARCH}.deb";
    # FIXME: we need GNU tar
    shell_exec "PATH=/usr/gnu/bin:/usr/bin dpkg-deb -b '$pkgdir' '$pkg_deb'";
    shell_exec "rm -r -f '$pkgdir'";

    my $md5sum = get_output_line "md5sum    $pkg_deb | cut -d' ' -f1";
    my $sha1   = get_output_line "sha1sum   $pkg_deb | cut -d' ' -f1";
    my $sha256 = get_output_line "sha256sum $pkg_deb | cut -d' ' -f1";
    my $size   = (stat $pkg_deb)[7];
    my $pkg_deb_base = basename $pkg_deb;

    $changes{'Checksums-Sha1'} .= "\n $sha1 $size $pkg_deb_base";
    $changes{'Checksums-Sha256'} .= "\n $sha256 $size $pkg_deb_base";
    $changes{'Files'} .= "\n $md5sum $size $debsection $debpriority $pkg_deb_base";
    $changes{'Binary'} .= " $debname";

    #print Dumper($manifest_data);
}

my $changes_cnt = join "\n", map {"$_: $changes{$_}"} sort keys %changes;
write_file "$OUTDIR/$changes{'Source'}.changes", $changes_cnt;

