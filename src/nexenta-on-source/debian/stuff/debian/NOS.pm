#!/usr/bin/perl -w

package NOS;

use FindBin;
use lib "$FindBin::Bin/";

use File::Path;
use File::Basename;

use strict;

#------------------------------
# Constructor
#------------------------------
sub new
{
    my $class = shift;
    my $self = {
        _fileName => '',
        _moduleName => '',
        _version => '5.11-0.148-1',
        _manifest => {},
        _scripts => {},
        _installproto => [],
    };

    bless $self, $class;
    return $self;
}


###############################
#------------------------------
# function init()
#------------------------------
sub init
{
    my ($self) = @_;
    undef ($self->{_manifest});
#    $self->{_manifest} = {};
    undef ($self->{_scripts});
#    $self->{_scripts} = {};
    undef ($self->{_installproto});
#    $self->{_installproto} = [];
}

#------------------------------
# function init()
#------------------------------
sub getScripts
{
    my ($self) = @_;
    return $self->{_scripts};
}

#------------------------------
# function setVersion()
#------------------------------
sub setVersion
{
    my ( $self, $version ) = @_;
    $self->{_version} = $version if defined($version);
    return $self->{_version};
}

#------------------------------
# function getVersion()
#------------------------------
sub getVersion
{
    my ( $self ) = @_;
    return $self->{_version};
}

#------------------------------
# function getModuleName()
#------------------------------
sub getModuleName
{
    my ( $self ) = @_;
    return $self->{_moduleName};
}

#------------------------------
# function getFileName()
#------------------------------
sub getFileName
{
    my ( $self ) = @_;
    return $self->{_fileName};
}

#------------------------------
# function readFile()
#------------------------------
sub readFile
{
    my ( $self, $filename ) = @_;
#    my ( $filename ) = @_;

#    print $self->getFunctionName().", $filename\n";
#    my( $filename ) = shift;
    my $lines = [];
    my $templines = [];
    my $line = '';
    my $incfile = '';
    my $dirName = '';

    local *FILE;
    open( FILE, "<", $filename ) or die "Can't open '$filename' : $!";
    while( <FILE> ) {

        chomp;              # remove trailing newline characters

        s/^\$\(sparc_ONLY\)/REMOVED /;
        s/^\$\(i386_ONLY\)//;
        s/\$\(ARCH64\)/amd64/g;
        s/\$\(ARCH32\)/i86/g;
        s/\$\(ARCH\)/i386/g;
        s/\$\(PKGVERS\)/$self->{_version}/g;

        s/#.*//;            # ignore comments by erasing them
        next if /^(\s)*$/;  # skip blank lines
        next if /^#/;       # skip comments lines

        if (/<include/)
        {
            $incfile = $_;
            $incfile =~ s/<include //;
            $incfile =~ s/>//;
            
            if ($incfile eq 'global_zone_only_component')
            {
                push (@$lines, 'file path=_fakeGlobalZone_ variant.opensolaris.zone=global');
                next;
            }
            
            $dirName = dirname($filename);
            $templines = $self->readFile($dirName.'/'.$incfile);
            push (@$lines, @$templines);
            next;
        }
        if (/<transform/)
        {
            next;
        }

        if ($_ =~ /\\$/)
        {
            chop($_);
            $line .= $_;
            next;
        }
        else
        {
            s/^\s*//;           # remove first space(s)
            $line .= $_;
        }

        if ($line =~ /^REMOVED/)
        {
            $line = '';
            next;
        }
#        print "== $line\n";

        push @$lines, $line;    # push the data line onto the array
        $line = '';
    }
    close FILE;
    
#    $self->{_fileName} = $filename;
#    $self->{_moduleName} = lc(basename($filename, ".mf"));

    return $lines;  # reference
}

