#!/usr/bin/perl -w
#
# Copyright 2005-2011 Nexenta Systems, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Igor Kozhukhov <igor.kozhukhov@nexenta.com>
# VERSION 1.1
#

use FindBin;
use lib "$FindBin::Bin/";

use File::Path;
use File::Find;
use File::Basename;
use Env;

use strict;

use NOS;

#-----------------------------------------------------------------------------#
my $ignorePkgs = {};
$$ignorePkgs{'consolidation-osnet-osnet-message-files'} = 1;
$$ignorePkgs{'developer-build-onbld'} = 1;

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

#-----------------------------------------------------------------------------#
my $tmpl = {};
$$tmpl{'MAINTAINER'} = $ENV{'MAINTAINER'};
#$$tmpl{'MAINTAINER'} = 'Igor Kozhukhov <igor.kozhukhov@nexenta.com>';
#$$tmpl{'MAINTAINER'} = 'Nexenta Systems <maintainer@nexenta.com>';
#$$tmpl{'PKGVER'}='5.11-148-4.0.HPC-a1';
$$tmpl{'PKGVER'} = $ENV{'PKGVER'};
$$tmpl{'DESTANATION'} = "$FindBin::Bin/packages";
my $modulesList = [];
#-----------------------------------------------------------------------------#
#------------------------------
# main
#------------------------------
{
#    $ENV{'BASEGATE'} = '/Volumes/illumos/illumos-gate2';
    my $gatePath = $ENV{'BASEGATE'};

#    $ENV{'MANIFESTGATE'} = '.';
    unless ($ENV{'MANIFESTGATE'})
    {
#        my $manPath = "$gatePath/usr/src/pkg/manifests";
        $ENV{'MANIFESTGATE'} = $ENV{'BASEGATE'}.'/usr/src/pkg/manifests';
    }

    my $templates = &initTemplates();

    find(\&d, $ENV{'MANIFESTGATE'});

#    &genPackage('sunwcs');
#exit 0;

    my $pkgFailed = [];
    foreach my $pkg (sort @$modulesList)
    {
        next if ($$ignorePkgs{$pkg});
        print "Generating package: $pkg ... ";
        my $oPackage = &genPackage($pkg);
#        my $res = ($oPackage) ? $oPackage : 'OK';
        my $res = ($oPackage) ? 'FAILED' : 'OK';
        print "- $res\n";
        print "-------------------------------------------------------------\n";
        push(@$pkgFailed, "$pkg ($oPackage)") if ($res eq 'FAILED');
    }
    
    if (scalar(@$pkgFailed) > 0)
    {
        open(LOG, ">", "pkgfailed.txt") or die "Can't open 'pkgfailed.txt' : $!";
        print LOG "Failed packages:".scalar(@$pkgFailed)."\n\t".join("\n\t", @$pkgFailed);
        close(LOG);
    }

}

sub d
{
    /\.mf$/ or return;

    my $mod = basename($File::Find::name);
    $mod =~ s/\..*$//;
    if ($mod =~ /^SUNW/i)
    {
        return unless ($mod =~ /^SUNWcsd$/i || $mod =~ /^SUNWcs$/i);
    }
#    print "$mod\n";
    push(@$modulesList, $mod);
}

