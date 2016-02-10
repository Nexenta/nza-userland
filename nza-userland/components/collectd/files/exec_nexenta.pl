#!/usr/bin/perl
#
# exec_nexenta.pl
#
# Nexenta collectd EXEC script.
#
# Copyright (c) 2016  Nexenta Systems
# William Kettler <william.kettler@nexenta.com>
#
# Version 0.2.0
# January 4, 2016
#

use strict;
use warnings;
use Sun::Solaris::Kstat;
use Getopt::Long;
use Pod::Usage;
use Time::HiRes qw(gettimeofday tv_interval usleep);

# Ubuffered stdout
$| = 1;

# Initialize command line args
my $interval = 0;
my %opts     = (
    'interval' => \$interval
);

# Initialize globals
my %lus      = ();

# Parse command line args
GetOptions (\%opts, "help|h", "man", "cpu", "mem", "net", "stmf", "arc",
            "zpool", "disk", "nfsv3", "nfsv4", "all", "interval=i")
or pod2usage(2);

# Print documentation if required
pod2usage(-verbose => 0, -noperldoc => 1, -exit => 0) if $opts{"help"};
pod2usage(-verbose => 3, -noperldoc => 1, -exit => 0) if $opts{"man"};
pod2usage("At least one stat must be enabled") if (keys %opts == 1);

# Define the polling interval
if (!$interval) {
    if (defined $ENV{'COLLECTD_INTERVAL'}) {
        $interval = int($ENV{'COLLECTD_INTERVAL'});
    } else {
        $interval = 10;
    }
}
my $uinterval = $interval * 1000000;

# Get constants for memory statistics
my $pagesz = get_pagesz();

# Initialize global kstat
my $kstat = Sun::Solaris::Kstat->new();

while (1) {
    my $start = [gettimeofday];

    # Update kstats
    $kstat->update();

    # Put ktats
    put_cpu()   if ($opts{"cpu"}   || $opts{"all"});
    put_mem()   if ($opts{"mem"}   || $opts{"all"});
    put_net()   if ($opts{"net"}   || $opts{"all"});
    put_stmf()  if ($opts{"stmf"}  || $opts{"all"});
    put_arc()   if ($opts{"arc"}   || $opts{"all"});
    put_zpool() if ($opts{"zpool"} || $opts{"all"});
    put_disk()  if ($opts{"disk"}  || $opts{"all"});
    put_nfsv3() if ($opts{"nfsv3"} || $opts{"all"});
    put_nfsv4() if ($opts{"nfsv4"} || $opts{"all"});

    usleep($uinterval - tv_interval($start));
}

sub putval {
    #
    # PUTVAL, collectd EXEC plaintext protocol
    #
    my ($category, $name, $type, $key, $interval, $value) = @_;
    print "PUTVAL \"$category/$name/$type-$key\" interval=$interval ",
        "N:$value\n";
}

sub put_cpu {
    #
    # Write CPU kstats
    #
    my $category = "cpu";
    my $module   = "cpu_stat";
    my $type     = "gauge";
    my @keys     = ("user", "kernel", "wait", "idle", "xcalls");

    # Iterate over each cpu instance
    for my $instance (keys %{$kstat->{$module}}) {
        my $name = "cpu_stat$instance";
        # Iterate over each defined kstat
        for (@keys) {
            # Read kstat and write value
            my $value = ${kstat}->{$module}{$instance}{$name}{$_};
            putval($category, $name, $type, $_, $interval, $value);
        }
    }
}

sub get_pagesz {
    #
    # Determine memory page size in MB
    #
    chomp(my $pgsz = `pagesize`);

    return $pgsz;
}

