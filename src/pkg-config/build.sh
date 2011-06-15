#!/bin/sh

# build script for pkg-config

WEBARCHIVE_PATH="http://apt.nexenta.org/wip/dists/siddy-testing/main/source/devel"

PKGNAME="pkg-config"
PKGVER="0.25"
PKGARCH="$PKGNAME"_"$PKGVER".orig.tar.gz

mkdir build && cd build && wget $WEBARCHIVE_PATH/$PKGARCH

tar xzvf $PKGARCH --exclude "debian" 

cp -r ../debian $PKGNAME-$PKGVER/

cd $PKGNAME-$PKGVER && dpkg-buildpackage -sa -uc -us
