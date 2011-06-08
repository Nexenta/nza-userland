#!/bin/sh

# build script for apt

WEBARCHIVE_PATH="http://apt.nexenta.org/wip/dists/siddy-testing/main/source/admin/"

PKGNAME="apt_0.8.0"
PKGARCH="$PKGNAME""nexenta8".tar.gz
PKGDSC="$PKGNAME""nexenta8.dsc"


cd build && wget $WEBARCHIVE_PATH/$PKGARCH
wget $WEBARCHIVE_PATH/$PKGDSC

tar xzvf $PKGARCH --exclude "debian" 

cp -r ../debian apt-0.8.0/

cd apt-0.8.0 && dpkg-buildpackage -sa -uc -us