sub put_mem {
    #
    # Write memory kstats
    # http://www.brendangregg.com/K9Toolkit/swapinfo
    #
    my $category = "memory";
    my $alias    = "physical";
    my $module   = "unix";
    my $instance = 0;
    my $name     = "system_pages";
    my $type     = "gauge";
    my @keys     = ("freemem", "availrmem", "pageslocked", "pagestotal",
                    "pp_kernel", "physmem");
    my %stats    = ();
    my %mem      = ();

    # Iterate over each defined kstat
    for (@keys) {
        # Read kstat and write value
        my $value = ${kstat}->{$module}->{$instance}->{$name}->{$_};
        $stats{$_} = $value;
    }

    $mem{"total"} = $stats{"physmem"};
    if ($stats{"pp_kernel"} < $stats{"pageslocked"}) {
    	# Here we assume all pp_kernel pages are in memory
    	$mem{"kernel"} = $stats{"pp_kernel"};
    	$mem{"locked"} = $stats{"pageslocked"} - $stats{"pp_kernel"};
    } else {
    	# Here we assume pageslocked is entirely kernel
    	$mem{"kernel"} = $stats{"pageslocked"};
    	$mem{"locked"} = 0;
    }
    $mem{"used"} = $stats{"pagestotal"} - $stats{"freemem"} - $mem{"kernel"} -
        $mem{"locked"};

    while (my ($k, $v) = each(%mem)) {
        putval($category, $alias, $type, $k, $interval, $v * $pagesz);
    }
}

sub put_net {
    #
    # Write network kstats
    #
    my $category = "network";
    my $module   = "link";
    my $instance = 0;
    my $type     = "gauge";
    my @keys     = ("obytes", "rbytes", "opackets", "ipackets", "oerrors",
                    "ierrors");

    # Iterate over each network interface
    for my $name (keys %{$kstat->{$module}->{$instance}}) {
        # Iterate over each defined kstat
        for (@keys) {
            # Read kstat and write value
            my $value = ${kstat}->{$module}{$instance}{$name}{$_};
            putval($category, $name, $type, $_, $interval, $value);
        }
    }
}

sub put_stmf {
    #
    # Write STMF kstats
    #
    my $category = "stmf";
    my $module   = "stmf";
    my $instance = 0;
    my $type     = "gauge";
    my $alias    = '';
    my $id       = '';

    # Return if STMF isn't in use
    return if (!exists $kstat->{$module});

    # Iterate over LUs
    for my $name (keys %{$kstat->{$module}{$instance}}) {
        # If we already have a key set the alias
        if (exists($lus{$name})) {
            $alias = $lus{$name};
        # If we are stmf_lu_io_* get the lun-alias
        } elsif (index($name, "stmf_lu_io") != -1) {
            $id = (split("_", $name))[-1];
            $alias = $kstat->{$module}{$instance}{"stmf_lu_$id"}{"lun-alias"};
            $alias = (split("/", $alias, 5))[-1];
            $alias =~ s/\//_/g;
            $lus{$name} = $alias;
        # If we are stmf_tgt_io_* get the target-name
        } elsif (index($name, "stmf_tgt_io") != -1) {
            $id = (split("_", $name))[-1];
            $alias = $kstat->{$module}{$instance}{"stmf_tgt_$id"}{"target-name"};
            $alias =~ s/\./_/g;
            $lus{$name} = $alias;
        } else {
            next;
        }

        # Iterate over every kstat
        while (my ($k, $v) = each(%{$kstat->{$module}{$instance}{$name}})) {
            next if ($k eq "crtime" || $k eq "snaptime" || $k eq "class");
            putval($category, $alias, $type, $k, $interval, $v);
        }
    }
}

sub put_arc {
    #
    # Write ARC kstats
    #
    my $category = "zfs";
    my $module   = "zfs";
    my $instance = 0;
    my $name     = "arcstats";
    my $type     = "gauge";

    # Iterate over each defined kstat
    while (my ($k, $v) = each(%{$kstat->{$module}{$instance}{$name}})) {
        next if ($k eq "crtime" || $k eq "snaptime" || $k eq "class");
        putval($category, $name, $type, $k, $interval, $v);
    }
}

sub put_zpool {
    #
    # Write ZFS kstats
    #
    my $category = "zfs";
    my $module   = "zfs";
    my $instance = 0;
    my $type     = "gauge";

    # Iterate over each defined kstat
    while (my $name = each(%{$kstat->{$module}{$instance}})) {
        next if ($kstat->{$module}{$instance}{$name}{"class"} ne "disk");
        while (my ($k, $v) = each(%{$kstat->{$module}{$instance}{$name}})) {
            next if ($k eq "crtime" || $k eq "snaptime" || $k eq "class");
            putval($category, $name, $type, $k, $interval, $v);
        }
    }
}

