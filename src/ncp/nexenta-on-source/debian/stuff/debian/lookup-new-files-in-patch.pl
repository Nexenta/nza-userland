#!/usr/bin/perl -w

if (!$ARGV[0]) {
	die "Usage: $0 <file>\n";
}

if (!open(FD, $ARGV[0])) {
	die "Cannot open file '$ARGV[0]': $!\n";
}
my @lines = <FD>;
close FD;

my $found = 0;
for my $line (@lines) {
	if (!$found && $line =~ /--- \/dev\/null/) {
		$found = 1;
	} elsif ($found && $line =~ /\+\+\+ b\/(\S+)\s+/) {
		print "$1\n";
		$found = 0;
	}
}
