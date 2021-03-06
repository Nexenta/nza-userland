
#
# Copyright 2010-2014 Nexenta Systems, Inc. All rights reserved.
# VERSION: 1.7

package MFT;

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
        _arch => '',
        _version => '5.11-0.200',
        _manifest => {},
        _scripts => {},
        _installproto => [],
        _depends => [],
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
    undef ($self->{_scripts});
    undef ($self->{_installproto});
    undef ($self->{_depends});
}

#------------------------------
# function getHostArch()
#------------------------------
sub getHostArch()
{
    my ($self) = @_;
    return $self->{_arch};
}

#------------------------------
# function setHostArch()
#------------------------------
sub setHostArch()
{
    my ($self, $arch) = @_;
    $self->{_arch} = $arch if defined($arch);
    return $self->{_arch};
}

#------------------------------
# function getScripts()
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
    my $lines = [];
    my $templines = [];
    my $line = '';
    my $incfile = '';
    my $dirName = '';

    local *FILE;
    open( FILE, "<", $filename ) or die "Can't open '$filename' : $!";
    while( <FILE> ) {

        chomp;              # remove trailing newline characters

#        s/^\$\(sparc_ONLY\)/REMOVED /;
#        s/^\$\(i386_ONLY\)//;
#        s/\$\(ARCH64\)/amd64/g;
#        s/\$\(MACH64\)/amd64/g;
#        s/\$\(ARCH32\)/i86/g;
#        s/\$\(MACH\)/i86/g;
#        s/\$\(ARCH\)/i386/g;
#        s/\$\(PKGVERS\)/$self->{_version}/g;

#        s/#.*//;            # ignore comments by erasing them
        next if /^(\s)*$/;  # skip blank lines
        next if /^#/;       # skip comments lines
        next if /^\s*#/;    # skip comments lines

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

        push @$lines, $line;    # push the data line onto the array
        $line = '';
    }
    close FILE;

    return $lines;  # reference
}

#------------------------------
# function getData()
#------------------------------
sub getData()
{
    my ( $self, $str ) = @_;

    $_ = $str;
    my $res = {};

    my $actions = {};

    my $buff = [];
    my $action = '';
    $$res{'action'} = $buff;

    $action = $_ =~ m/^(\S*)/;
    $action = $1;

    push(@$buff, $action);

    my $origstr = $str;
    $_ = $origstr;
    s/^\S*//; # remove $action

    my $tmpRes = {};
    $tmpRes = $self->parser($_);
    $$tmpRes{'action'} = $$res{'action'};

    return $tmpRes;
}