#------------------------------
# genPackage
#------------------------------
sub genPackage
{
    my ($package) = @_;

    my $packageFile;
    $packageFile = $package.".mf";
    $packageFile = 'SUNWcs.mf' if ($package eq 'sunwcs');
    $packageFile = 'SUNWcsd.mf' if ($package eq 'sunwcsd');
    $packageFile = $ENV{'MANIFESTGATE'}."/".$packageFile;

    $$tmpl{'DEPENDENCES'} = '${shlibs:Depends}, ${misc:Depends}';
#    $$tmpl{'PKGOLDNAME'} = '';
    $$tmpl{'FIXPERMS'} = '';
    $$tmpl{'POSTINST_CONFIGURE'} = '';
    $$tmpl{'PREINST_INSTALL'} = '';
    $$tmpl{'CONFFILES'} = '';
    $$tmpl{'ZONE'} = '';

    my $nos = new NOS();
    my $str = '';
    my $file = '';

    $nos->init();
#print "== pkgFile = $packageFile\n";
    $nos->readMfFile($packageFile);
#print "2\n";
    $$tmpl{'PKGNAME'} = $nos->getModuleName();
    $$tmpl{'PKGSHORTDESCRIPTION'} = $nos->getShortDescription();
    $$tmpl{'PKGDESCRIPTION'} = $nos->getDescription();

    $$tmpl{'SAVETO'} = $$tmpl{'DESTANATION'}.'/'.$$tmpl{'PKGNAME'}.'/debian';

    $str = "test -d $$tmpl{'DESTANATION'}/$$tmpl{'PKGNAME'} && rm -rf $$tmpl{'DESTANATION'}/$$tmpl{'PKGNAME'}";
    system($str);

    return 6 unless ($nos->getArch() eq 'i386');
    return 7 if ($nos->getPkgObsolete() eq 'true');
#    return 8 if ($nos->getPkgRenamed() eq 'true');

    my $res='';
    my $oDirs = &saveDirs($nos);
    $res = '1' if ($oDirs);
    my $oFiles = &saveFiles($nos);
    $res .= '2' if ($oFiles);
    my $oHardLinks = &saveHardLinks($nos);
    $res .= '3' if ($oHardLinks);
    my $oDrivers = &saveDrivers($nos);
    $res .= '4' if ($oDrivers);
    my $oLinks = &saveLinks($nos);
    $res .= '5' if ($oLinks);
    
    return $res if ($oDirs && $oFiles && $oHardLinks);

# fill scripts and conffiles
    my $templates = &initTemplates();
    my $output = $nos->getScripts();

    my $operation = 'postinst';
    my $operations = $$output{$operation} if defined($$output{$operation});
    if (defined ($operations) && scalar(@$operations) > 0)
    {
        $$tmpl{'POSTINST_CONFIGURE'} = join("\n\t",@$operations);
        &saveExtfiles($nos, $operation);
    }

    $operation = 'preinst';
    undef $operations;
    $operations = $$output{$operation} if defined($$output{$operation});
#print "== @$operations\n";
    if (defined ($operations) && scalar(@$operations) > 0)
    {
        $$tmpl{'PREINST_INSTALL'} = join("\n\t",@$operations);
        &saveExtfiles($nos, $operation);
    }

    $operation = 'fixperms';
    undef $operations;
    $operations = $$output{$operation} if defined($$output{$operation});
    if (defined ($operations) && scalar(@$operations) > 0)
    {
        $$tmpl{'PATH'} = '/usr/bin:/sbin:/usr/sbin';
        $$tmpl{'FIXPERMS'} = join("\n",@$operations);
        &saveExtfiles($nos, $operation);
    }

    $operation = 'conffiles';
    undef $operations;
    $operations = $$output{$operation} if defined($$output{$operation});
    if (defined ($operations) && scalar(@$operations) > 0)
    {
        $$tmpl{'CONFFILES'} = join("\n",@$operations);
        &saveExtfiles($nos, $operation);
    }

    $operation = 'zone';
    undef $operations;
    $operations = $$output{$operation} if defined($$output{$operation});
    if (defined ($operations) && scalar(@$operations) > 0)
    {
        $$tmpl{'ZONE'} = @$operations[0];
    }

    $operation = 'changelog';
    $str = fillTemplate($$templates{$operation});
    $file = $$tmpl{'SAVETO'}."/$operation";
    &saveFinalFile($file, $str);


    $$tmpl{'DEPENDENCES'} .= ', sunwcs' if ($$specialPkgs{$$tmpl{'PKGNAME'}});
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
    $str = "chmod 0777 $file";
    system($str);
    
    return 0;
}

#-----------------------------------------------------------------------------#

