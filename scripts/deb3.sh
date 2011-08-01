#!/bin/bash
set -e
# COPYRIGHT
#
#     (c) Osamu Aoki, 2010, GPL2+
#
# dpatch2quilt.sh is used as the base of this program.
# parts from http://blog.orebokech.com/2007/08/converting-debian-packages-from-dpatch.html
#     (c) gregor herrmann, 2007-2008, GPL2+
#     (c) Damyan Ivanov, 2007-2008, GPL2+
#     (c) Martin Quinson, 2008, GPL2+

# NAME
#
#     deb3 - convert debian source package to new 3.0 (quilt) format
#
# SYNOPSIS
#
#     deb3 [quilt|dpatch|0|1|2|]
#
# DESCRIPTION
#
# deb3 converts debian source packages which use series of patches from 
# 1.0 format to new 3.0 (quilt) format while adjusting contents in 
# debian/patches.  This is run from the package top level directory.
# If run without argument, deb3 guesses source structure.  Following 
# formats are auto detected.
#
#   * dh_quilt_patch/dh_quilt_unpatch
#   * dpatch
#   * cdbs (simple-patchsys.mk)
#   * dbs  (dbs-build.mk)
#
# ARGUMENT
#
# You can force particular conversion using argument.
#
#     quilt   conversion for dh_quilt_patch/dh_quilt_unpatch
#     dpatch  conversion for dpatch
#     0       conversion for dbs and cdbs made with -p 0 patches (default)
#     1       conversion for dbs and cdbs made with -p 1 patches
#     2       conversion for dbs and cdbs made with -p 2 patches

# Default patch level for cdbs and dbs 
# This may be overriden via environment variable or argument
: ${PATCH_LEVEL=0}

export QUILT_PATCHES=debian/patches
export QUILT_PATCH_OPTS=""
export QUILT_DIFF_ARGS="-p ab --no-timestamps --no-index --color=auto"
export QUILT_REFRESH_ARGS="-p ab --no-timestamps --no-index"
export QUILT_COLORS="diff_hdr=1;32:diff_add=1;34:diff_rem=1;31:diff_hunk=1;33:diff_ctx=35:diff_cctx=33"

function convert_quilt()
{
	COUNT_OLD=$(ls -1 debian/patches/*.patch | wc -l)
	COUNT_NEW=$(ls -1 debian/patches/*.patch | wc -l)
}

function convert_dpatch()
{
	for p in $(dpatch list-all); do
	        quilt import -P $p.patch debian/patches/$p.dpatch
	        AUTHOR=$(dpatch cat --author-only $p.dpatch)
	        DESC=$(dpatch cat --desc-only $p.dpatch)
	        echo "Author: $AUTHOR" | quilt header -r $p.patch
	        echo "Description: $DESC" | quilt header -a $p.patch
	        quilt push
	        quilt refresh
	        # git add debian/patches/$p.patch
	done
	quilt pop -a
	COUNT_OLD=$(ls -1 debian/patches/*.dpatch | wc -l)
	COUNT_NEW=$(ls -1 debian/patches/*.patch | wc -l)
	rm -rf debian/patches/*.dpatch
	rm -rf debian/patches/00list
	# git add debian/patches/series
	# git rm debian/patches/00list debian/patches/*.dpatch
}

function convert_simple()
{
	mv debian/patches debian/patches-old
	for p in debian/patches-old/* ; do
		# normalize patch filename extension to *.patch
		q=${p##*/}
		q=${q%.*}.patch
		# normally $PATCH_LEVEL is 0
	        quilt import -p $PATCH_LEVEL -P $q $p
		# no good data to use.  Just provide template entries.
	        quilt push
	        quilt refresh
	        # git add $p
	done
	quilt pop -a	
	COUNT_OLD=$(ls -1 debian/patches-old/* | wc -l)
	COUNT_NEW=$(ls -1 debian/patches/*.patch | wc -l)
	rm -rf debian/patches-old
	# git add debian/patches/series
}

dh_testdir

# set package source format
mkdir -p debian/source
echo "3.0 (quilt)" >debian/source/format

# make debian/rules template
mv debian/rules debian/rules.old
cat >debian/rules <<EOF
#!/usr/bin/make -f
# Uncomment this to turn on verbose mode.
#export DH_VERBOSE=1

%:
        dh  \$@

# Use override_dh_* targets to customize this.
# ---------------------------------------------------
# For old debian/rules see debian/rules.old
#
EOF

# change patch queue format
if [ "$1" = quilt ]; then
	convert_quilt
elif [ "$1" = dpatch ]; then
	convert_dpatch
elif [ "$1" = 1 ] || [ "$1" = 2 ] || [ "$1" = 3 ]; then
	PATCH_LEVEL=$1
	convert_simple
elif [ -f debian/patches/series ]; then
	convert_quilt
elif [ -f debian/patches/00list ]; then
	convert_dpatch
elif grep "include.*\/cdbs\/.*\/simple-patchsys\.mk" debian/rules ; then
	convert_simple
elif grep "include.*\/dbs\/dbs-build\.mk" debian/rules ; then
	convert_simple
else
	echo "deb3 [quilt|dpatch|0|1|2|]" >&2
	exit 1
fi

if [ "$COUNT_OLD" != "$COUNT_NEW" ] ; then
        echo "WARNING: The numbers of removed dpatch patches and added quilt patches differ!" >&2
	exit 1
fi

echo "... Auto conversion completed!" >&2

cat <<EOF

-----------------------------------------------------------------------
You need to make further modification to your package following 
debhelper(7) manpage.  This deb3 script only provides starting point to
you.  Typical modifications are:

 * "Build-Depends:" should remove "cdbs", "dpatch", and "quilt".
 * "Build-Depends:" should list "debhelper"
 * Add "override_dh_*:" targets to debian/rules to address special 
   cases.

You can find tutorial for packaging using this new "dh \$@" style and 
new 3.0 (quilt) source format in the maint-guide package.  It is also 
availabe at:

   http://www.jp.debian.org/doc/manuals/maint-guide/index.en.html

-----------------------------------------------------------------------
EOF

exit 0

