#!/bin/sh

set -e

# universal build script

PKGNAME=`grep ^Source debian/control | sed 's/^Source:\s//'`
PKGVERS=`grep ^Upstream-Version debian/control | sed 's/^Upstream-Version:\s//'`

if [ -z "$PKGNAME" ]; then
  echo "Cannot determine Source (upstream name)"
  exit 1
elif [ -z "$PKGVERS" ]; then
  echo "Cannot determine Upstream-Version"
  exit 1
fi

echo "Starting build of $PKGNAME version $PKGVERS"

if [ -d build ]; then
  echo "Removing old build dir"
  rm -rf build
fi

mkdir -p build cache && cd cache

PKGURL=http://ftp.uk.debian.org/debian/pool/main/`echo $PKGNAME | grep -o '^\(lib\)\?[a-z]'`/$PKGNAME
PKGDSC="$PKGNAME"_"$PKGVERS.dsc"
if [ -f "$PKGDSC" ]; then
  echo "Using previously downloaded $PKGDSC"
else
  echo "Downloading $PKGDSC ...\c"
  if wget -q -c "$PKGURL/$PKGDSC"; then
    echo " done"
  else
    echo " failed"
    exit 1
  fi
fi

PKGORIGVERS=`echo $PKGVERS | sed 's/\(.*\)-\(.*\)/\1/'`
PKGFORMAT=`grep ^Format "$PKGDSC" | sed 's/^Format:\s//'`
PKGARCH=`grep -o "$PKGNAME"_"\($PKGVERS\|$PKGORIGVERS\)\(\.orig\)\?\.tar\.\(bz2\|gz\)" $PKGDSC | uniq`
case "$PKGARCH" in
  *.bz2)
    PKGFMT=bz2
    ;;
  *)
    PKGFMT=gz
    ;;
esac

PKGORIG="$PKGNAME"_"$PKGORIGVERS.orig.tar.$PKGFMT"
if [ -f "$PKGARCH" ]; then
  echo "Using previously downloaded $PKGARCH"
else
  echo "Downloading $PKGARCH ...\c"
  if wget -q -c "$PKGURL/$PKGARCH"; then
    echo " done"
  else
    echo " failed"
    exit 1
  fi
fi

cd ../build

# We need to create a .orig for native packages
PKGDIR=`echo $PKGNAME | sed 's/[0-9]//g'`-"$PKGORIGVERS"
if echo "$PKGFORMAT" | grep -q native; then
  if [ -f "../cache/$PKGORIG" ]; then
    echo "Unpacking previously generated $PKGORIG ...\c"
    tar -xf "../cache/$PKGORIG"
    echo " done"
    [ -d "$PKGDIR" ] || PKGDIR="$PKGNAME"
  else
    echo "Unpacking $PKGARCH ...\c"
    tar -xf "../cache/$PKGARCH" --exclude "debian"
    echo " done"
    [ -d "$PKGDIR" ] || PKGDIR="$PKGNAME"
    echo "Creating $PKGORIG ...\c"
    case "$PKGARCH" in
      *.bz2)
        TAROPTS=-cjf
        ;;
      *)
        TAROPTS=-czf
        ;;
    esac
    echo "Generating $PKGORIG ...\c"
    tar $TAROPTS "../cache/$PKGORIG" "$PKGDIR"
    echo " done"
  fi
else
  echo "Using $PKGARCH as orig tarball"
  echo "Unpacking $PKGARCH ...\c"
  tar -xf "../cache/$PKGARCH"
  echo " done"
  [ -d "$PKGDIR" ] || PKGDIR="$PKGNAME"
fi

echo "Applying our changes ..."
cp "../cache/$PKGARCH" "$PKGORIG"
cp -r ../debian "$PKGDIR/" && cd "$PKGDIR"
if [ -e debian/patches/series ]; then
  QUILT_PATCHES=debian/patches quilt push -a
fi

DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -sa -uc -us
