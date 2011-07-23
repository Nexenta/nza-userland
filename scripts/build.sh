#!/bin/sh

set -e
set -u

BUILDDIR=/tmp/build-pkg

SRC_BASE_URL="
http://apt.nexenta.org/wip/dists/unstable/main/source
http://apt.nexenta.org/wip/dists/testing/main/source
http://apt.nexenta.org/wip/dists/stable/main/source
http://ftp.fi.debian.org/debian/pool/main
http://ftp.uk.debian.org/debian/pool/main
http://ftp.de.debian.org/debian/pool/main
"

LOCAL_TARBALL=''
FORCE='no'
INSTALL_BUILD_DEPS='yes'
DPKG_BP_OPTIONS='-sa'
UPLOAD_CMD=''

QUILT_PATCHES=${QUILT_PATCHES:-debian/patches}
CWD="$PWD"


usage()
{
    cat << USAGE
Usage: $0 [options] [path/to/pkg/in/hg/tree]

If no path specified, current directory is used.

Options:

    -o <orig-tarball>     Do not download tarball, but get this one
    -f                    Overwrite files if they exist
    -d                    Do not install build dependancies
    -B "dpkg-buildpackage options" ($DPKG_BP_OPTIONS)

    -U <target>           Ship built packages with \`dupload --to <target>'
                          (see /etc/dupload.conf

    -P <target>           Ship built packages with \`dput -f <target>'
                          (see /etc/dput.cf).
    -L                    Same as \`-P local'

    -h                    This help message

USAGE
}


while getopts U:PL:B:dfo:h? opt; do
    case $opt in
        o)
            if [ ! -f "$OPTARG" ]; then
                echo "No such file: $OPTARG"
                exit 1
            fi
            if ! echo "$OPTARG" | grep -q -E '^(~|/)'; then
                LOCAL_TARBALL="$CWD/$OPTARG"
            else
                LOCAL_TARBALL="$OPTARG"
            fi
            ;;

        B) DPKG_BP_OPTIONS="$OPTARG" ;;

        d) INSTALL_BUILD_DEPS='no' ;;

        U) UPLOAD_CMD="dupload --to $OPTARG" ;;
        P) UPLOAD_CMD="dput -f $OPTARG" ;;
        L) UPLOAD_CMD='dput -f local' ;;

        f) FORCE=yes ;;

        h|\?)
            usage
            exit 0
            ;;
    esac
done
shift `expr  $OPTIND - 1`


if [ $# = 0 ]; then
    PKGDIR="$CWD"
elif [ "$1" = . ]; then
    PKGDIR="$CWD"
else
    PKGDIR="$1"
fi

# Strip /debian...:
PKGDIR=`echo "$PKGDIR" | sed -r 's,(/debian.*|/*)$,,'`
if ! echo "$PKGDIR" | grep -q -E '^(~|/)'; then
    PKGDIR="$CWD/$PKGDIR"
fi
echo "Working with \`$PKGDIR'"

CONTROL="$PKGDIR/debian/control"
if [ ! -f "$CONTROL" ]; then
    echo "Not found: \`$CONTROL'. Abort"
    exit 1
fi

if ! grep -q '3\.0  *(quilt)' "$PKGDIR/debian/source/format" ; then
    echo "Source is not of \`3.0 (quilt)' format. Please update the package."
    exit 1
fi

PKGNAME=`basename "$PKGDIR"`
PKGNAME_c=`grep '^Source:' "$CONTROL" | grep -wo '\S*$' || true`
if [ -n "$PKGNAME_c" ]; then
    if [ "$PKGNAME_c" != "$PKGNAME" ]; then
        echo "Warning: source name in \`$CONTROL' and directory name do not match."
        echo "Using package name from \`$CONTROL'"
        PKGNAME="$PKGNAME_c"
        sleep 2
    fi
else
    echo "Error: field \`Source' not found in \`$CONTROL'. Abort"
    exit 1
fi

echo "Source package name is \`$PKGNAME'"

# FIXME: dctrl-tools is better, but absent ;-)
# debian/control can have several Section fields (for each package),
# we use the first one for source (head -n 1)
SECTION=`grep '^Section:' "$CONTROL" | grep -wo '\S*$' | head -n 1 || true`
if [ -z "$SECTION" ]; then
    echo "Field \`Section' is not set. \`$CONTROL' is broken."
    exit 1
else
    echo "Section is \`$SECTION'"
fi

UPSTREAM_VERSION=`grep '^Upstream-Version:' "$CONTROL" | grep -wo '\S*$' || true`
if [ -z "$UPSTREAM_VERSION" ]; then
    echo "Field \`Upstream-Version' is not set. Please update the package to the new version scheme (40-0-0)."
    exit 1
else
    echo "Upstream version is \`$UPSTREAM_VERSION'"
fi



# $PKGDIR is an absolute path
PKGBUILDDIR="${BUILDDIR}${PKGDIR}"
mkdir -p "$PKGBUILDDIR"

echo "Changing directory to \`$PKGBUILDDIR'"
cd "$PKGBUILDDIR"

TARBALL_TMPL=${PKGNAME}_${UPSTREAM_VERSION}.orig.tar
SOURCE_TARBALL=''

echo "Getting source tarball"
if [ -z "$LOCAL_TARBALL" ]; then
    tarball=`ls -1 ${TARBALL_TMPL}.* 2>/dev/null | head -n 1 || true`
    if [ -n "$tarball" -a $FORCE != yes ]; then
        echo "Tarball already here: $tarball"
        echo "Use -f options to download again"
        sleep 2
        SOURCE_TARBALL="$tarball"
    else
        rm -f ${TARBALL_TMPL}.*
        for base_url in $SRC_BASE_URL ; do
            for c in gz bz2 xz lzma; do
                SOURCE_TARBALL="${TARBALL_TMPL}.$c"
                case "$base_url" in
                    *.debian.org/*)      # work for ksh and bash:
                        urls="$base_url/${PKGNAME:0:1}/$PKGNAME/$SOURCE_TARBALL"
                        # maybe package is native for Debian?
                        urls+=" $base_url/${PKGNAME:0:1}/$PKGNAME/${SOURCE_TARBALL/.orig/}"
                        ;;
                    *)
                        urls="$base_url/$SECTION/$SOURCE_TARBALL"
                        ;;
                esac
                for s in $urls ; do
                    printf "Trying $s ... "
                    if curl -f --head -s -w '%{http_code}' -o /dev/null "$s"; then
                        echo
                        curl -f -# -o "$SOURCE_TARBALL" "$s";
                        break 3 # Exit from three for-loops
                    else
                        echo
                        rm -f "$SOURCE_TARBALL"
                    fi
                done
            done
        done
        if [ ! -f "$SOURCE_TARBALL" ] ; then
            echo "No tarball downloaded. Abort"
            exit 1
        fi
    fi
else
    echo "Copying local tarball \`$LOCAL_TARBALL'"
    SOURCE_TARBALL=`basename "$LOCAL_TARBALL"`
    c=`echo "$SOURCE_TARBALL" | sed -r 's,.*\.tar\.(gz|bz2|xz|lzma)$,\1,'`
    if [ -z "$c" ]; then
        echo "\`$LOCAL_TARBALL' is not a tarball or compression is not supported. Abort."
        exit 1
    fi
    if [ "$SOURCE_TARBALL" != "${TARBALL_TMPL}.$c" ]; then
        echo "Name \`$SOURCE_TARBALL' does not match source tarball name scheme,"
        echo "      renaming to \`${TARBALL_TMPL}.$c'"
        SOURCE_TARBALL=${TARBALL_TMPL}.$c
    fi
    if [ ! -f "$SOURCE_TARBALL" -o "$FORCE" = yes ]; then
        rm -f "$SOURCE_TARBALL"
        cp "$LOCAL_TARBALL" "$SOURCE_TARBALL"
    else
        echo "File \`$SOURCE_TARBALL' exists. Use -f option to overwrite."
        sleep 2
    fi
fi


echo "Unpacking sources into \`$PKGNAME'"
[ -d "$PKGNAME" ] && rm -rf "$PKGNAME"
mkdir "$PKGNAME"

echo "Unpacking source tarball \`$SOURCE_TARBALL'"
tar xf $SOURCE_TARBALL -C "$PKGNAME" --strip-components=1

echo "Updating directory \`debian/'"
[ -e "$PKGNAME/debian" ] && rm -rf "$PKGNAME/debian"
cp -r "$PKGDIR/debian" "$PKGNAME/debian"

cd "$PKGNAME"
# Otherwise quilt will fail:
if [ `quilt series | wc -l` != 0 ]; then
    echo "Applying patches"
    quilt push -a
fi
cd -

#TODO: read dependancies from debian/control
if [ "$INSTALL_BUILD_DEPS" = yes ]; then
    echo "Getting build dependancies"
    if ! apt-get -q -y  build-dep $PKGNAME ; then
        echo "Try to use -d option (see $0 -h for help)"
        exit 1
    fi
fi

echo "Building package"
cd "$PKGNAME"
dpkg-buildpackage $DPKG_BP_OPTIONS
cd -

if [ -n "$UPLOAD_CMD" ]; then
    $UPLOAD_CMD "$PKGBUILDDIR"/*.changes
fi

echo "New package(s):"
ls -1 "$PKGBUILDDIR"/*.deb

