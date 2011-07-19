#!/bin/sh

#Usage: ./version.sh PACKAGENAME
#You must be in top level directory of packaging repo.
#
#Author: Kartik Mistry <kartik.mistry@nexenta.com>
#
#To Do: Use sane ways to determine siddy versions.

for i in $*
do

 cd packaging/src/$i
 HGVER=`dpkg-parsechangelog --count 1 | grep "Version:"`
 SQUVER=`rmadison -s squeeze $i | cut -d "|" -f 2`
 SIDVER1=`apt-cache show $i|grep -s Filename:|cut -d "/" -f 6|cut -d "_" -f 2|head -1`
 SIDVER2=`apt-cache show $i|grep -s Filename:|cut -d "/" -f 6|cut -d "_" -f 2|tail -1`

 echo "$i has following versions:"
 echo "HG repo is at: $HGVER"
 echo "Squeeze is at:$SQUVER"
 echo "Siddy-testing is at:" $SIDVER1
 echo "Siddy-unstable is at:" $SIDVER2
 echo "-------------------------------"

 cd -

done