#------------------------------
# function getData()
#------------------------------
sub getData()
{
    my ( $self, $str ) = @_;

#print "input: $str\n";

#    my($str) = shift;
    $_ = $str;
    my $res = {};

    my $actions = {};

    my $attrs = [];
    push(@$attrs, 'path');
    push(@$attrs, 'mode');
    push(@$attrs, 'owner');
    push(@$attrs, 'group');
    push(@$attrs, 'preserve');
    push(@$attrs, 'elfarch');
    push(@$attrs, 'elfbits');
    push(@$attrs, 'elfhash');
    push(@$attrs, 'original_name');
    push(@$attrs, 'restart_fmri');
    push(@$attrs, 'variant.opensolaris.zone');
    $$actions{'file'} = $attrs;

    $attrs = [];
    push(@$attrs, 'path');
    push(@$attrs, 'mode');
    push(@$attrs, 'owner');
    push(@$attrs, 'group');
    push(@$attrs, 'preserve');
    push(@$attrs, 'variant.opensolaris.zone');
    $$actions{'dir'} = $attrs;

    $attrs = [];
    push(@$attrs, 'path');
    push(@$attrs, 'target');
    $$actions{'link'} = $attrs;

    $attrs = [];
    push(@$attrs, 'path');
    push(@$attrs, 'target');
    $$actions{'hardlink'} = $attrs;

    $attrs = [];
    push(@$attrs, 'name');
    push(@$attrs, 'alias');
    push(@$attrs, 'class');
    push(@$attrs, 'perms');
    push(@$attrs, 'clone_perms');
    push(@$attrs, 'policy');
    push(@$attrs, 'privs');
    push(@$attrs, 'devlink');
    $$actions{'driver'} = $attrs;

    $attrs = [];
    push(@$attrs, 'type');
    push(@$attrs, 'fmri');
    push(@$attrs, 'predicate');
    push(@$attrs, 'root-image');
    $$actions{'depend'} = $attrs;

    $attrs = [];
    push(@$attrs, 'license');
    push(@$attrs, 'must-accept');
    push(@$attrs, 'must-display');
    $$actions{'license'} = $attrs;

    $attrs = [];
    push(@$attrs, 'category');
    push(@$attrs, 'desc');
    push(@$attrs, 'hotline');
    push(@$attrs, 'name');
    push(@$attrs, 'pkg');
    push(@$attrs, 'vendor');
    push(@$attrs, 'version');
    $$actions{'legacy'} = $attrs;

    $attrs = [];
    push(@$attrs, 'name');
    push(@$attrs, 'value');
    push(@$attrs, 'info.classification');
    push(@$attrs, 'pkg.description');
    push(@$attrs, 'pkg.obsolete');
    push(@$attrs, 'pkg.renamed');
    push(@$attrs, 'pkg.summary');
    $$actions{'set'} = $attrs;

    $attrs = [];
    push(@$attrs, 'groupname');
    push(@$attrs, 'gid');
    $$actions{'group'} = $attrs;

    $attrs = [];
    push(@$attrs, 'username');
    push(@$attrs, 'password');
    push(@$attrs, 'uid');
    push(@$attrs, 'group');
    push(@$attrs, 'gcos-field');
    push(@$attrs, 'home-dir');
    push(@$attrs, 'login-shell');
    push(@$attrs, 'group-list');
    push(@$attrs, 'ftpuser');
    push(@$attrs, 'lastchng');
    push(@$attrs, 'min');
    push(@$attrs, 'max');
    push(@$attrs, 'warn');
    push(@$attrs, 'inactive');
    push(@$attrs, 'expire');
    push(@$attrs, 'flag');
    $$actions{'user'} = $attrs;

    my $buff = [];
    my $action = '';
    $$res{'action'} = $buff;

    $action = $_ =~ m/^(\S*)/;
    $action = $1;
    if (defined($$actions{$action}))
    {
        push(@$buff, $action)
    }
    else
    {
        print "Undefined action '$action'\n";
        return;
#        push(@$buff, 'none')
    }

#print "== origin: $str\n";
# if ($action eq 'dir');

    my $origstr = $str;
    $_ = $origstr;
    s/^\S*//; # remove $action
#print "== orig2: $_\n";
    my $val;
    $attrs = $$actions{$action};

#    print "== $attrs, @$attrs\n";

    if (!defined($attrs))
    {
        print "WARNING: action '$action' undefined!\n";
        return (undef $res);
    }

    foreach my $attr (sort @$attrs)
    {
        my $found = 1;
        my $buff = [];
        $val = '';

        $$res{$attr} = $buff if (/$attr=/);

        while($found)
        {
            if (/\s$attr=/)
            {
#print "1 - $attr\n";
                if (/\s$attr=\"/)
                {
                    $val = $_ =~ m/\s$attr=\"(.*?)\"/;
                    $val = "\"$1\"" if defined($1);
#print "2 == $val\n";
                }
                else
                {
                    $val = $_ =~ m/\s$attr=(\S*)/;
                    $val = $1;
#print "1 == $val\n";
                }
                push(@$buff, $val);
#                $_ = $`.$';
                $val =~ s/\\/\\\\/g;
                $val =~ s/\*/\\\*/g;
                $val =~ s/\$/\\\$/g;
                $val =~ s/\+/\\\+/g;
                $val =~ s/\(/\\\(/g;
                $val =~ s/\)/\\\)/g;
                $val =~ s/\[/\\\[/g;
                $val =~ s/\]/\\\]/g;
#print "2 == $val\n";
                s/\s$attr=$val//; # remove attribute=value
#print "str = $_\n";
                $found = 1;
            }
            else
            {
                $found = 0;
            }
        }
    }

#    print "$type\n";

    return $res;
}

sub print_mog_line()
{
    my($myhash) = @_;
    
    foreach my $act (keys %$myhash)
    {
        print "$act=$$myhash{$act}[0]\n";
    }
}

#------------------------------
# function readMfFile()
#------------------------------
sub readMfFile()
{
    my ( $self, $mffile ) = @_;

    my $result = {};
    my $actions = [];

#    print "Loading file: $mffile\n";
    $self->{_fileName} = $mffile;
    $self->{_moduleName} = lc(basename($mffile, ".mf"));
    $self->{_moduleName} =~ s/_/-/g;

    my $lines = $self->readFile($mffile);

    my $mf;
    foreach my $line (sort @{$lines})
    {
        if($self->{_moduleName} eq 'runtime-perl-510-module-sun-solaris')
        {
            $line =~ s/PLAT/i86pc/g;
            $line .= ' mode=0555' if ($line =~ /.*\.so/);
            $line .= ' mode=0444' if ($line =~ /.*\.(pm|bs)/);
        }
#print "4 - $line\n";
        $mf = $self->getData($line);
        next unless(defined($mf));
        $actions = $$result{$$mf{'action'}[0]};
        push(@$actions, $mf);
        $$result{$$mf{'action'}[0]} = $actions;
    }
    $self->{_manifest} = $result;
#    return $result;
    return $self->{_manifest};
}

#------------------------------
# function getManifest()
#------------------------------
sub getManifest
{
    my ( $self ) = @_;
    return $self->{_manifest};
}

#------------------------------
# function getActions()
#------------------------------
sub getActions
{
    my ( $self, $actions, $field ) = @_;

    my $result = [];

    foreach my $action (@$actions)
    {
        push(@$result, $$action{$field}[0]) if defined($$action{$field});
    }

    return $result;
}

#------------------------------
# function getDescription()
#------------------------------
sub getDescription
{
    my ( $self ) = @_;

    my $mf = $self->getManifest();

    return unless defined($$mf{'set'});

    my $output = 'none';
    my $r = $$mf{'set'};

    foreach my $line (@$r)
    {
        $output = $$line{'value'}[0] if ($$line{'name'}[0] eq 'pkg.description');
        $output =~ s/"//g;
    }

    return $output;
}

#------------------------------
# function getShortDescription()
#------------------------------
sub getShortDescription
{
    my ( $self ) = @_;

    my $mf = $self->getManifest();
    return unless defined($$mf{'set'});

    my $output = 'none';
    my $r = $$mf{'set'};

    foreach my $line (@$r)
    {
        $output = $$line{'value'}[0] if ($$line{'name'}[0] eq 'pkg.summary');
        $output =~ s/"//g;
    }

    return $output;
}

#------------------------------
# function getArch()
#------------------------------
sub getArch
{
    my ( $self ) = @_;

    my $mf = $self->getManifest();
    return unless defined($$mf{'set'});

    my $output = 'none';
    my $r = $$mf{'set'};

    foreach my $line (@$r)
    {
        $output = $$line{'value'}[0] if ($$line{'name'}[0] eq 'variant.arch');
        $output =~ s/"//g;
    }

    return $output;
}

#------------------------------
# function getPkgObsolete()
#------------------------------
sub getPkgObsolete
{
    my ( $self ) = @_;

    my $mf = $self->getManifest();
    return unless defined($$mf{'set'});

    my $output = 'none';
    my $r = $$mf{'set'};

    foreach my $line (@$r)
    {
        $output = $$line{'value'}[0] if ($$line{'name'}[0] eq 'pkg.obsolete');
        $output =~ s/"//g;
    }

    return $output;
}

#------------------------------
# function getPkgRenamed()
#------------------------------
sub getPkgRenamed
{
    my ( $self ) = @_;

    my $mf = $self->getManifest();
    return unless defined($$mf{'set'});

    my $output = 'none';
    my $r = $$mf{'set'};

    foreach my $line (@$r)
    {
        $output = $$line{'value'}[0] if ($$line{'name'}[0] eq 'pkg.renamed');
        $output =~ s/"//g;
    }

    return $output;
}
1;
