#!/bin/sh

#Usage: ./version.sh PACKAGENAME
#You must be in top level directory of packaging repo.
#
#Author: Kartik Mistry <kartik.mistry@nexenta.com>
#
#To Do: Use sane ways to determine siddy versions.

cd packaging/src/$1
HGVER=`dpkg-parsechangelog --count 1 | grep "Version:"`
SQUVER=`rmadison -s squeeze $1 | cut -d "|" -f 2`
SIDVER1=`apt-cache show $1|grep -s Filename:|cut -d "/" -f 6|cut -d "_" -f 2|head -1`
SIDVER2=`apt-cache show $1|grep -s Filename:|cut -d "/" -f 6|cut -d "_" -f 2|tail -1`

echo "$1 has following versions:"
echo "HG repo is at: $HGVER"
echo "Squeeze is at:$SQUVER"
echo "Siddy-testing is at:" $SIDVER1
echo "Siddy-unstable is at:" $SIDVER2