#------------------------------
# fillTemplate
#------------------------------
sub fillTemplate
{
#    my ( $file ) = @_;
    my ( $template ) = @_;
    
    my $str = '';

    $str = $template;

    my $curDate = qx(date "+%a, %d %h %Y %X %z");
    chomp($curDate);
    $$tmpl{'DATE'} = $curDate;

    $str =~ s/%%PKGNAME%%/$$tmpl{'PKGNAME'}/g;
    $str =~ s/%%PKGVER%%/$$tmpl{'PKGVER'}/g;
    $str =~ s/%%MAINTAINER%%/$$tmpl{'MAINTAINER'}/g;
    $str =~ s/%%PKGSHORTDESCRIPTION%%/$$tmpl{'PKGSHORTDESCRIPTION'}/g;
    $str =~ s/%%PKGDESCRIPTION%%/$$tmpl{'PKGDESCRIPTION'}/g;
    $str =~ s/%%DEPENDENCES%%/$$tmpl{'DEPENDENCES'}/g;
#    $str =~ s/%%PKGOLDNAME%%/$$tmpl{'PKGOLDNAME'}/g;
    $str =~ s/%%DATE%%/$$tmpl{'DATE'}/g;
    $str =~ s/%%FIXPERMS%%/$$tmpl{'FIXPERMS'}/g;
    $str =~ s/%%PATH%%/$$tmpl{'PATH'}/g;
    $str =~ s/%%POSTINST_CONFIGURE%%/$$tmpl{'POSTINST_CONFIGURE'}/g;
    $str =~ s/%%PREINST_INSTALL%%/$$tmpl{'PREINST_INSTALL'}/g;
    $str =~ s/%%CONFFILES%%/$$tmpl{'CONFFILES'}/g;
#    $str =~ s/%%SHLIBS%%/$$tmpl{'SHLIBS'}/g;
    $str =~ s/%%ZONE%%/$$tmpl{'ZONE'}/g;

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
# saveExtfiles
#------------------------------
sub saveExtfiles
{
    my ($nos, $operation) = @_;

    my $output = $nos->getScripts();
    my $templates = &initTemplates();
#    my $moduleName = $nos->getModuleName();
    my $operations = $$output{$operation} if defined($$output{$operation});
#    print join("\n", @$operations) if defined($$output{$operation});
    return unless defined($$output{$operation});

#    my $str = fillTemplate('tmpl/'.$operation.'.tmpl');
    my $str = fillTemplate($$templates{$operation});
    my $file = $$tmpl{'SAVETO'}.'/'.$$tmpl{'PKGNAME'}.'.'.$operation;
    &saveFinalFile($file, $str);
}

#------------------------------
# saveDepends()
#------------------------------
sub saveDepends
{
    my ($nos) = @_;
}

#------------------------------
# saveFiles()
#------------------------------
sub saveFiles
{
    my ($nos) = @_;

    my $mf = $nos->getManifest();
    return 1 unless defined($$mf{'file'});

    my $r = $$mf{'file'};
    my $moduleName = $nos->getModuleName();

    my $str;
    my $output = {};
    $output = $nos->{_scripts} if (defined($nos->{_scripts}));

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

    my @buff;
    my @buffperm;
    my $file = $$tmpl{'SAVETO'}.'/'.$moduleName.".install";
    my $fileperm = $$tmpl{'SAVETO'}.'/'.$moduleName.".files.fixperm";

    foreach my $line (@$r)
    {
        my $preserve = $$line{'preserve'}[0] if defined($$line{'preserve'});
        my $restart_fmri = $$line{'restart_fmri'}[0] if defined($$line{'restart_fmri'});

        my $group = defined($$line{'group'}) ? $$line{'group'}[0] : 'root';
        my $mode = defined($$line{'mode'}) ? $$line{'mode'}[0] : '0644';
        my $owner = defined($$line{'owner'}) ? $$line{'owner'}[0] : 'root';

        my $path = $$line{'path'}[0]; # if defined($$line{'path'});
        
        next if ($path =~ /etc\/motd/); # use etc/motd from base-files package
        $mode = '0755' if ($path =~ /.*\.so.*/); # fix shared libs attribute

        if (defined($$line{'preserve'}) && $preserve eq 'true')
        {
            push(@$conffiles, "$path");
        }
        
        if (defined($$line{'variant.opensolaris.zone'}) && scalar(@$zone) < 1)
        {
            push(@$zone, $$line{'variant.opensolaris.zone'}[0]);
            next if ($path eq '_fakeGlobalZone_');
        }

        if (defined($restart_fmri))
        {
            unless(defined($$svcChk{"$restart_fmri"}))
            {
                $$svcChk{"$restart_fmri"} = 1;
#                push(@$postinst, "if [ \"\$BASEDIR\" = \"/\" ]; then");
                push(@$postinst, "svcadm restart $restart_fmri");
#                push(@$postinst, "fi");
            }
        }

        push(@buff, "$path");
        
        push(@$fixperms, "chmod $mode \$DEST/$path");
        push(@$fixperms, "chown $owner:$group \$DEST/$path");
    }
    return 1 if (scalar(@buff) < 1);
    &saveFinalFile($file, join("\n", @buff));

#    $str = "";
#    push (@$postinst, $str) if (scalar(@$postinst) > 0);
    

    if ($moduleName eq 'system-library')
    {
        push (@$preinst, "mount | grep -c /lib/libc.so.1 >/dev/null && umount /lib/libc.so.1");
    }

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);
    $$output{'preinst'} = $preinst if (scalar(@$preinst) > 0);
    $$output{'postrm'} = $postrm if (scalar(@$postrm) > 0);
    $$output{'prerm'} = $prerm if (scalar(@$prerm) > 0);
    $$output{'conffiles'} = $conffiles if (scalar(@$conffiles) > 0);
    $$output{'fixperms'} = $fixperms if (scalar(@$fixperms) > 0);
    $$output{'zone'} = $zone if (scalar(@$zone) > 0);

    $nos->{_scripts} = $output;
    return 0;
}


