#!/bin/sh

set -e

# build script for sunw-meta

if [ -d build ]; then
  echo "Removing old build dir"
  rm -rf build
fi

mkdir -p build/sunw-meta && cd build/sunw-meta

cp -r ../../debian .

DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -sa -uc -us
