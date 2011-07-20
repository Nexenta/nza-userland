#!/bin/bash

#Usage: ./fetch-deb-dir.sh
#Author: Kartik Mistry <kartik.mistry@gmail.com>

for i in `cat pkg.lst`
do
  echo "Fetching $i"
  mkdir "$i"
  cd "$i"
  apt-get source "$i"
  cp -r "$i"-*/debian .
  rm -rf "$i"*
  cd ..
done
