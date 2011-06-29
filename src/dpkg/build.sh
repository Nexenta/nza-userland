#!/bin/sh

set -e

# build script for dpkg

WEBARCHIVE_PATH="http://ftp.uk.debian.org/debian/pool/main/d/dpkg/"

PKGNAME=dpkg
PKGVERS=`grep Upstream-Version debian/control | sed 's/Upstream-Version:\s//'`
PKGARCH="$PKGNAME"_"$PKGVERS.tar.bz2"
PKGORIG="$PKGNAME"_"$PKGVERS.orig.tar.bz2"
PKGDSC="$PKGNAME"_"$PKGVERS.dsc"
PKGDIR="$PKGNAME-$PKGVERS"

if [ -d build ]; then
  echo "Removing old build dir"
  rm -rf build
fi

mkdir -p build cache && cd cache

if [ -f "$PKGARCH" ]; then
  echo "Using local $PKGARCH"
else
  echo "Downloading $PKGARCH ...\c"
  if wget -q -c $WEBARCHIVE_PATH/$PKGARCH; then
    echo " done"
  else
    echo " failed"
    exit 1
  fi
fi

if [ -f "$PKGDSC" ]; then
  echo "Using local $PKGDSC"
else
  echo "Downloading $PKGDSC ...\c"
  if wget -q -c $WEBARCHIVE_PATH/$PKGDSC; then
    echo " done"
  else
    echo " failed"
    exit 1
  fi
fi

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
