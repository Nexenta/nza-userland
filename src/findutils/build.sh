#!/bin/sh

# build script for findutils

WEBARCHIVE_PATH="http://apt.nexenta.org/wip/dists/siddy-unstable/main/source/utils"

PKGNAME="findutils"
PKGVER="4.4.2"
PKGARCH="$PKGNAME"_"$PKGVER".orig.tar.gz

mkdir build && cd build && wget $WEBARCHIVE_PATH/$PKGARCH

tar xzvf $PKGARCH --exclude "debian" 

cp -r ../debian $PKGNAME-$PKGVER/

cd $PKGNAME-$PKGVER && dpkg-buildpackage -sa -uc -us
