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

PKGURL=http://ftp.uk.debian.org/debian/pool/main/`echo $PKGNAME | grep -o '^\(lib\)\?[a-z]'`/$PKGNAME/
PKGDSC="$PKGNAME"_"$PKGVERS.dsc"
if [ -f "$PKGDSC" ]; then
  echo "Using local $PKGDSC"
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
if [ "$PKGFORMAT" = "1.0" ]; then
  PKGARCH="$PKGNAME"_"$PKGVERS".tar.gz
  PKGORIG="$PKGNAME"_"$PKGVERS".orig.tar.gz
  if [ -f "$PKGORIG" ]; then
    echo "Using local $PKGORIG"
  elif [ -f "$PKGARCH" ]; then
    echo "Using local $PKGARCH"
  else
    if wget -q -c "$PKGURL/$PKGARCH"; then
      echo " done"
    else
      echo " failed"
      exit 1
    fi
  fi
  [ -f "$PKGORIG" ] || mv "$PKGARCH" "$PKGORIG"
elif [ "$PKGFORMAT" = "3.0 (native)" ]; then
  PKGARCH=`grep -o "$PKGNAME"_"$PKGVERS".tar.'\(gz\|bz2\)' $PKGDSC | uniq`
  if [ -f "$PKGARCH" ]; then
    echo "Using local $PKGARCH"
  else
    echo "Downloading $PKGARCH ...\c"
    if wget -q -c "$PKGURL/$PKGARCH"; then
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
  PKGORIG="$PKGNAME"_"$PKGORIGVERS.orig.tar.$PKGFMT"
else # Assume 3.0 (quilt) or some other modern format
  PKGORIG=`grep -o "$PKGNAME"_"$PKGORIGVERS".orig.tar.'\(gz\|bz2\)' $PKGDSC | uniq`
  if [ -f "$PKGORIG" ]; then
    echo "Using local $PKGORIG"
  else
    echo "Downloading $PKGORIG ...\c"
    if wget -q -c "$PKGURL/$PKGORIG"; then
      echo " done"
    else
      echo " failed"
      exit 1
    fi
  fi
fi

cd ../build

PKGDIR=`echo $PKGNAME | sed 's/[0-9]//g'`-"$PKGORIGVERS"
if [ -f "../cache/$PKGORIG" ]; then
  echo "Unpacking $PKGORIG ...\c"
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
      tar -cjf "../cache/$PKGORIG" "$PKGDIR"
      ;;
    *)
      tar -czf "../cache/$PKGORIG" "$PKGDIR"
      ;;
  esac
  echo " done"
fi

echo "Applying our changes ...\c"
cp "../cache/$PKGORIG" .
cp -r ../debian "$PKGDIR/" && cd "$PKGDIR"
if [ -e debian/patches/series ]; then
  QUILT_PATCHES=debian/patches quilt push -a
fi
echo " done"

DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -sa -uc -us
