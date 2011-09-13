#!/usr/bin/perl -w
use strict;

# Copyright (C) 2005, Stefano Zacchiroli <zack@debian.org>
#
# Created:        Sat, 16 Apr 2005 12:43:04 +0200 zack
# Last-Modified:  $Id$
#
# This is free software, you can redistribute it and/or modify it under the
# terms of the GNU General Public License version 2 as published by the Free
# Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place, Suite 330, Boston, MA  02111-1307  USA

# XXX this script is getting uglier and uglier ... please, rewrite it! :-/

my $usage =
  "Usage:\n" .
  "  debian/vim-scripts.pl { doc | update | test } [ name ...  ]\n" .
  "  debian/vim-scripts.pl copyright > debian/copyright\n" .
  "  debian/vim-scripts.pl registry > debian/vim-registry/vim-registry.yaml\n";
my $action = shift or die $usage;
my $status = "debian/vim-scripts.status";
my @scripts = ();
push @scripts, @ARGV;

sub parse_script_page($) {
  my ($url) = @_;
  my ($in_table, $script_name, $script_version, $script_date, $download_url);
  open HTML, "wget -nv -O - '$url' |" or die "Can't exec wget for pipe-reading";
  while (my $line = <HTML>) {
    next if $script_version and $script_date;
    chomp $line;
    if (not $in_table and $line =~ /<td class="[^"]*" valign="top" nowrap><a href="(download_script\.php\?src_id=\d+)">([^<]+)<\/a><\/td>/) {
      $in_table = 1;
      $download_url = "http://www.vim.org/scripts/$1";
      $script_name = $2;
    } elsif ($in_table and $line =~ /<td class="[^"]*" valign="top" nowrap><b>\s*([^<]+)\s*<\/b><\/td>/) {
      $script_version = $1;
    } elsif ($in_table and $line =~ /<td class="[^"]*" valign="top" nowrap><i>\s*([^<]+)\s*<\/i><\/td>/) {
      $script_date = $1;
    }
  }
  close HTML;
#   print "$script_name\t$script_version\t$script_date\n";
  return [$script_version, $script_date, $download_url];
}

sub rebuild_index() {
  my $date=`date -R`;
  open INDEX, "> html/index.html";
  print INDEX <<EOH;
<html>
 <head>
  <title>vim-scripts - scripts web pages index</title>
 </head>
 <body>
  <h2>vim-scripts - scripts web pages index:</h2>
  <p>
  Below you can find a list pointing to the web pages of the addons shipped in
  the <tt>vim-scripts</tt> package, as they appearead on the
  <a href="http://www.vim.org">Vim Website</a> when the package has been built
  (for the actual date see the bottom of this page).
  </p>
  <ul>
EOH
  open FIND, "find html/ -type f -name '*.html' -printf '\%f\\n' |";
  my @fnames = <FIND>;
  close FIND;
  foreach my $fname (sort @fnames) {
    chomp $fname;
    next if $fname =~ "index.html";
    my $anchor = $fname;
    $anchor =~ s/_/\//;
    print INDEX "   <li><a href=\"$fname\">$anchor</a></li>\n";
  }
  print INDEX <<EOT;
  </ul>
  <p>
  Page generated on $date.
  </p>
 </body>
</html>
EOT
  close INDEX;
}

sub emit_registry($$$$$) {
  my ($addon, $description, $script_name, $extras, $disabledby) = @_;
  return if $addon eq '';
  print "addon: $addon\n";
  print "description: \"$description\"\n";
  print "basedir: /usr/share/vim-scripts/\n";
  print "disabledby: \"$disabledby\"\n" unless $disabledby eq '';
  print "files:\n";
  my @files = ($script_name);
  if ($extras ne '') {
    for my $pat (split(/,\s*/, $extras)) {
      push @files, glob $pat;
    }
  }
  foreach my $file (@files) {
    print "  - $file\n";
  }
  print "---\n";
}

open STATUS, "< $status" or die "Can't open $status";
my ($script_name, $script_url, $author, $author_url, $email, $license, $extras,
  $description, $version, $addon, $disabledby);
my $skip = 1;
$script_name = ''; $extras = ''; $addon = ''; $disabledby = '';
while (my $line = <STATUS>) {
  # assumption: each plugin "block" of lines starts with the "script_name:"
  # field
  chomp $line;
  if ($line =~ /^--\s*$/) {
    $skip = not $skip;
    emit_registry($addon, $description, $script_name, $extras, $disabledby)
      if $skip and $action eq "registry";
  }
  print $line, "\n" if $skip and $action eq "copyright";
  next if $skip;
  if ($line =~ /^script_name:\s*(.*)/) {
    if ($script_name ne '') { # new plugin, process data collected so far
      emit_registry($addon, $description, $script_name, $extras, $disabledby)
	if $action eq "registry";
      $extras = ''; $addon = ''; $disabledby = '';
    }
    $script_name = $1;
  } elsif ($line =~ /^addon:\s*(.*)/) { $addon = $1; }
  elsif ($line =~ /^description:\s*(.*)/) { $description = $1; }
  elsif ($line =~ /^script_url:\s*(.*)/) { $script_url = $1; }
  elsif ($line =~ /^author:\s*(.*)/) { $author = $1; }
  elsif ($line =~ /^author_url:\s*(.*)/) { $author_url = $1; }
  elsif ($line =~ /^email:\s*(.*)/) { $email = $1; }
  elsif ($line =~ /^license:\s*(.*)/) { $license = $1; }
  elsif ($line =~ /^extras:\s*(.*)/) { $extras = $1; }
  elsif ($line =~ /^disabledby:\s*(.*)/) { $disabledby = $1; }
  elsif ($line =~ /^version:\s*(.*)/) {
    $version = $1;
    if (not @scripts or grep /^\Q$script_name\E$/, @scripts) {
      if ($action eq "test") {
        print $script_name, "\n";
      } elsif ($action eq "doc" and $script_url) {
        my $fname = $script_name;
        $fname =~ s/\//_/g;
        system "wget -nv -O html/$fname.html '$script_url'";
      } elsif ($action eq "update" and $script_url) {
        my ($upstream_version, $upstream_date, $download_url) =
          @{parse_script_page($script_url)};
        if (not ($upstream_version eq $version)) {
          print <<EOMSG;
$script_name may be out of date:
  debian version: $version
  upstream version: $upstream_version
    release date: $upstream_date
  script url: $script_url
  download url: $download_url
EOMSG
        }
      } elsif ($action eq "copyright") {
	print <<EOP;
script:  $script_name
author:  $author < $email >
url:	 $script_url
license: $license

EOP
      }
    }
  }
  rebuild_index() if ($action eq "doc");
}
close STATUS;

