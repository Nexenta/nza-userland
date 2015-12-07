#!/usr/bin/perl
#
# exec_iostat.pl
#
# collectd EXEC script that monitors iostat statistics.
# http://sunsite.uakom.sk/sunworldonline/swol-09-1997/swol-09-perf.html
#
# Copyright (c) 2015  Nexenta Systems
# William Kettler <william.kettler@nexenta.com>
#

use strict;
use warnings;
use Sys::Hostname;
use Sun::Solaris::Kstat;

# Ubuffered stdout
$| = 1;

# Variable declerations
my $host     = '';
my $interval = 0;

# kstats
my $module = "sd";
my %kstats = (
    "nread"       => "derive",
    "reads"       => "derive",
    "rlastupdate" => "derive",
    "rlentime"    => "derive",
    "rtime"       => "derive",
    "writes"      => "derive",
    "nwritten"    => "derive",
    "wlastupdate" => "derive",
    "wlentime"    => "derive",
    "wtime"       => "derive"
);

# Define the system hostname
if (defined $ENV{'COLLECTD_HOSTNAME'}) {
    $host = $ENV{'COLLECTD_HOSTNAME'};
} else {
    $host = hostname;
}

# Define the polling interval
if (defined $ENV{'COLLECTD_INTERVAL'}) {
    $interval = int($ENV{'COLLECTD_INTERVAL'});
} else {
    $interval = 10;
}

# Initialize kstats
my $kstat = Sun::Solaris::Kstat->new();

while (1) {
    # Update kstats
    $kstat->update();

    # Iterate over each sd instance
    for my $instance ( keys %{$kstat->{$module}} ) {
        my $name = "sd$instance";
        # Iterate over each defined kstat
        while ( my ($stat, $type) = each(%kstats) ) {
            # Read kstat and write value
            my $value   = ${kstat}->{$module}->{$instance}->{$name}->{$stat};
            print "PUTVAL \"$host/$name/$type-$stat\" interval=$interval ",
                "N:$value\n";
        }
    }

    # Sleep
    sleep $interval;
}
