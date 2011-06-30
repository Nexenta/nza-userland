#!/bin/sh

set -e

# universal build script

PKGNAME=`grep ^Source debian/control | sed 's/^Source:\s//''`
PKGVERS=`grep ^Upstream-Version debian/control | sed 's/^Upstream-Version:\s//'`

WEBARCHIVE_PATH=http://ftp.uk.debian.org/debian/pool/main/`echo $PKGNAME | grep -o '^\(lib\)\?[a-z]'`/$PKGNAME/

echo "Starting build of $PKGNAME version $PKGVERS"

if [ -d build ]; then
  echo "Removing old build dir"
  rm -rf build
fi

mkdir -p build cache && cd cache

PKGDSC="$PKGNAME"_"$PKGVERS.dsc"
if [ -f "$PKGDSC" ]; then
  echo "Using local $PKGDSC"
else
  echo "Downloading $PKGDSC ...\c"
  if wget -q -c "$WEBARCHIVE_PATH/$PKGDSC"; then
    echo " done"
  else
    echo " failed"
    exit 1
  fi
fi

ORIGVER=`echo $PKGVERS | sed 's/\(.*\)-\(.*\)/\1/'`
if grep -q 'Format: [0-9]\.[0-9] (native)' "$PKGDSC"; then
  PKGARCH=`grep -o "$PKGNAME"_"$PKGVERS".tar.'\(gz\|bz2\)' $PKGDSC | uniq`
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
  case "$PKGARCH" in
    *.bz2)
      PKGFMT=bz2
      ;;
    *)
      PKGFMT=gz
      ;;
  esac
  PKGORIG="$PKGNAME"_"$ORIGVER.orig.tar.$PKGFMT"
else
  PKGORIG=`grep -o "$PKGNAME"_"$ORIGVER".orig.tar.'\(gz\|bz2\)' $PKGDSC | uniq`
  if [ -f "$PKGORIG" ]; then
    echo "Using local $PKGORIG"
  else
    echo "Downloading $PKGORIG ...\c"
    if wget -q -c $WEBARCHIVE_PATH/$PKGORIG; then
      echo " done"
    else
      echo " failed"
      exit 1
    fi
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
  case "$PKGARCH" in
    *.bz2)
      tar -cjf "../cache/$PKGORIG" "$PKGNAME-$ORIGVER"
      ;;
    *)
      tar -czf "../cache/$PKGORIG" "$PKGNAME-$ORIGVER"
      ;;
  esac
  echo " done"
fi

echo "Applying our changes ...\c"
cp "../cache/$PKGORIG" .
cp -r ../debian "$PKGNAME-$ORIGVER/"
cd "$PKGNAME-$ORIGVER"
if [ -e debian/patches/series ]; then
  QUILT_PATCHES=debian/patches quilt push -a
fi
echo " done"

DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -sa -uc -us
