#!/usr/bin/perl
#
# exec_sderr.pl
#
# collectd EXEC script that monitors sderr statistics.
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
my $module = "sderr";
my %kstats = (
    "Device Not Ready" => "gauge",
    "Hard Errors"      => "gauge",
    "Illegal Request"  => "gauge",
    "Media Error"      => "gauge",
    "No Device"        => "gauge",
    "Recoverable"      => "gauge",
    "Soft Errors"      => "gauge",
    "Transport Errors" => "gauge"
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
        my $name = "sd$instance,err";
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
