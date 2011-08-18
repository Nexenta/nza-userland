#! /bin/sh

set -e

if ! test -d ClockerPlugIn; then
    echo >&2 "Cannot find ClockerPlugIn -- run from root of examples directory."
    exit 1
fi

gzip --force README
find . -name '*.gz' -print0 | xargs -0 gunzip -f

mkdir -p src/cppunit
ln -f -s /usr/lib/libcppunit.la src/cppunit

aclocal
libtoolize --automake
automake --add-missing --foreign
autoconf
