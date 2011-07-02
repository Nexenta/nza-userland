#!/bin/sh

set -e

# build script for pkg-config

WEBARCHIVE_PATH="http://ftp.fi.debian.org/debian/pool/main/p/pkg-config"

PKGNAME="pkg-config"
PKGVERS="0.25"

PKGORIG="$PKGNAME"_"$PKGVERS.orig.tar.gz"
PKGDSC="$PKGNAME"_"$PKGVERS"-"1.1.dsc"
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
  tar -xzf "../cache/$PKGORIG"
  echo " done"

echo "Applying our changes ...\c"
cp "../cache/$PKGORIG" .
cp -r ../debian "$PKGDIR/" && cd "$PKGDIR"

echo " done"

DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -sa -uc -us