#------------------------------
# function parser()
#------------------------------
sub parser ()
{
    my ( $self, $line ) = @_;

    my $flag = 1;
    my $flag_cnt = 0;

    my $res = {};
    my $others = [];
    my $wrd = '';
    my @words = split(' ', $line);
    foreach my $word (@words)
    {
	my $buff = [];
	if ($word =~ /"/) #"
	{
	    $flag_cnt++;
	    $flag_cnt = 0 if ($flag_cnt > 1);
	}

	if ($flag_cnt)
	{
	    $wrd .= ' '.$word;
	    $flag = 0;
	}
	else
	{
	    if ($flag < 1 && $flag_cnt < 1)
	    {
		$wrd .= ' '.$word;
	    }
	    else
	    {
		$wrd = $word;
	    }
	    $flag = 1 unless ($flag_cnt);
	}
	$wrd =~ s/^\s*//;
	if ($flag)
	{
	    if ($wrd =~ /=/)
	    {
		my @tokens = split(/=/, $wrd, 2);
#		$tokens[1] =~ s/"//g;
		defined($$res{$tokens[0]}) ? $buff = $$res{$tokens[0]} : $$res{$tokens[0]} = $buff;
		push(@$buff, $tokens[1]);
	    }
	    else
	    {
		push(@$others, $wrd) if (length($wrd) > 2);
	    }
	    $wrd = '';
	}
    }
    $$res{'others'} = $others if (scalar(@$others) > 0);

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

    $self->{_fileName} = $mffile;

    my $lines = $self->readFile($mffile);

    my $mf;
    foreach my $line (sort @{$lines})
    {
        $mf = $self->getData($line);
        next unless(defined($mf));
        $actions = $$result{$$mf{'action'}[0]};
        push(@$actions, $mf);
        $$result{$$mf{'action'}[0]} = $actions;
    }
    $self->{_manifest} = $result;
    $self->{_moduleName} = $self->getPkgName();

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
	if ($$line{'name'}[0] eq 'variant.arch')
	{
	    my $arr = @$line{'value'};
	    if (scalar(@$arr) > 1)
	    {
		foreach my $val (@$arr)
		{
		    if ($val eq $self->{_arch})
		    {
			$output = $val;
			last;
		    }
		}
	    }
	    else
	    {
		$output = $$arr[0];
		$output =~ s/["']//g;
	    }
	}
#        $output = $$line{'value'}[0] if ($$line{'name'}[0] eq 'variant.arch');
    }
# workaround for now - return i386 if ARCH not defined
#    $output = 'i386' if ($output eq 'none');

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


#------------------------------
# function getOrigVersion()
#------------------------------
sub getOrigVersion
{
    my ( $self ) = @_;

    my $mf = $self->getManifest();
    return unless defined($$mf{'set'});

    my $output = 'none';
    my $r = $$mf{'set'};

    foreach my $line (@$r)
    {
	if ($$line{'name'}[0] eq 'pkg.fmri')
	{
	    $output = $$line{'value'}[0];
	    last;
	}
    }
    $output =~ s/\S*\@//;
    $output =~ s/,\S*//;

    return $output;
}


#------------------------------
# function getOrigName()
#------------------------------
sub getOrigName
{
    my ( $self ) = @_;

    my $mf = $self->getManifest();
    return unless defined($$mf{'set'});

    my $output = 'none';
    my $r = $$mf{'set'};

    foreach my $line (@$r)
    {
	if ($$line{'name'}[0] eq 'pkg.fmri')
	{
	    $output = $$line{'value'}[0];
	    last;
	}
    }
    $output =~ s/\@\S*//;
    $output =~ s/\S*\///;
    $output =~ s/_/-/g;
    $output = lc($output);

    return $output;
}

#------------------------------
# function getPkgName()
#------------------------------
sub getPkgName
{
    my ( $self ) = @_;

    my $mf = $self->getManifest();
    return unless defined($$mf{'set'});

    my $output = 'none';
    my $r = $$mf{'set'};

    foreach my $line (@$r)
    {
	if ($$line{'name'}[0] eq 'pkg.fmri')
	{
	    $output = $$line{'value'}[0];
	    last;
	}
    }
    $output =~ s/\@.*$//;

    $output =~ s/\/openindiana.org\///;
    $output =~ s/\/opensolaris.org\///;
    $output =~ s/\/oi-experimental\///;
    $output =~ s/\/oi-dev\///;
    $output =~ s/\/oi-il\///;
    $output =~ s/pkg:\///;

    $output =~ s/_/-/g;
    $output =~ s/\//-/g;
    $output = lc($output);

    return $output;
}



#------------------------------
# function getDepend()
#------------------------------
# get dependences packages names
sub getDepend
{
    my ( $self, $pkg, $version ) = @_;
    my $mf = $self->getManifest();
    my $result = [];
    my @deps;

    $pkg =~ s/\.mog/\.dep/g;
    my $dir = dirname($pkg);
    my $lines = $self->readFile($pkg);
    foreach my $line (sort @{$lines}) {
        if ($line =~ m/^depend/i) {
            my @fields = split / /,$line;
            my @files = split /=/,@fields[2];
            my @paths = split /=/,@fields[3];
            my $file = "@paths[1]/@files[1]";
            push(@deps, $file);
        }
    }

    opendir(DIR, $dir);
    my @manif = grep {/\.mog/} readdir(DIR);
    closedir(DIR);
    foreach my $man (@manif) {
        my $lines2 = $self->readFile($dir."/".$man);
        foreach my $line2 (sort @{$lines2}) {
            foreach my $fl (@deps) {
                if (grep{/path=$fl\s/} $line2) {
                    $man =~ s/\.mog//g;
                    my $lman = lc($man);
                    next if ($lman =~ m/driver-serial-usbsksp-usbs49_fw/i);
                    next if ($pkg =~ m/SUNWcsd/i);
                    push(@$result, "$lman"." (>= $version)");
                }
            }
        }
    }

    my $newresult = [];
    my %seen=();
    foreach(@$result) {
        push(@$newresult, $_) unless ($seen{$_}++);
    }

    my $r = $$mf{'depend'};

    my $pkgName;

    foreach my $line (@$r) 
    {
        my $fmri = $$line{'fmri'}[0] if defined($$line{'fmri'});
        next unless defined($fmri);
        my $type = $$line{'type'}[0] if defined($$line{'type'});
        next if ($type eq 'exclude');
        next unless ($type eq 'require');

        $pkgName = $fmri;
        next if ($pkgName =~ m/__TBD$/i);
        $pkgName =~ s/openindiana.org//;
        $pkgName =~ s/opensolaris.org//;
        $pkgName =~ s/pkg:\///;
        $pkgName =~ s/\@.*$//;
        $pkgName =~ s/\//-/g;
        $pkgName =~ s/_/-/g;
        $pkgName = lc($pkgName);

        next if ($pkgName =~ m/consolidation/i);
        next if ($pkgName =~ m/release-name/i);
        next if ($pkgName =~ m/compatibility-packages-sunwxwplt/i);
        next if ($pkgName =~ m/runtime-perl-584/i);
        next if ($pkgName =~ m/runtime-perl-510/i);
#       next if ($pkgName =~ m/system-library-gcc-3-runtime/i);
        push(@$newresult, $pkgName);
    }

    return $newresult;
}

1;
