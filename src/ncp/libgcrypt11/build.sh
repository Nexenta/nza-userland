#!/bin/sh

set -e

# build script for dpkg

WEBARCHIVE_PATH="http://ftp.fi.debian.org/debian/pool/main/libg/libgcrypt11"

PKGNAME=libgcrypt
PKGVERS=1.4.6
PKGORIG="$PKGNAME"11_"$PKGVERS.orig.tar.bz2"
PKGDSC="$PKGNAME"11_"$PKGVERS-5.dsc"
PKGDIR="$PKGNAME-$PKGVERS"

if [ -d build ]; then
  echo "Removing old build dir"
  rm -rf build
fi

mkdir -p build cache && cd cache

  echo "Downloading $PKGORIG ...\c"
  echo $WEBARCHIVE_PATH/$PKGORIG
  wget -q -c $WEBARCHIVE_PATH/$PKGORIG
  echo " done"

  echo "Downloading $PKGDSC ...\c"
  wget -q -c $WEBARCHIVE_PATH/$PKGDSC
  echo " done"

cd ../build

  echo "Unpacking $PKGORIG ...\c"
  tar -xjf "../cache/$PKGORIG"
  echo " done"

echo "Applying our changes ...\c"
cp "../cache/$PKGORIG" .
cp -r ../debian "$PKGDIR/" && cd "$PKGDIR"

QUILT_PATCHES=debian/patches quilt push -a
echo " done"

DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -sa -uc -us
