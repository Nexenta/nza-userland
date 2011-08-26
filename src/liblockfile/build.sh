#!/bin/sh

set -e

WEBARCHIVE_PATH="http://ftp.de.debian.org/debian/pool/main/libl/liblockfile"


PKGNAME=liblockfile
PKGVERS=1.08
PKGARCH="$PKGNAME"_"$PKGVERS.tar.gz"
PKGORIG="$PKGNAME"_"$PKGVERS.orig.tar.gz"
PKGDSC="$PKGNAME"_"$PKGVERS"-"4.dsc"
PKGDIR="$PKGNAME"-"$PKGVERS"

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