#------------------------------
# saveDirs()
#------------------------------
sub saveDirs
{
    my ($nos) = @_;

    my $mf = $nos->getManifest();
    return 1 unless defined($$mf{'dir'});
    
    my $r = $$mf{'dir'};
    my $moduleName = $nos->getModuleName();

    my $str;
    my $output = {};
    $output = $nos->{_scripts} if (defined($nos->{_scripts}));

    my $fixperms = [];

    $fixperms = $$output{'fixperms'} if (defined($$output{'fixperms'}));

    my @buff;
    my @buffperm;
    my $file = $$tmpl{'SAVETO'}.'/'.$moduleName.".dirs";
#    my $fileperm = $$tmpl{'SAVETO'}.'/'.$moduleName.".dirs.fixperm";
    foreach my $line (@$r)
    {
        my $group = defined($$line{'group'}) ? $$line{'group'}[0] : 'root';
        my $mode = defined($$line{'mode'}) ? $$line{'mode'}[0] : '0755';
        my $owner = defined($$line{'owner'}) ? $$line{'owner'}[0] : 'root';

        my $path = $$line{'path'}[0];

        push(@buff, "$path");
        
        push(@buffperm, "chmod $mode \$DEST/$path");
        push(@buffperm, "chown $owner:$group \$DEST/$path");

        push(@$fixperms, "chmod $mode \$DEST/$path");
        push(@$fixperms, "chown $owner:$group \$DEST/$path");
    }
    return 1 if (scalar(@buff) < 1);
    &saveFinalFile($file, join("\n", @buff));
#    &saveFinalFile($fileperm, join("\n", @buffperm));

    $$output{'fixperms'} = $fixperms if (scalar(@$fixperms) > 0);
    $nos->{_scripts} = $output;
    return 0;
}


#------------------------------
# saveLinks
#------------------------------
sub saveLinks
{
    my ($nos) = @_;

    my $mf = $nos->getManifest();
    return 1 unless defined($$mf{'link'});

    my $r = $$mf{'link'};
    my $moduleName = $nos->getModuleName();
    my $str;
    my $output = {};
    $output = $nos->{_scripts} if (defined($nos->{_scripts}));

    my $postinst = [];
    my $fixperms = [];

    $postinst = $$output{'postinst'} if (defined($$output{'postinst'}));
    $fixperms = $$output{'fixperms'} if (defined($$output{'fixperms'}));

#    my $file = $$tmpl{'SAVETO'}.'/'.$nos->getModuleName().".links";
    my @buff;
    foreach my $line (@$r)
    {
        my $path = $$line{'path'}[0];
        my $target = $$line{'target'}[0];
#        push(@buff, "$target $path");

        my $dir;
        if ($moduleName eq 'sunwcsd')
        {
            $dir = dirname("$path");
            $str = "mkdir -p \$BASEDIR/$dir";
            push (@$postinst, $str);
            $str = "test -h \$BASEDIR/$path || /usr/bin/ln -f -s $target \$BASEDIR/$path";
            push (@$postinst, $str);
        }
        else
        {
            $dir = dirname("$path");
            $str = "mkdir -p \$DEST/$dir";
            push (@$fixperms, $str);
            $str = "/usr/bin/ln -f -s $target \$DEST/$path";
            push (@$fixperms, $str);
        }
    }
#    &saveFinalFile($file, join("\n", @buff));

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);
    $$output{'fixperms'} = $fixperms if (scalar(@$fixperms) > 0);

    $nos->{_scripts} = $output;
    return 0;
}


