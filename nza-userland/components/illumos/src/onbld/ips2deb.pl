#!/usr/bin/perl
#
# Copyright 2010-2012 Nexenta Systems, Inc. All rights reserved.
#
# VERSION 1.19
#

use FindBin;
use lib "$FindBin::Bin/";

use File::Path;
use File::Copy;
#use File::Find;
use File::Basename;
use Getopt::Long;
use Env;

use strict;

use MFT;

#-----------------------------------------------------------------------------#
my $ignorePkgs = {};
$$ignorePkgs{'consolidation-osnet-osnet-message-files'} = 1;
$$ignorePkgs{'consolidation-osnet-osnet-incorporation'} = 1;
$$ignorePkgs{'consolidation-osnet-osnet-redistributable'} = 1;

my $specialPkgs = {};
$$specialPkgs{'system-file-system-zfs'} = 1;
$$specialPkgs{'system-file-system-zfs-tests'} = 1;
$$specialPkgs{'system-file-system-udfs'} = 1;
$$specialPkgs{'system-floating-point-scrubber'} = 1;
$$specialPkgs{'system-tnf'} = 1;
$$specialPkgs{'diagnostic-cpu-counters'} = 1;
$$specialPkgs{'driver-network-eri'} = 1;
$$specialPkgs{'compatibility-ucb'} = 1;
$$specialPkgs{'diagnostic-powertop'} = 1;
$$specialPkgs{'diagnostic-latencytop'} = 1;
$$specialPkgs{'network-ipfilter'} = 1;
$$specialPkgs{'developer-debug-mdb'} = 1;
$$specialPkgs{'system-extended-system-utilities'} = 1;
$$specialPkgs{'storage-library-network-array'} = 1;
$$specialPkgs{'service-resource-cap'} = 1;
$$specialPkgs{'developer-linker'} = 1;
$$specialPkgs{'developer-dtrace'} = 1;
$$specialPkgs{'driver-network-eri'} = 1;


my $tmpl = {};
my $modulesList = [];
my @dirs = "";
my $verbouse = 0;
my $gatePath = '';

