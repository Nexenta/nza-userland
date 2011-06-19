#!/bin/sh

set -e

# build script for apt

WEBARCHIVE_PATH="http://ftp.fi.debian.org/debian/pool/main/a/apt"

PKGNAME=apt
PKGVERS=0.8.10.3+squeeze1
PKGARCH="$PKGNAME"_"$PKGVERS.tar.gz"
PKGORIG="$PKGNAME"_"$PKGVERS.orig.tar.bz2"
PKGDSC="$PKGNAME"_"$PKGVERS.dsc"
PKGDIR="$PKGNAME-$PKGVERS"

if [ -d build ]; then
  echo "Removing old build dir"
  rm -rf build
fi

mkdir -p build cache && cd cache

  echo "Downloading $PKGORIG ...\c"
  echo $WEBARCHIVE_PATH/$PKGACH
  wget -q -c $WEBARCHIVE_PATH/$PKGARCH
  echo " done"

  echo "Downloading $PKGDSC ...\c"
  wget -q -c $WEBARCHIVE_PATH/$PKGDSC
  echo " done"

cd ../build

if [ -f "../cache/$PKGORIG" ]; then
  echo "Unpacking $PKGORIG ...\c"
  tar -xf "../cache/$PKGORIG"
  echo " done"
else
  echo "Unpacking $PKGARCH ...\c"
  tar -xf "../cache/$PKGARCH" --exclude "debian"
  echo " done"
  echo "Creating $PKGORIG ...\c"
  tar -cjf "../cache/$PKGORIG" "$PKGDIR"
  echo " done"
fi

echo "Applying our changes ...\c"
cp "../cache/$PKGORIG" .
cp -r ../debian "$PKGDIR/" && cd "$PKGDIR"

QUILT_PATCHES=debian/patches quilt push -a
echo " done"

DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -sa -uc -us