#------------------------------
# saveHardLinks
#------------------------------
sub saveHardLinks
{
    my ($nos) = @_;

    my $mf = $nos->getManifest();
    return 1 unless defined($$mf{'hardlink'});

    my $r = $$mf{'hardlink'};
    my $moduleName = $nos->getModuleName();
    my $str;
    my $output = {};
    $output = $nos->{_scripts} if (defined($nos->{_scripts}));

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

    foreach my $line (@$r)
    {
        my $path = $$line{'path'}[0];
        my $target = $$line{'target'}[0];
        my $destDir = dirname($path);
        my $destFile = basename($path);

        if ($moduleName eq 'sunwcs')
        {
            $str = "mkdir -p \$DEST/$destDir";
            push (@$fixperms, $str);
            $str = "cd \$DEST/$destDir && /usr/bin/ln -f $target $destFile";
            push (@$fixperms, $str);
        }
        else
        {
            $str = "mkdir -p \$BASEDIR/$destDir";
            push (@$postinst, $str);
            $str = "test -e \$BASEDIR/$path || (cd \$BASEDIR/$destDir && /usr/bin/ln -f $target $destFile)";
            push (@$postinst, $str);
        }
    }

#    $str = "";
#    push (@$postinst, $str) if (scalar(@$postinst) > 0);

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);
    $$output{'preinst'} = $preinst if (scalar(@$preinst) > 0);
    $$output{'postrm'} = $postrm if (scalar(@$postrm) > 0);
    $$output{'prerm'} = $prerm if (scalar(@$prerm) > 0);
    $$output{'fixperms'} = $fixperms if (scalar(@$fixperms) > 0);

    $nos->{_scripts} = $output;
    return 0;
}

#------------------------------
# saveDrivers
#------------------------------
sub saveDrivers
{
    my ($nos) = @_;

    my $mf = $nos->getManifest();
    return 1 unless defined($$mf{'driver'});
    my $r = $$mf{'driver'};

    my $str;
    my $output = {};
    $output = $nos->{_scripts} if (defined($nos->{_scripts}));

    my $postinst = [];
    my $preinst = [];
    my $postrm = [];
    my $prerm = [];

    $postinst = $$output{'postinst'} if (defined($$output{'postinst'}));
    $preinst = $$output{'preinst'} if (defined($$output{'preinst'}));
    $postrm = $$output{'postrm'} if (defined($$output{'postrm'}));
    $prerm = $$output{'prerm'} if (defined($$output{'prerm'}));

#    local *FILE;
#    open (FILE, ">", $nos->getModuleName().".drivers");
    foreach my $line (@$r)
    {
        my $name = $$line{'name'}[0] if defined($$line{'name'});
        my $privs = $$line{'privs'}[0] if defined($$line{'privs'});
        my $policy = $$line{'policy'}[0] if defined($$line{'policy'});
        my $devlink = $$line{'devlink'}[0] if defined($$line{'devlink'});

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
                $perms =~ s/"/'/g;
                $OPTIONS .= " -m $perms";
            }
        }

        $policy =~ s/"/'/g if defined($policy);
        $OPTIONS .= " -p $policy" if defined($policy);

        $str = "grep -c \"^$name \" \$BASEDIR/etc/name_to_major >/dev/null || $drv \$BASEDIR_OPT $OPTIONS $name";
        push (@$postinst, $str);

        if (defined($originalClonePerm))
        {
            $drv = 'update_drv -a -n ';

            $perms = '';
            $OPTIONS = '';
            $OPTIONS .= " -P $privs" if defined($$line{'privs'});
            $OPTIONS .= " -i '$alias'" if (defined($$line{'alias'}) && ! defined($$line{'perms'}));
            $OPTIONS .= " -c '$class'" if (defined($$line{'class'}) && ! defined($$line{'perms'}));;

            if ($originalClonePerm)
            {
                $policy =~ s/"/'/g if defined($policy);
                $OPTIONS .= " -p $policy" if defined($policy);

                foreach $perms (@$originalClonePerm)
                {
                    $perms =~ s/"/'/g;

                    $str = "grep -c \"$perms\" \$BASEDIR/etc/minor_perm >/dev/null|| $drv \$BASEDIR_OPT $OPTIONS -m $perms clone";
                    push (@$postinst, $str);
                }
            }
        }

        if(defined($devlink))
        {
            $devlink =~ s/\\t/\t/g;
            $str = "grep -c \"$devlink\" \$BASEDIR/etc/devlink.tab >/dev/null || echo \"$devlink\" >> \$BASEDIR/etc/devlink.tab";
            push (@$postinst, $str);
        }
    }
