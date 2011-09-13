#!/bin/bash
#
# Copyright 2005-2011 Nexenta Systems, Inc.  All rights reserved.
# Use is subject to license terms.
#
# $Id$
#
# Igor Kozhukhov <igor.kozhukhov@nexenta.com>
#

function build() {
    DIR="$1"
    cd $DIR
    PKG=`basename $DIR`
    echo "Starting build of package: $PKG ..."
    dpkg-buildpackage -d -b 2>&1 > /dev/null 2> /dev/null
#    echo $PKG >> $CWD/pkgs.txt
    cd $CWD
    echo "Finished: $PKG"
}

CWD=`pwd`

DIRS=`find debian/packages/ -maxdepth 1 -type d  -name "*"`

test -f $CWD/pkgs.txt && rm -f $CWD/pkgs.txt

for DIR in $DIRS
do
    build $DIR
done

echo "== Build of packages have been finished"

exit 0
