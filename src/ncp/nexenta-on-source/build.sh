#!/bin/sh

set -e

# build script for nexenta-on-source

if [ -d build ]; then
  echo "Removing old build dir"
  rm -rf build
fi

mkdir -p build/nos && cd build/nos

cp -r ../../debian .

DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -sa -uc -us
