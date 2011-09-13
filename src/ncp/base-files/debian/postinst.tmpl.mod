#!/usr/bin/sh

set -e

PATH=/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

if [ "${BASEDIR:=/}" != "/" ]; then
    BASEDIR_OPT="-b $BASEDIR"
fi

case "$1" in
    configure)
        echo "#OSNAME# #VERSION# (Siddy/Illumos)" > /etc/issue
        echo "#OSNAME# #VERSION# (Siddy/Illumos)" > /etc/issue.net
        echo "The programs included with the Nexenta system are free software;" > /etc/motd
        echo "the exact distribution terms for each program are described in the" >> /etc/motd
        echo "individual files in /usr/share/doc/*/copyright." >> /etc/motd
        echo "" >> /etc/motd
        echo "Nexenta comes with ABSOLUTELY NO WARRANTY, to the extent permitted by" >> /etc/motd
        echo "applicable law." >> /etc/motd
    ;;

    abort-upgrade|abort-remove|abort-deconfigure)
    ;;

    *)
        echo "postinst called with unknown argument '$1'" >&2
        exit 1
    ;;
esac

exit 0