sub put_disk {
    #
    # Write disk kstats
    #
    my $category = "disk";
    my $module = "sd";
    my $type   = "gauge";
    my @keys = ("nread", "reads", "rlastupdate", "rlentime", "rtime", "writes",
                "nwritten", "wlastupdate", "wlentime", "wtime");

    # Iterate over each sd instance
    for my $instance (keys %{$kstat->{$module}}) {
        my $name = "sd$instance";
        # Iterate over each defined kstat
        for (@keys) {
            # Read kstat and write value
            my $value = ${kstat}->{$module}->{$instance}->{$name}->{$_};
            putval($category, $name, $type, $_, $interval, $value);
        }
    }
}

sub put_nfsv3 {
    #
    # Write NFSv3 kstats
    #
    my $category = "nfs";
    my $alias    = "nfsv3";
    my $module   = "nfs";
    my $instance = 0;
    my $name     = "rfsproccnt_v3";
    my $type     = "gauge";

    # Iterate over each defined kstat
    while (my ($k, $v) = each(%{$kstat->{$module}{$instance}{$name}})) {
        next if ($k eq "crtime" || $k eq "snaptime" || $k eq "class");
        putval($category, $alias, $type, $k, $interval, $v);
    }
}

sub put_nfsv4 {
    #
    # Write NFSv4 kstats
    #
    my $category = "nfs";
    my $alias    = "nfsv4";
    my $module   = "nfs";
    my $instance = 0;
    my $name     = "rfsproccnt_v4";
    my $type     = "gauge";

    # Iterate over each defined kstat
    while (my ($k, $v) = each(%{$kstat->{$module}{$instance}{$name}})) {
        next if ($k eq "crtime" || $k eq "snaptime" || $k eq "class");
        putval($category, $alias, $type, $k, $interval, $v);
    }
}

__END__

=head1 NAME

exec_nexenta.pl - Nexenta kstat to collectd EXEC script

=head1 SYNOPSIS

exec_collectd.pl [options]

 Options:

   -help|-h        Print usage
   -man            Print man page
   -cpu            Enable CPU kstats
   -mem            Enable memory kstats
   -net            Enable network interface kstats
   -stmf           Enable STMF kstats
   -arc            Enable ARC kstats
   -zpool          Enable zpool kstats
   -disk           Enable disk kstats
   -nfsv3          Enable NFSv3 kstats
   -nfsv4          Enable NFSv4 kstats
   -all            Enable all kstats
   -interval=t     Define the polling interval in seconds

=head1 OPTIONS

=over 4

=item B<-help|-h>

Prints a brief help message and exits.

=item B<-man>

Prints the man page and exits.

=item B<-cpu>

Enables CPU kstats.

#> kstat cpu_stat:::{user,kernel,wait,idle,xcalls}

=item B<-mem>

Enables memory kstats.

#> kstat unix::system_pages:{freemem,availrmem,pageslocked,pagestotal,\
pp_kernel,physmem,pagestotal}

=item B<-net>

Enables network interface kstats.

#> kstat link:::{obytes,rbytes,opackets,ipackets,oerrorsierrors}

=item B<-stmf>

Enables STMF kstats.

#> kstat stmf::stmf_*_io*

=item B<-arc>

Enables ARC kstats.

#> kstat zfs::arcstats

=item B<-zpool>

Enables zpool kstats.

#> kstat -c disk zfs

=item B<-disk>

Enables disk kstats.

#> kstat -c disk sd:::{nread,reads,rlastupdate,rlentime,rtime,\
writes,nwritten,wlastupdate,wlentime,wtime}

=item B<-nfsv3>

Enables NFSv3 kstats.

#> kstat nfs:0:rfsproccnt_v3

=item B<-nfsv4>

Enables NFSv4 kstats.

#> kstat nfs:0:rfsproccnt_v4

=item B<-all>

Enable all kstats.

=item B<-interval=i>

Define the kstat polling interval in seconds. If no interval is specified the
COLLECTD_INTERVAL environment variable is read if defined otherwise 10s is
used.

=back

=head1 DESCRIPTION

B<This program> will read Nexenta kernel statistics and write values to
collectd using the EXEC plain text protocol.

=cut