#    close (FILE);

    $str = "";
    push (@$postinst, $str) if (scalar(@$postinst) > 0);

    $$output{'postinst'} = $postinst if (scalar(@$postinst) > 0);
    $$output{'preinst'} = $preinst if (scalar(@$preinst) > 0);
    $$output{'postrm'} = $postrm if (scalar(@$postrm) > 0);
    $$output{'prerm'} = $prerm if (scalar(@$prerm) > 0);

    $nos->{_scripts} = $output;
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

  * Initial release 

 -- %%MAINTAINER%%  %%DATE%%
';

# compat
$$initTemplate{'compat'} = '7';

# conffiles
$$initTemplate{'conffiles'} = '%%CONFFILES%%';

# control
$$initTemplate{'control'} = 'Source: %%PKGNAME%%
Section: base
Priority: optional
Maintainer: %%MAINTAINER%%

Package: %%PKGNAME%%
Architecture: solaris-i386
Depends: %%DEPENDENCES%%
XBS-Zone: %%ZONE%%
Description: %%PKGSHORTDESCRIPTION%%
 %%PKGDESCRIPTION%%
';

# copyright
$$initTemplate{'copyright'} = '
Copyright:

Copyright 2010-2011 Nexenta Systems, Inc.  All rights reserved.
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


# rules
$$initTemplate{'rules'} = '#!/usr/bin/make -f
# -*- makefile -*-
# Sample debian/rules that uses debhelper.
# This file was originally written by Joey Hess and Craig Small.
# As a special exception, when this file is copied by dh-make into a
# dh-make output file, you may use that output file without restriction.
# This special exception was added by Craig Small in version 0.37 of dh-make.

# Uncomment this to turn on verbose mode.
#export DH_VERBOSE=1

GATE := ${BASEGATE}
DEST := $(CURDIR)/debian/%%PKGNAME%%

configure: configure-stamp
configure-stamp:
	dh_testdir
	# Add here commands to configure the package.

	touch configure-stamp


build: build-stamp

build-stamp: configure-stamp 
	dh_testdir

	# Add here commands to compile the package.

	touch $@

clean:
	dh_testdir
	dh_testroot
	rm -f build-stamp configure-stamp

	# Add here commands to clean up after the build process.
#	-$(MAKE) clean

	dh_clean 

install: build
	dh_testdir
	dh_testroot
	dh_clean -k 
	dh_installdirs

	# Add here commands to install the package into debian/tmp.
#	mkdir -p $(CURDIR)/debian/tmp
#	mv proto/* $(CURDIR)/debian/tmp


# Build architecture-independent files here.
binary-indep: build install
# We have nothing to do by default.

# Build architecture-dependent files here.
binary-arch: build install
	dh_testdir
	dh_testroot
	dh_installchangelogs 
#	dh_installdocs
#	dh_installexamples
#	dh_install
	dh_install --sourcedir=$(GATE)/proto/root_i386
	DEST=$(DEST) /bin/sh $(CURDIR)/debian/%%PKGNAME%%.fixperms
#	dh_installmenu
#	dh_installdebconf
#	dh_installlogrotate
#	dh_installemacsen
#	dh_installpam
#	dh_installmime
#	dh_python
#	dh_installinit
#	dh_installcron
#	dh_installinfo
#	dh_installman
#	dh_link
#	dh_strip
	dh_compress
#	dh_fixperms
#	dh_perl
#	dh_makeshlibs -p%%PKGNAME%%
	dh_makeshlibs
	dh_installdeb
#	dh_shlibdeps debian/tmp/lib/* debian/tmp/usr/lib/*
	-dh_shlibdeps
	dh_gencontrol
	dh_md5sums
	dh_builddeb

binary: binary-indep binary-arch
.PHONY: build clean binary-indep binary-arch binary install configure
';


    return $initTemplate;
}
