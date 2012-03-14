#!/bin/sh

# Copyright (c) 2012, Nexenta Systems, Inc. All rights reserved.

PATH=/usr/gnu/bin:/usr/bin:/sbin:/usr/sbin:/usr/gnu/sbin

PROTO="$1"
PKGDIR="$2"

ERRORDIR=`dirname $0`

CWD=`pwd`
PKGNAME=`basename $CWD`

echo "Building pkg: $PKGNAME ..."

#echo "$PROTO"

BASEGATE=$PROTO /usr/bin/dpkg-buildpackage -d -b -uc 2> build.log 1>&2
RES=$?

if (( $RES > 0 )); then
    echo "Error: $PKGNAME"
    echo "Error: $PKGNAME" >> $ERRORDIR/bldpkg_err.txt
else
    cd ..
    mv ${PKGNAME}_*.* $PKGDIR
fi

exit 0
