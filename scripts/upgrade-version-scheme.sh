#!/bin/sh -e -u

CWD="$PWD"

NEW_VERSION='40-0-0'

MSG_NEW_SCHEME='New version scheme'
MSG_PORTED='Ported to NCP4'
ENTRY="$MSG_NEW_SCHEME"


usage() {
    cat << USAGE

Usage: $0 [options] [package dir]

If no package directory is specified, current directory is used.
If no options are given, -n is assumed


Options:

    -m "changelog text"   use this text in debian/changlog entry

    -p                    same as \`-m "$MSG_PORTED" '
    -n                    same as \`-m "$MSG_NEW_SCHEME" '


    -h                    this help message

USAGE
    exit 0
}


while getopts npm:h opt; do
    case $opt in
        p) ENTRY="$MSG_PORTED";;
        n) ENTRY="$MSG_NEW_SCHEME";;
        m) ENTRY="$OPTARG";;
        *) usage ;;
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

CHANGELOG="$PKGDIR/debian/changelog"
if [ ! -f "$CHANGELOG" ]; then
    echo "Not found: \`$CHANGELOG'. Abort"
    exit 1
fi

PKGNAME=`basename "$PKGDIR"`

if grep -q '^Upstream-Version:' "$CONTROL" ; then
    echo "Package \`$PKGNAME' already uses new version scheme. Nothing to do."
    exit 0
fi

CHANGELOG_HEAD_LINE=`head -n 1 $CHANGELOG`
echo "Using head from changelog: \`$CHANGELOG_HEAD_LINE'"

if echo "$CHANGELOG_HEAD_LINE" | grep -q "$NEW_VERSION" ; then
    echo "Already new version? Maybe, incomplete previous update. Abort"
    exit 1
fi

UPSTREAM_VERSION=`echo "$CHANGELOG_HEAD_LINE" | sed -r 's/.*\((.+:)?([0-9.]+).*\).*/\2/' || true`
if [ -n "$UPSTREAM_VERSION" ]; then
    echo "Detected upstream version is \`$UPSTREAM_VERSION'"
else
    echo "Can't detect upstream version. Abort."
    exit 1
fi

echo "Updating \`$CHANGELOG'"
dch -p -b -v "$NEW_VERSION" -c "$CHANGELOG" "$ENTRY"

echo "Updating \`$CONTROL'"
awk "{print \$0}; /^Source:/ {print \"Upstream-Version: $UPSTREAM_VERSION\"}" \
    "$CONTROL" > "$CONTROL.new"
mv "$CONTROL.new" "$CONTROL"

FORMAT="$PKGDIR/debian/source/format"
if [ -f "$FORMAT" ]; then
    if ! grep -q '3\.0  *(quilt)' "$FORMAT" ; then
        echo "Updating \`$FORMAT' to \`3.0 (quilt)'"
        echo '3.0 (quilt)' > "$FORMAT"
        echo 'See http://wiki.debian.org/Projects/DebSrc3.0'
    fi
fi

COMPAT="$PKGDIR/debian/compat"
echo "Updating \`$COMPAT' to 8"
echo 8 > "$COMPAT"

exit 0

