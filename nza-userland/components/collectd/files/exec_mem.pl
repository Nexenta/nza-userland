#!/usr/bin/perl
#
# exec_mem.pl
#
# collectd EXEC script that monitors memory statistics.
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
my $module   = "unix";
my $instance = 0;
my $name = "system_pages";
my %kstats = (
    "freemem"     => "gauge",
    "availrmem"   => "gauge",
    "pageslocked" => "gauge",
    "pagestotal"  => "gauge",
    "pp_kernel"   => "gauge",
    "physmem"     => "gauge",
    "pagestotal"  => "gauge"
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

    # Iterate over each defined kstat
    while ( my ($stat, $type) = each(%kstats) ) {
        # Read kstat and write value
        my $value   = ${kstat}->{$module}->{$instance}->{$name}->{$stat};
        print "PUTVAL \"$host/$name/$type-$stat\" interval=$interval ",
            "N:$value\n";
    }

    # Sleep
    sleep $interval;
}
