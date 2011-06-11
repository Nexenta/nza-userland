#!/bin/sh

set -e

# build script for dpkg

WEBARCHIVE_PATH="http://ftp.uk.debian.org/debian/pool/main/d/dpkg/"

PKGNAME=dpkg
PKGVERS=1.15.8.10
PKGARCH="$PKGNAME"_"$PKGVERS.tar.bz2"
PKGDSC="$PKGNAME"_"$PKGVERS.dsc"

mkdir -p build && cd build
wget -c $WEBARCHIVE_PATH/$PKGARCH
wget -c $WEBARCHIVE_PATH/$PKGDSC

tar -xvf "$PKGARCH" --exclude "debian" 

cp -r ../debian "$PKGNAME-$PKGVERS/"

cd "$PKGNAME-$PKGVERS" && dpkg-buildpackage -sa -uc -us