#------------------------------
# main
#------------------------------
{
    $$tmpl{'MAINTAINER'} = 'Nexenta Systems <maintainer@nexenta.com>';
    $$tmpl{'MANIFESTGATE'} = $gatePath.'/usr/src/pkg/manifests';
    $$tmpl{'DESTANATION'} = "$FindBin::Bin/packages";
    $$tmpl{'MFEXT'} = 'mog';
    $$tmpl{'CATEGORY'} = 'undef';
    $$tmpl{'PKGVER'} = '1.0.0-deb';
    undef $$tmpl{'COMPONENT_VERSION'};
    my @pkgName = "";
    $pkgName[0] = 'all';
    my $result = GetOptions ( "p|pkg|package=s" => \@pkgName,
				'v|verbose!' => \$verbouse,
				"basegate=s" => \$gatePath,
				"pv|pversion|package_version=s" => \$$tmpl{'PKGVER'},
				"cv|component_version=s" => \$$tmpl{'COMPONENT_VERSION'},
				"o|out|destination=s" => \$$tmpl{'DESTANATION'},
				"manifest_gate|mg|mfg=s" => \$$tmpl{'MANIFESTGATE'},
				"maintainer=s" => \$$tmpl{'MAINTAINER'},
				"manifest_extention|me|mfe=s" => \$$tmpl{'MFEXT'},
				"category|pkgtype=s" => \$$tmpl{'CATEGORY'},
				"d|dir=s" => \@dirs);

    $$tmpl{'ARCH'} = '';

    my $arch = `uname -p`;
    chomp $arch;
    $$tmpl{'ARCH'} = $arch;


    my $templates = &initTemplates();

    my $str;
    if ($pkgName[0] eq 'all' && scalar(@pkgName) < 2)
    {
	&modulesList($$tmpl{'MANIFESTGATE'});
    }
    else
    {
	foreach my $pkgNameOne (@pkgName)
	{
	    $$tmpl{'MANIFESTGATE'} = dirname ($pkgNameOne);
	    $pkgNameOne = basename ($pkgNameOne);
	    $$tmpl{'MFEXT'} = $pkgNameOne;
	    $$tmpl{'MFEXT'} =~ s/.*\.//;
	    $str = "\.".$$tmpl{'MFEXT'}."\$";
	    $pkgNameOne =~ s/$str//;
	    push(@$modulesList, $pkgNameOne) unless ($pkgNameOne =~ /\.\// || $pkgNameOne eq 'all');
	}
    }

    my $pkgFailed = [];
    my $pkg;
    foreach $pkg (sort @$modulesList)
    {
        next if ($pkg =~ /^consolidation-/i);
        print "Generating structure from file: $pkg ... " if $verbouse;
        my $oPackage = &genPackage($pkg);
        my $res = ($oPackage) ? 'FAILED' : 'OK';
        print "- $res\n" if $verbouse;
        print "-------------------------------------------------------------\n" if $verbouse;
        push(@$pkgFailed, "$pkg ($oPackage)") if ($res eq 'FAILED');
    }

    if (scalar(@$pkgFailed) > 0)
    {
        open(LOG, ">", "$pkg.failed.txt") or die "Can't open '$pkg.failed.txt' : $!";
        my $str = "\n";
        $str .= "1 - absent 'dir'\n";
        $str .= "2 - absent 'file'\n";
        $str .= "3 - absent 'hardlink'\n";
        $str .= "4 - absent 'driver'\n";
        $str .= "5 - absent 'link'\n";
        $str .= "6 - absent 'user'\n";
        $str .= "7 - absent 'group'\n";
        $str .= "8 - arch != $$tmpl{'ARCH'}\n";
        $str .= "9 - PkgObsolete\n";
        $str .= "0 - PkgRenamed\n";
        $str .= "a - absent depends\n";
        $str .= "b - ignored packages\n";
        print LOG "Help: \n$str\n\n";
        print LOG "Failed packages:".scalar(@$pkgFailed)."\n\t".join("\n\t", @$pkgFailed);
        close(LOG);
    }

}

sub d
{
    my $str = "\.".$$tmpl{'MFEXT'}."\$";
    /$str/ or return;

    my $mod = basename($File::Find::name);
    $mod =~ s/$str//;
    if ($mod =~ /^SUNW/i)
    {
        return unless ($mod =~ /^SUNWcsd$/i || $mod =~ /^SUNWcs$/i);
    }
    push(@$modulesList, $mod);
}

sub modulesList ()
{
    my $dir = shift;

    my $str = "\.".$$tmpl{'MFEXT'}."\$";

    my @files = <$dir/*>;
    foreach my $line (@files)
    {
	next unless ($line =~ /$str/);
	my $mod = basename($line);
	$mod =~ s/$str//;
	if ($mod =~ /^SUNW/i)
	{
	    next unless ($mod =~ /^SUNWcsd$/i || $mod =~ /^SUNWcs$/i);
	}
	push(@$modulesList, $mod) unless defined($$ignorePkgs{$mod});
    }
}


#------------------------------
# genPackage
#------------------------------
sub genPackage
{
    my ($package) = @_;

    my $packageFile;
    $packageFile = $package.".".$$tmpl{'MFEXT'};
    $packageFile =~ /^SUNWcs\./ if ($package eq 'sunwcs');
    $packageFile = /^SUNWcsd\./ if ($package eq 'sunwcsd');
    $packageFile = $$tmpl{'MANIFESTGATE'}."/".$packageFile;

    $$tmpl{'DEPENDENCES'} = '${shlibs:Depends}, ${misc:Depends}';
    $$tmpl{'FIXPERMS'} = '';
    $$tmpl{'POSTINST_CONFIGURE'} = '';
    $$tmpl{'PREINST_INSTALL'} = '';
    $$tmpl{'PRERM_UPGRADE'} = '';
    $$tmpl{'CONFFILES'} = '';
    $$tmpl{'ZONE'} = '';
    $$tmpl{'ORIGINALVERSION'} = '';
    $$tmpl{'ORIGINALNAME'} = '';
    $$tmpl{'REPLACES'} = '';
    $$tmpl{'PRIORITY'} = '';

    my $replaces = {};
    $replaces = readSpecFile("$FindBin::Bin/ips2deb.replaces");

    my $specVersions = {};
    $specVersions = readSpecFile("$FindBin::Bin/ips2deb.versions");

    my $specPriorities = {};
    $specPriorities = readSpecFile("$FindBin::Bin/ips2deb.priorities");

    my $mft = new MFT();
    my $str = '';
    my $file = '';
    my $dep = [];

    $mft->init();
    $mft->setHostArch($$tmpl{'ARCH'});
    $mft->readMfFile($packageFile);
    $$tmpl{'PKGNAME'} = $mft->getModuleName();
    $$tmpl{'PKGSHORTDESCRIPTION'} = $mft->getShortDescription();
    $$tmpl{'PKGDESCRIPTION'} = $mft->getDescription();
    $$tmpl{'ORIGINALVERSION'} = $mft->getOrigVersion();
    $$tmpl{'ORIGINALVERSION'} = $$tmpl{'COMPONENT_VERSION'} if (defined($$tmpl{'COMPONENT_VERSION'}));
    $$tmpl{'ORIGINALNAME'} = $mft->getOrigName();
    $$tmpl{'SAVETO'} = $$tmpl{'DESTANATION'}.'/'.$$tmpl{'PKGNAME'}.'/debian';

    $$tmpl{'PKGVER'} = $$specVersions{"$$tmpl{'PKGNAME'}"} if (defined($$specVersions{"$$tmpl{'PKGNAME'}"}));
    $$tmpl{'PRIORITY'} = 'optional';
    $$tmpl{'PRIORITY'} = $$specPriorities{"$$tmpl{'PKGNAME'}"} if (defined($$specPriorities{"$$tmpl{'PKGNAME'}"}));

    return '8' unless ($mft->getArch() eq $$tmpl{'ARCH'});
    return '9' if ($mft->getPkgObsolete() eq 'true');
    return '0' if ($mft->getPkgRenamed() eq 'true');
    return 'b' if (defined($$ignorePkgs{$$tmpl{'PKGNAME'}}));
    return 'b' if ($$tmpl{'PKGNAME'} =~ /^consolidation-/i);

    $str = "test -d $$tmpl{'DESTANATION'}/$$tmpl{'PKGNAME'} && rm -rf $$tmpl{'DESTANATION'}/$$tmpl{'PKGNAME'}";
    system($str);

    my $res='';
    my $oDirs = &saveDirs($mft);
    $res = '1' if ($oDirs);
    my $oFiles = &saveFiles($mft);
    $res .= '2' if ($oFiles);
    my $oHardLinks = &saveHardLinks($mft);
    $res .= '3' if ($oHardLinks);
    my $oDrivers = &saveDrivers($mft);
    $res .= '4' if ($oDrivers);
    my $oLinks = &saveLinks($mft);
    $res .= '5' if ($oLinks);
    my $oGroups = &saveGroups($mft);
    $res .= '7' if ($oGroups);
    my $oUsers = &saveUsers($mft);
    $res .= '6' if ($oUsers);
    $dep = $mft->getDepend();
    $res .= 'a' unless (defined($dep) && scalar($dep) > 0);

    return $res if ($oDirs && $oFiles && $oHardLinks && $oUsers && $oGroups && ($res =~ /^a/));

# fill scripts and conffiles
    my $templates = &initTemplates();
    my $output = $mft->getScripts();

# postinst
    my $operation = 'postinst';
    my $operations = $$output{$operation} if defined($$output{$operation});
    if (defined ($operations) && scalar(@$operations) > 0)
    {
        $$tmpl{'POSTINST_CONFIGURE'} = join("\n\t",@$operations);
        &saveExtfiles($mft, $operation);
    }

# preinst
    $operation = 'preinst';
    undef $operations;
    $operations = $$output{$operation} if defined($$output{$operation});
    if (defined ($operations) && scalar(@$operations) > 0)
    {
        $$tmpl{'PREINST_INSTALL'} = join("\n\t",@$operations);
        &saveExtfiles($mft, $operation);
    }

# prerm
    $operation = 'prerm';
    undef $operations;
    $operations = $$output{$operation} if defined($$output{$operation});
    if (defined ($operations) && scalar(@$operations) > 0)
    {
        $$tmpl{'PRERM_UPGRADE'} = join("\n\t",@$operations);
        &saveExtfiles($mft, $operation);
    }

    $operation = 'fixperms';
    undef $operations;
    $operations = $$output{$operation} if defined($$output{$operation});
    if (defined ($operations) && scalar(@$operations) > 0)
    {
        $$tmpl{'PATH'} = '/usr/bin:/sbin:/usr/sbin';
        $$tmpl{'FIXPERMS'} = join("\n",@$operations);
        &saveExtfiles($mft, $operation);
    }
    else
    {
        my $str = fillTemplate($$templates{$operation});
        my $file = $$tmpl{'SAVETO'}.'/'.$$tmpl{'PKGNAME'}.'.'.$operation;
        &saveFinalFile($file, $str);
    }

# we need clean <pkg>.conffiles
# because we have scheme for update files by postinst operation
    $operation = 'conffiles';
    $$output{$operation} = "";
    $mft->{_scripts} = $output;
    $$tmpl{'CONFFILES'} = "";
    &saveExtfiles($mft, $operation);

    $operation = 'changelog';
    $str = fillTemplate($$templates{$operation});
    $file = $$tmpl{'SAVETO'}."/$operation";
    &saveFinalFile($file, $str);


    $$tmpl{'DEPENDENCES'} .= ', sunwcs' if ($$specialPkgs{$$tmpl{'PKGNAME'}});
    $$tmpl{'DEPENDENCES'} .= ', '.join(', ', @$dep) if (defined($dep) && scalar(@$dep) > 0);
    $$tmpl{'REPLACES'} = "\nReplaces: ".$$replaces{$$tmpl{'PKGNAME'}} if (defined($$replaces{$$tmpl{'PKGNAME'}}));

    $operation = 'control';
    $str = fillTemplate($$templates{$operation});
    $file = $$tmpl{'SAVETO'}."/$operation";
    &saveFinalFile($file, $str);

    $operation = 'copyright';
    $str = fillTemplate($$templates{$operation});
    $file = $$tmpl{'SAVETO'}."/$operation";
    &saveFinalFile($file, $str);

    $operation = 'compat';
    $str = fillTemplate($$templates{$operation});
    $file = $$tmpl{'SAVETO'}."/$operation";
    &saveFinalFile($file, $str);

    $operation = 'rules';
    $str = fillTemplate($$templates{$operation});
    $file = $$tmpl{'SAVETO'}."/$operation";
    &saveFinalFile($file, $str);
    $str = "chmod 0755 $file";
    system($str);

    return 0;
}

#------------------------------
# fillTemplate
#------------------------------
sub fillTemplate
{
    my ( $template ) = @_;
    my $str = '';

    $str = $template;

    my $curDate = qx(date "+%a, %d %h %Y %H:%M:%S %z");
    chomp($curDate);
    $$tmpl{'DATE'} = $curDate;

    $str =~ s/%%PKGNAME%%/$$tmpl{'PKGNAME'}/g;
    $str =~ s/%%PKGVER%%/$$tmpl{'PKGVER'}/g;
    $str =~ s/%%MAINTAINER%%/$$tmpl{'MAINTAINER'}/g;
    $str =~ s/%%PKGSHORTDESCRIPTION%%/$$tmpl{'PKGSHORTDESCRIPTION'}/g;
    $str =~ s/%%PKGDESCRIPTION%%/$$tmpl{'PKGDESCRIPTION'}/g;
    $str =~ s/%%DEPENDENCES%%/$$tmpl{'DEPENDENCES'}/g;
    $str =~ s/%%DATE%%/$$tmpl{'DATE'}/g;
    $str =~ s/%%FIXPERMS%%/$$tmpl{'FIXPERMS'}/g;
    $str =~ s/%%PATH%%/$$tmpl{'PATH'}/g;
    $str =~ s/%%POSTINST_CONFIGURE%%/$$tmpl{'POSTINST_CONFIGURE'}/g;
    $str =~ s/%%PREINST_INSTALL%%/$$tmpl{'PREINST_INSTALL'}/g;
    $str =~ s/%%PRERM_UPGRADE%%/$$tmpl{'PRERM_UPGRADE'}/g;
    $str =~ s/%%CONFFILES%%/$$tmpl{'CONFFILES'}/g;
    $str =~ s/%%ORIGINALVERSION%%/$$tmpl{'ORIGINALVERSION'}/g;
    $str =~ s/%%ORIGINALNAME%%/$$tmpl{'ORIGINALNAME'}/g;
    $str =~ s/%%CATEGORY%%/$$tmpl{'CATEGORY'}/g;
    $str =~ s/%%REPLACES%%/$$tmpl{'REPLACES'}/g;
    $str =~ s/%%ARCH%%/$$tmpl{'ARCH'}/g;
    $str =~ s/%%PRIORITY%%/$$tmpl{'PRIORITY'}/g;

    return $str;
}

#------------------------------
# saveFinalFile
#------------------------------
sub saveFinalFile
{
    my ( $file, $str ) = @_;

    my $dirName = dirname($file);
    system("mkdir -p $dirName");

    local *FILE;
    open (FILE, ">", $file);
    print FILE "$str\n";
    close (FILE);
}

#------------------------------
# saveExternalfiles
#------------------------------
sub saveExtfiles
{
    my ($mft, $operation) = @_;

    my $output = $mft->getScripts();
    my $templates = &initTemplates();
    my $operations = $$output{$operation} if defined($$output{$operation});
    return unless defined($$output{$operation});

    my $str = fillTemplate($$templates{$operation});
    my $file = $$tmpl{'SAVETO'}.'/'.$$tmpl{'PKGNAME'}.'.'.$operation;
    &saveFinalFile($file, $str);
}

#------------------------------
# saveDepends()
#------------------------------
sub saveDepends
{
#    my ($mft) = @_;
    my ($package) = @_;
    my $packageFile = "manifests/".$package.".mf";

    my $mft = new MFT();
    $mft->init();
    $mft->readMfFile($packageFile);
    my $res = [];
    $res = $mft->getDepend();

    print join(', ', @$res)."\n";
}

#------------------------------
# saveFiles()
#------------------------------
sub saveFiles
{
    my ($mft) = @_;

    my $mf = $mft->getManifest();
    return 1 unless defined($$mf{'file'});

    my $r = $$mf{'file'};
    my $moduleName = $mft->getModuleName();

    my $str;
    my $found = 0;
    my $output = {};
    $output = $mft->{_scripts} if (defined($mft->{_scripts}));

    my $postinst = [];
    my $preinst = [];
    my $postrm = [];
    my $prerm = [];
    my $conffiles = [];
    my $fixperms = [];
    my $zone = [];
    my $svcChk = {};

    $postinst = $$output{'postinst'} if (defined($$output{'postinst'}));
    $preinst = $$output{'preinst'} if (defined($$output{'preinst'}));
    $postrm = $$output{'postrm'} if (defined($$output{'postrm'}));
    $prerm = $$output{'prerm'} if (defined($$output{'prerm'}));
    $conffiles = $$output{'conffiles'} if (defined($$output{'conffiles'}));
    $fixperms = $$output{'fixperms'} if (defined($$output{'fixperms'}));
    $zone = $$output{'zone'} if (defined($$output{'zone'}));

    if ($moduleName eq 'sunwcs')
    {
	$str = "cp -f \$BASEDIR/usr/bin/cp \$BASEDIR/usr/bin/ln";
	push (@$postinst, $str);

	$str = "cp -f \$BASEDIR/usr/bin/cp \$BASEDIR/usr/bin/mv";
	push (@$postinst, $str);

	$str = "cp -f \$BASEDIR/usr/lib/isaexec \$BASEDIR/usr/bin/ksh";
	push (@$postinst, $str);

	$str = "cp -f \$BASEDIR/usr/lib/isaexec \$BASEDIR/usr/bin/ksh93";
	push (@$postinst, $str);

	$str = "cp -f \$BASEDIR/usr/lib/isaexec \$BASEDIR/usr/sbin/rem_drv";
	push (@$postinst, $str);

	$str = "cp -f \$BASEDIR/usr/lib/isaexec \$BASEDIR/usr/sbin/update_drv";
	push (@$postinst, $str);
    }

    my @buff;
    my @buffperm;
    my $file = $$tmpl{'SAVETO'}.'/'.$moduleName.".install";
    my $fileperm = $$tmpl{'SAVETO'}.'/'.$moduleName.".files.fixperm";

    foreach my $line (@$r)
    {
        my $preserve = $$line{'preserve'}[0] if defined($$line{'preserve'});
        my $restart_fmri = $$line{'restart_fmri'}[0] if defined($$line{'restart_fmri'});
        my $arch = $$line{'variant.arch'}[0] if defined($$line{'variant.arch'});

        my $zonevariant = $$line{'variant.opensolaris.zone'}[0] if defined($$line{'variant.opensolaris.zone'});

        my $group = $$line{'group'}[0];
        my $mode = $$line{'mode'}[0];
        my $owner = $$line{'owner'}[0];

        my $path = $$line{'path'}[0]; # if defined($$line{'path'});
        my $path_dir = dirname($path);
        my $path_others = $$line{'others'}[0]; # if defined($$line{'others'});
        my $origPath = $path;

        next if ($path =~ /etc\/motd/); # use etc/motd from base-files package


        push(@$fixperms, "mkdir -p \$DEST/$path_dir");

	$found = 0;
	undef($path_others) if ($path_others =~ /NOHASH/ || defined($$line{'chash'}));
        if (defined($path_others))
        {
	    $str = dirname("$origPath");
	    mkpath("$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$str");

	    foreach my $dirOne (@dirs)
	    {
		next unless (-e "$dirOne/$path_others" && -f "$dirOne/$path_others");
		copy("$dirOne/$path_others", "$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$origPath") or die "Copy failed:($dirOne/$path_others), $!";
		chown $owner, $group, "$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$origPath";
		chmod oct("$mode"), "$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$origPath";
	    $found = 1;
	    }
        }
        else
        {
	    foreach my $dirOne (@dirs)
	    {
		next if (($dirOne =~ /^\.\//) || (length($dirOne) < 3));
		next unless (-e "$dirOne/$origPath" && -f "$dirOne/$origPath");
		$str = dirname("$origPath");
		mkpath("$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$str");
		copy("$dirOne/$origPath", "$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$origPath") or die "Copy failed: $!";
		chown $owner, $group, "$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$origPath";
		chmod oct("$mode"), "$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$origPath";
		$found = 1;
		last;
	    }
        }

        unless ($found)
        {
	    print "FAILED!\n==NOT found: $path\n"; 
	    exit 1;
        }

	    push(@$fixperms, "test -f \"\$DEST/$origPath\" || echo '== Missing: $origPath'");
	    push(@$fixperms, "test -f \"\$DEST/$origPath\" || exit 1");
	    push(@$fixperms, "chmod $mode \"\$DEST/$origPath\"");
	    push(@$fixperms, "chown $owner:$group \"\$DEST/$origPath\"");

        if (defined($$line{'preserve'}) && $preserve eq 'renamenew')
        {
            $str = "mv \$DEST/$origPath \$DEST/$origPath.new";
	    push(@$fixperms, $str);

            $str = "([ -f \$BASEDIR/$path ] || mv -f \$BASEDIR/$path.new \$BASEDIR/$path)";
            push(@$postinst, $str);
        }

        if (defined($$line{'preserve'}) && $preserve eq 'renameold')
        {
            $str = "mv \$DEST/$origPath \$DEST/$origPath.$moduleName";
	    push(@$fixperms, $str);

            $str = "([ -f \$BASEDIR/$path ] && mv -f \$BASEDIR/$path \$BASEDIR/$path.old )";
            push(@$postinst, $str);

            $str = "([ -f \$BASEDIR/$path.$moduleName ] && mv -f \$BASEDIR/$path.$moduleName \$BASEDIR/$path )";
            push(@$postinst, $str);
        }

        if (defined($$line{'preserve'}) && $preserve eq 'legacy')
        {
            $str = "mv \$DEST/$origPath \$DEST/$origPath.$moduleName";
	    push(@$fixperms, $str);

            $str = "([ -f \$BASEDIR/$path ] || rm -f \$BASEDIR/$path.$moduleName )";
            push(@$postinst, $str);

            $str = "([ -f \$BASEDIR/$path ] && mv -f \$BASEDIR/$path \$BASEDIR/$path.legacy )";
            push(@$postinst, $str);

            $str = "([ -f \$BASEDIR/$path.$moduleName ] && mv -f \$BASEDIR/$path.$moduleName \$BASEDIR/$path )";
            push(@$postinst, $str);
        }

        if (defined($$line{'preserve'}) && $preserve eq 'true')
        {
            $str = "mv \$DEST/$origPath \$DEST/$origPath.$moduleName";
	    push(@$fixperms, $str);

            $str = "([ -f \$BASEDIR/$path.saved ] && mv -f \$BASEDIR/$path.saved \$BASEDIR/$path )";
            push(@$postinst, $str);
            $str = "([ -f \$BASEDIR/$path ] || mv -f \$BASEDIR/$path.$moduleName \$BASEDIR/$path )";
            
            push(@$postinst, $str);
            $str = "([ -f \$BASEDIR/$path ] && rm -f \$BASEDIR/$path.$moduleName)";
            
            push(@$postinst, $str);
    	    $str = "([ -f \$BASEDIR/$path ] && mv -f \$BASEDIR/$path \$BASEDIR/$path.saved)";
    	    push(@$prerm, $str);
    	    
        }

        if (defined($zonevariant) && ($zonevariant eq 'global'))
        {
	    $str = "[ \"\$ZONEINST\" = \"1\" ] && ([ -f \$BASEDIR/$path ] && rm -f \$BASEDIR/$path)";
            push(@$postinst, $str);
        }

        if (defined($restart_fmri))
        {
            unless(defined($$svcChk{"$restart_fmri"}))
            {
                $$svcChk{"$restart_fmri"} = 1;
		push(@$postinst, "[ \"\${BASEDIR}\" = \"/\" ] && ( /usr/sbin/svcadm restart $restart_fmri || true )");
            }
        }
    }

    return 1 unless ($found);

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);
    $$output{'preinst'} = $preinst if (scalar(@$preinst) > 0);
    $$output{'postrm'} = $postrm if (scalar(@$postrm) > 0);
    $$output{'prerm'} = $prerm if (scalar(@$prerm) > 0);
    $$output{'conffiles'} = $conffiles if (scalar(@$conffiles) > 0);
    $$output{'fixperms'} = $fixperms if (scalar(@$fixperms) > 0);
    $$output{'zone'} = $zone if (scalar(@$zone) > 0);

    $mft->{_scripts} = $output;
    return 0;
}


#------------------------------
# saveDirs()
#------------------------------
sub saveDirs
{
    my ($mft) = @_;

    my $mf = $mft->getManifest();
    return 1 unless defined($$mf{'dir'});

    my $r = $$mf{'dir'};
    my $moduleName = $mft->getModuleName();

    my $str;
    my $found = 0;
    my $output = {};
    $output = $mft->{_scripts} if (defined($mft->{_scripts}));

    my $postinst = [];
    my $fixperms = [];
    
    $postinst = $$output{'postinst'} if (defined($$output{'postinst'}));
    $fixperms = $$output{'fixperms'} if (defined($$output{'fixperms'}));

    my @buff;
    my $file = $$tmpl{'SAVETO'}.'/'.$moduleName.".dirs";
    foreach my $line (@$r)
    {
        my $arch = $$line{'variant.arch'}[0] if defined($$line{'variant.arch'});

        my $group = $$line{'group'}[0];
        my $mode = $$line{'mode'}[0];
        my $owner = $$line{'owner'}[0];

        my $path = $$line{'path'}[0];

	mkpath("$$tmpl{'SAVETO'}/$$tmpl{'PKGNAME'}/$path", 
		{mode => oct($mode), uwner => $owner, group => $group});

        push(@$fixperms, "chmod $mode \$DEST/$path");
        push(@$fixperms, "chown $owner:$group \$DEST/$path");
        $found = 1;
    }
    return 1 unless ($found);

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);
    $$output{'fixperms'} = $fixperms if (scalar(@$fixperms) > 0);
    $mft->{_scripts} = $output;
    return 0;
}

#------------------------------
# saveUsers
#------------------------------
sub saveUsers
{
    my ($mft) = @_;

    my $mf = $mft->getManifest();
    return 1 unless defined($$mf{'user'});

    my $r = $$mf{'user'};
    my $moduleName = $mft->getModuleName();
    my $str;
    my $output = {};
    $output = $mft->{_scripts} if (defined($mft->{_scripts}));

    my $postinst = [];

    $postinst = $$output{'postinst'} if (defined($$output{'postinst'}));

    foreach my $user (@$r)
    {
        $str = '';
        push (@$postinst, $str);
        $str = "if ! getent passwd $$user{'username'}[0] >/dev/null 2>\&1 ; then";
        push (@$postinst, $str);
        $str = "useradd ";
        $str .= " -c $$user{'gcos-field'}[0] " if defined ($$user{'gcos-field'});
        $str .= " -s $$user{'login-shell'}[0] " if defined ($$user{'login-shell'});
        $str .= " -u $$user{'uid'}[0] ";
        $str .= " -g $$user{'group'}[0] " if defined ($$user{'group'});
        $str .= " -m $$user{'username'}[0]";
        push (@$postinst, $str);
        $str = "fi";
        push (@$postinst, $str);
    }

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);

    $mft->{_scripts} = $output;
    return 0;
}


#------------------------------
# saveGroups
#------------------------------
sub saveGroups
{
    my ($mft) = @_;

    my $mf = $mft->getManifest();
    return 1 unless defined($$mf{'group'});

    my $r = $$mf{'group'};
    my $moduleName = $mft->getModuleName();
    my $str;
    my $output = {};
    $output = $mft->{_scripts} if (defined($mft->{_scripts}));

    my $postinst = [];

    $postinst = $$output{'postinst'} if (defined($$output{'postinst'}));

    foreach my $grp (@$r)
    {
        $str = '';
        push (@$postinst, $str);
        $str = "if ! getent group $$grp{'groupname'}[0] >/dev/null 2>\&1 ; then";
        push (@$postinst, $str);
        $str = "groupadd -g $$grp{'gid'}[0] $$grp{'groupname'}[0]";
        push (@$postinst, $str);
        $str = "fi";
        push (@$postinst, $str);
    }

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);

    $mft->{_scripts} = $output;
    return 0;
}

#------------------------------
# saveLinks
#------------------------------
sub saveLinks
{
    my ($mft) = @_;

    my $mf = $mft->getManifest();
    return 1 unless defined($$mf{'link'});

    my $r = $$mf{'link'};
    my $moduleName = $mft->getModuleName();
    my $str;
    my $output = {};
    $output = $mft->{_scripts} if (defined($mft->{_scripts}));

    my $postinst = [];
    my $preinst = [];
    my $postrm = [];
    my $prerm = [];
    my $fixperms = [];

    $postinst = $$output{'postinst'} if (defined($$output{'postinst'}));
    $preinst = $$output{'preinst'} if (defined($$output{'preinst'}));
    $postrm = $$output{'postrm'} if (defined($$output{'postrm'}));
    $prerm = $$output{'prerm'} if (defined($$output{'prerm'}));
    $fixperms = $$output{'fixperms'} if (defined($$output{'fixperms'}));

    my @buff;
    foreach my $line (@$r)
    {
        my $path = $$line{'path'}[0];
        my $target = $$line{'target'}[0];
        my $mediator = $$line{'mediator'}[0] if defined($$line{'mediator'});
        my $mediator_ver = $$line{'mediator-version'}[0] if defined($$line{'mediator-version'});
        my $mediator_priority = $$line{'mediator-priority'}[0] if defined($$line{'mediator-priority'});
        
        my $alternative_priority = 0;
        $alternative_priority = 99 if (defined($mediator));
        $alternative_priority = 10 if (defined($mediator_priority) && ($mediator_priority eq 'vendor'));

        my $zonevariant;
        $zonevariant = $$line{'variant.opensolaris.zone'}[0] if defined($$line{'variant.opensolaris.zone'});

        my $dir;
        my $alternativesName;
        $dir = dirname("$path");
        if (defined($zonevariant) && ($zonevariant eq 'global'))
        {
	    $str = "[ \"\$ZONEINST\" = \"1\" ] || (mkdir -p \$BASEDIR/$dir && ln -f -s $target \$BASEDIR/$path)";
	    if (defined($mediator))
	    {
		$alternativesName = getAlternativesName($path);
		$str = "[ \"\$ZONEINST\" = \"1\" ] || (update-alternatives --quiet --altdir \$BASEDIR/etc/alternatives --admindir \$BASEDIR/var/lib/dpkg/alternatives --install $path $alternativesName \$BASEDIR/$dir/$target $alternative_priority || true)";
		$str = "(update-alternatives --quiet --altdir \$BASEDIR/etc/alternatives --admindir \$BASEDIR/var/lib/dpkg/alternatives --install /$path $alternativesName /$dir/$target $alternative_priority || true)";
	    }
            push(@$postinst, $str);
        }
        else
        {
	    $str = "mkdir -p \$DEST/$dir && ln -f -s $target \$DEST/$path";
	    if (defined($mediator))
	    {
		$alternativesName = getAlternativesName($path);
        	$str = "(update-alternatives --quiet --altdir \$BASEDIR/etc/alternatives --admindir \$BASEDIR/var/lib/dpkg/alternatives --install /$path $alternativesName /$dir/$target $alternative_priority || true)";
        	
        	push(@$postinst, $str);
        	
		$str = "if [ \"$1\" != \"upgrade\" ]; then\n";
		$str .= "	(update-alternatives --altdir \$BASEDIR/etc/alternatives --admindir \$BASEDIR/var/lib/dpkg/alternatives --remove $alternativesName /$dir/$target || true)\n";
		$str .= "fi\n";
		push(@$prerm, $str);
	    }
	    else
	    {
		push (@$fixperms, $str);
	    }
        }

    }

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);
    $$output{'preinst'} = $preinst if (scalar(@$preinst) > 0);
    $$output{'postrm'} = $postrm if (scalar(@$postrm) > 0);
    $$output{'prerm'} = $prerm if (scalar(@$prerm) > 0);
    $$output{'fixperms'} = $fixperms if (scalar(@$fixperms) > 0);

    $mft->{_scripts} = $output;
    return 0;
}


#------------------------------
# saveHardLinks
#------------------------------
sub saveHardLinks
{
    my ($mft) = @_;

    my $mf = $mft->getManifest();
    return 1 unless defined($$mf{'hardlink'});

    my $r = $$mf{'hardlink'};
    my $moduleName = $mft->getModuleName();
    my $str;
    my $output = {};
    $output = $mft->{_scripts} if (defined($mft->{_scripts}));

    my $postinst = [];
    my $preinst = [];
    my $postrm = [];
    my $prerm = [];
    my $fixperms = [];

    $postinst = $$output{'postinst'} if (defined($$output{'postinst'}));
    $preinst = $$output{'preinst'} if (defined($$output{'preinst'}));
    $postrm = $$output{'postrm'} if (defined($$output{'postrm'}));
    $prerm = $$output{'prerm'} if (defined($$output{'prerm'}));
    $fixperms = $$output{'fixperms'} if (defined($$output{'fixperms'}));

    if ($moduleName eq 'sunwcs')
    {
	$str = "mkdir -p \$DEST/usr/bin && cp -f \$DEST/usr/bin/cp \$DEST/usr/bin/ln";
        push(@$fixperms, $str);

	$str = "mkdir -p \$DEST/usr/bin && cp -f \$DEST/usr/bin/cp \$DEST/usr/bin/mv";
        push(@$fixperms, $str);

	$str = "mkdir -p \$DEST/usr/bin && cp -f \$DEST/usr/lib/isaexec \$DEST/usr/bin/ksh";
        push(@$fixperms, $str);

	$str = "mkdir -p \$DEST/usr/bin && cp -f \$DEST/usr/lib/isaexec \$DEST/usr/bin/ksh93";
        push(@$fixperms, $str);

	$str = "mkdir -p \$DEST/usr/bin && cp -f \$DEST/usr/lib/isaexec \$DEST/usr/sbin/rem_drv";
        push(@$fixperms, $str);

	$str = "mkdir -p \$DEST/usr/bin && cp -f \$DEST/usr/lib/isaexec \$DEST/usr/sbin/update_drv";
        push(@$fixperms, $str);
    }


    foreach my $line (@$r)
    {
        my $path = $$line{'path'}[0];
        my $target = $$line{'target'}[0];
        my $destDir = dirname($path);
        my $destFile = basename($path);
        my $zonevariant = $$line{'variant.opensolaris.zone'}[0] if defined($$line{'variant.opensolaris.zone'});

	next if ($path eq "usr/bin/ln");
	next if ($path eq "usr/bin/mv");
	next if ($path eq "usr/bin/ksh");
	next if ($path eq "usr/bin/ksh93");
	next if ($path eq "usr/sbin/rem_drv");
	next if ($path eq "usr/sbin/update_drv");

        if (defined($zonevariant) && ($zonevariant eq 'global'))
        {

            $str = "[ \"\$ZONEINST\" = \"1\" ] || (mkdir -p \$BASEDIR/$destDir && cd \$BASEDIR/$destDir && ln -f $target $destFile)";
            push (@$postinst, $str);

            $str = "[ \"\$ZONEINST\" = \"1\" ] || rm -f \$BASEDIR/$path";
            push (@$prerm, $str);
        }
        else
        {
            $str = "mkdir -p \$BASEDIR/$destDir && (cd \$BASEDIR/$destDir && ln -f $target $destFile)";
            push (@$postinst, $str);

            $str = "rm -f \$BASEDIR/$path";
            push (@$prerm, $str);
        }
    }

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);
    $$output{'preinst'} = $preinst if (scalar(@$preinst) > 0);
    $$output{'postrm'} = $postrm if (scalar(@$postrm) > 0);
    $$output{'prerm'} = $prerm if (scalar(@$prerm) > 0);
    $$output{'fixperms'} = $fixperms if (scalar(@$fixperms) > 0);

    $mft->{_scripts} = $output;
    return 0;
}

#------------------------------
# saveDrivers
#------------------------------
sub saveDrivers
{
    my ($mft) = @_;

    my $mf = $mft->getManifest();
    return 1 unless defined($$mf{'driver'});
    my $r = $$mf{'driver'};
    my $moduleName = $mft->getModuleName();

    my $str;
    my $output = {};
    $output = $mft->{_scripts} if (defined($mft->{_scripts}));

    my $postinst = [];
    my $preinst = [];
    my $postrm = [];
    my $prerm = [];

    $postinst = $$output{'postinst'} if (defined($$output{'postinst'}));
    $preinst = $$output{'preinst'} if (defined($$output{'preinst'}));
    $postrm = $$output{'postrm'} if (defined($$output{'postrm'}));
    $prerm = $$output{'prerm'} if (defined($$output{'prerm'}));

    foreach my $line (@$r)
    {
        my $name = $$line{'name'}[0] if defined($$line{'name'});
        my $privs = $$line{'privs'}[0] if defined($$line{'privs'});
        my $policy = $$line{'policy'}[0] if defined($$line{'policy'});
        my $devlink = $$line{'devlink'}[0] if defined($$line{'devlink'});
        my @devlinkFields if defined($$line{'devlink'});

        my $originalPerm;
        my $originalClonePerm;

        my $drv = 'add_drv -n ';

        $originalPerm = $$line{'perms'} if defined($$line{'perms'});
        $originalClonePerm = $$line{'clone_perms'} if defined($$line{'clone_perms'});

        my $perms = '';
        my $OPTIONS = '';

        $OPTIONS .= " -P $privs" if defined($privs);

        my $classes = $$line{'class'} if defined($$line{'class'});
        my $class = '';
        if (defined($classes))
        {
            if (scalar($classes) > 1)
            {
                $class .= join(" ", @$classes);
            }
            else
            {
                $class = @$$classes[0];
            }
            $OPTIONS .= " -c '$class'";
        }

        my $aliases = $$line{'alias'} if defined($$line{'alias'});
        my $alias = '';
        if (defined($aliases))
        {
            if (scalar($aliases) > 1)
            {
                $alias .= join("\" \"", @$aliases);
            }
            else
            {
                $alias = @$aliases[0];
            }
            $OPTIONS .= " -i '\"$alias\"'";
        }

        if (defined($originalPerm))
        {
            if ($originalPerm)
            {
                if (scalar(@$originalPerm) > 1)
                {
                    $perms = join(",", @$originalPerm);
                }
                else
                {
                    $perms = $$originalPerm[0];
                }
                $perms =~ s/"/'/g; #"
                $OPTIONS .= " -m $perms";
            }
        }

        $policy =~ s/"/'/g if defined($policy); #"
        $OPTIONS .= " -p $policy" if defined($policy);

        $str = "[ \"\$ZONEINST\" = \"1\" ] || (grep -c \"^$name \" \$BASEDIR/etc/name_to_major >/dev/null || ( $drv \$BASEDIR_OPT $OPTIONS $name ) )";
        push (@$postinst, $str);

	$str = "[ \"\$ZONEINST\" = \"1\" ] || ( rem_drv -n \$BASEDIR_OPT $name )";
	push (@$prerm, $str);

        if (defined($originalClonePerm))
        {
            $drv = 'update_drv -n ';

            $perms = '';
            $OPTIONS = '';
            $OPTIONS .= " -P $privs" if defined($$line{'privs'});
            $OPTIONS .= " -i '$alias'" if (defined($$line{'alias'}) && ! defined($$line{'perms'}));
            $OPTIONS .= " -c '$class'" if (defined($$line{'class'}) && ! defined($$line{'perms'}));;

            if ($originalClonePerm)
            {
                $policy =~ s/"/'/g if defined($policy); #"
                $OPTIONS .= " -p $policy" if defined($policy);

                foreach $perms (@$originalClonePerm)
                {
                    $perms =~ s/"/'/g; #"

                    $str = "[ \"\$ZONEINST\" = \"1\" ] || (grep -c \"$perms\" \$BASEDIR/etc/minor_perm >/dev/null || $drv -a \$BASEDIR_OPT $OPTIONS -m $perms clone)";
                    push (@$postinst, $str);
                    $str = "[ \"\$ZONEINST\" = \"1\" ] || (grep -c \"$perms\" \$BASEDIR/etc/minor_perm >/dev/null && $drv -d \$BASEDIR_OPT $OPTIONS -m $perms clone)";
                    push (@$prerm, $str);
                }
            }
        }

        if(defined($devlink))
        {
            $devlink =~ s/\\t/\t/g;
	    @devlinkFields = split(' ', $devlink);
            $str = "[ \"\$ZONEINST\" = \"1\" ] || (grep -c \"^$devlinkFields[0]\" \$BASEDIR/etc/devlink.tab >/dev/null || (echo \"$devlink\" >> \$BASEDIR/etc/devlink.tab))";
            push (@$postinst, $str);

            $str = "[ \"\$ZONEINST\" = \"1\" ] || ( cat \$BASEDIR/etc/devlink.tab | sed -e '/^$devlinkFields[0]/d' > \$BASEDIR/etc/devlink.tab.new; mv \$BASEDIR/etc/devlink.tab.new \$BASEDIR/etc/devlink.tab )";
            push (@$prerm, $str);
        }
    }

    $str = "";
    push (@$postinst, $str) if (scalar(@$postinst) > 0);
    push (@$prerm, $str) if (scalar(@$prerm) > 0);

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);
    $$output{'preinst'} = $preinst if (scalar(@$preinst) > 0);
    $$output{'postrm'} = $postrm if (scalar(@$postrm) > 0);
    $$output{'prerm'} = $prerm if (scalar(@$prerm) > 0);

    $mft->{_scripts} = $output;
    return 0;
}

#------------------------------
# initTemplates()
#------------------------------
sub initTemplates
{
    my $initTemplate = {};

# changelog
$$initTemplate{'changelog'} = '%%PKGNAME%% (%%PKGVER%%) unstable; urgency=low

  * Temporary file, need only for package generation process

 -- %%MAINTAINER%%  %%DATE%%
';

# compat
$$initTemplate{'compat'} = '7';

# conffiles
$$initTemplate{'conffiles'} = '%%CONFFILES%%';

# control
$$initTemplate{'control'} = 'Source: %%PKGNAME%%
Section: %%CATEGORY%%
Priority: %%PRIORITY%%
XBS-Original-Version: %%ORIGINALVERSION%%
XBS-Category: %%CATEGORY%%
Maintainer: %%MAINTAINER%%

Package: %%PKGNAME%%
Architecture: solaris-%%ARCH%%
Depends: %%DEPENDENCES%%
Provides: %%ORIGINALNAME%%%%REPLACES%%
Description: %%PKGSHORTDESCRIPTION%%
 %%PKGDESCRIPTION%%
';

# copyright
$$initTemplate{'copyright'} = '
Copyright:

Copyright (c) 2011 illumian.  All rights reserved.
Use is subject to license terms.
';

# fixperms
$$initTemplate{'fixperms'} = '#!/bin/sh

export PATH=%%PATH%%

%%FIXPERMS%%
';

# postinst
$$initTemplate{'postinst'} = '#!/bin/sh

# postinst script for %%PKGNAME%%
#
# see: dh_installdeb(1)

#set -e

# summary of how this script can be called:
#        * <postinst> \`configure\' <most-recently-configured-version>
#        * <old-postinst> \`abort-upgrade\' <new version>
#        * <conflictor\'s-postinst> \`abort-remove\' \`in-favour\' <package>
#          <new-version>
#        * <postinst> \`abort-remove\'
#        * <deconfigured\'s-postinst> \`abort-deconfigure\' \`in-favour\'
#          <failed-install-package> <version> \`removing\'
#          <conflicting-package> <version>
# for details, see http://www.debian.org/doc/debian-policy/ or
# the debian-policy package

PATH=/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

if [ "${BASEDIR:=/}" != "/" ]; then
    BASEDIR_OPT="-b $BASEDIR"
fi

case "$1" in
    configure)
        %%POSTINST_CONFIGURE%%
    ;;

    abort-upgrade|abort-remove|abort-deconfigure)
    ;;

    *)
        echo "postinst called with unknown argument \'$1\'" >&2
        exit 1
    ;;
esac

# dh_installdeb will replace this with shell code automatically
# generated by other debhelper scripts.

#DEBHELPER#

exit 0
';

# preinst
$$initTemplate{'preinst'} = '#!/bin/sh
# preinst script for sunwcs
#
# see: dh_installdeb(1)

#set -e

# summary of how this script can be called:
#        * <new-preinst> \`install\'
#        * <new-preinst> \`install\' <old-version>
#        * <new-preinst> \`upgrade\' <old-version>
#        * <old-preinst> \`abort-upgrade\' <new-version>
# for details, see http://www.debian.org/doc/debian-policy/ or
# the debian-policy package

PATH=/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

if [ "${BASEDIR:=/}" != "/" ]; then
    BASEDIR_OPT="-b $BASEDIR"
fi

case "$1" in
    install|upgrade)
	%%PREINST_INSTALL%%
    ;;

    abort-upgrade)
    ;;

    *)
        echo "preinst called with unknown argument \'$1\'" >&2
        exit 1
    ;;
esac

# dh_installdeb will replace this with shell code automatically
# generated by other debhelper scripts.

#DEBHELPER#

exit 0
';


# prerm
$$initTemplate{'prerm'} = '#!/bin/sh
# prerm script for sunwcs
#
# see: dh_installdeb(1)

#set -e

# summary of how this script can be called:
#        * <prerm> \`remove\'
#        * <old-prerm> \`upgrade\' <new-version>
#        * <new-prerm> \`failed-upgrade\' <old-version>
#        * <conflictor\'s-prerm> \`remove\' \`in-favour\' <package> <new-version>
#        * <deconfigured\'s-prerm> \`deconfigure\' \`in-favour\'
#          <package-being-installed> <version> \`removing\'
#          <conflicting-package> <version>
# for details, see http://www.debian.org/doc/debian-policy/ or
# the debian-policy package

PATH=/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

if [ "${BASEDIR:=/}" != "/" ]; then
    BASEDIR_OPT="-b $BASEDIR"
fi

case "$1" in
    remove|upgrade|deconfigure)
	%%PRERM_UPGRADE%%
    ;;

    failed-upgrade)
    ;;

    *)
        echo "prerm called with unknown argument \'$1\'" >&2
        exit 1
    ;;
esac

# dh_installdeb will replace this with shell code automatically
# generated by other debhelper scripts.

#DEBHELPER#

exit 0
';


# rules
$$initTemplate{'rules'} = '#!/usr/bin/gmake -f
# -*- makefile -*-
# Sample debian/rules that uses debhelper.
# This file was originally written by Joey Hess and Craig Small.
# As a special exception, when this file is copied by dh-make into a
# dh-make output file, you may use that output file without restriction.
# This special exception was added by Craig Small in version 0.37 of dh-make.

# Uncomment this to turn on verbose mode.
#export DH_VERBOSE=1

#MYGATE := ${BASEGATE}
DEST := $(CURDIR)/debian/%%PKGNAME%%

##configure: configure-stamp
##configure-stamp:
##	dh_testdir
	# Add here commands to configure the package.
##	touch configure-stamp


##build: build-stamp
build:

##build-stamp: configure-stamp 
#	dh_testdir
	# Add here commands to compile the package.
#	touch $@

clean:
	dh_testdir
	dh_testroot
	-rm -f build-stamp configure-stamp

	# Add here commands to clean up after the build process.
#	-$(MAKE) clean
#	dh_clean

##install: build
install:
##	dh_testdir
##	dh_testroot
##	dh_clean -k 
##	dh_installdirs

	# Add here commands to install the package into debian/tmp.
#	mkdir -p $(CURDIR)/debian/tmp
#	mv proto/* $(CURDIR)/debian/tmp


# Build architecture-independent files here.
##binary-indep: build install
# We have nothing to do by default.

# Build architecture-dependent files here.
##binary-arch: build install
binary-arch:
	dh_testdir
	dh_testroot
#	test -f $(CURDIR)/debian/%%PKGNAME%%.fixperms && MYSRCDIR=$(MYGATE) DEST=$(DEST) /bin/sh $(CURDIR)/debian/%%PKGNAME%%.fixperms
	test -f $(CURDIR)/debian/%%PKGNAME%%.fixperms && DEST=$(DEST) /bin/sh $(CURDIR)/debian/%%PKGNAME%%.fixperms
#	dh_makeshlibs -p%%PKGNAME%%
	dh_makeshlibs
	dh_installdeb
#	dh_shlibdeps debian/tmp/lib/* debian/tmp/usr/lib/*
	-dh_shlibdeps -Xdebian/sunwcs/usr/kernel/* -- --ignore-missing-info
	dh_gencontrol
	dh_md5sums
	dh_builddeb

##binary: binary-indep binary-arch
binary: binary-arch
##.PHONY: build clean binary-indep binary-arch binary install configure
.PHONY: clean binary-arch binary
';


    return $initTemplate;
}

#------------------------------
# function readSpecFile()
#------------------------------
sub readSpecFile()
{
    my ( $filename ) = @_;

    my $lines = {};
    my @buff;

    local *FILE;
    open( FILE, "<", $filename ) or die "Can't open '$filename' : $!";
    while( <FILE> ) {

        chomp;              # remove trailing newline characters

        next if /^(\s)*$/;  # skip blank lines
        next if /^#/;       # skip comments lines
        next if /^\s*#/;    # skip comments lines

	next unless /:/;

	@buff = split(':', $_);
	$$lines{$buff[0]} = $buff[1];
    }
    close FILE;

    return $lines;  # reference
}

#------------------------------
# function getAlternativesName()
#------------------------------
sub getAlternativesName()
{
    my ( $name ) = @_;

    $name = $name.32 if (($name =~ /\/i86\//) || ($name =~ /\/sparcv7\//));
    $name = $name.64 if (($name =~ /\/amd64\//) || ($name =~ /\/sparcv9\//));
    $name = basename ($name);
    return $name;
}
