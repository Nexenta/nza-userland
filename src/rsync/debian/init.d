#!/usr/bin/bash
set -e

# /lib/svc/method/rsync: start and stop the RSYNC daemon

DAEMON=/usr/bin/rsync
RSYNC_ENABLE=false
RSYNC_OPTS=''
RSYNC_DEFAULTS_FILE=/etc/default/rsync
RSYNC_CONFIG_FILE=/etc/rsyncd.conf
PIDFILE=/var/run/rsyncd.pid

test -x $DAEMON || exit 0

if [ -s $RSYNC_DEFAULTS_FILE ]; then
    . $RSYNC_DEFAULTS_FILE
    case "x$RSYNC_ENABLE" in
        xtrue|xfalse)   ;;
        xinetd)         exit 0
                        ;;
        *)              echo "Value of RSYNC_ENABLE in $RSYNC_DEFAULTS_FILE must be either 'true' or 'false';"
                        echo "not starting rsync daemon."
                        exit 1
                        ;;
    esac
fi

export PATH="${PATH:+$PATH:}/usr/sbin:/sbin"

case "$1" in
  start)
	if "$RSYNC_ENABLE"; then
            echo "Starting rsync daemon: rsync"
	    if [ -s $PIDFILE ] && kill -0 $(cat $PIDFILE) >/dev/null 2>&1; then
	    	echo " apparently already running."
		exit 0
	    fi
            if [ ! -s "$RSYNC_CONFIG_FILE" ]; then
                echo " missing or empty config file $RSYNC_CONFIG_FILE"
                exit 1
            fi
               $DAEMON --daemon --config="$RSYNC_CONFIG_FILE" $RSYNC_OPTS
            echo "."
        else
            if [ -s "$RSYNC_CONFIG_FILE" ]; then
                echo "rsync daemon not enabled in /etc/default/rsync"
            fi
        fi
	;;
  stop)
        if [ -s $PIDFILE ] && kill -0 $(cat $PIDFILE) >/dev/null 2>&1; then
         echo "Stopping rsync daemon: rsync"
         /usr/bin/kill -TERM `/usr/bin/cat $PIDFILE`
	 rm -f $PIDFILE 
         echo "."
        fi
	;;

  reload|force-reload)
        echo "Reloading rsync daemon: not needed, as the daemon"
        echo "re-reads the config file whenever a client connects."
	;;

  restart)
	# set +e
        if $RSYNC_ENABLE; then
            echo "Restarting rsync daemon: "
	    if [ -s $PIDFILE ] && kill -0 $(cat $PIDFILE) >/dev/null 2>&1; then
                /usr/bin/kill -TERM `/usr/bin/cat $PIDFILE`
	    	rm -f $PIDFILE
                echo -n "."
	    fi
            if [ ! -s "$RSYNC_CONFIG_FILE" ]; then
                echo " missing or empty config file $RSYNC_CONFIG_FILE"
                exit 1
            fi
            sleep 5
            $DAEMON --daemon --config="$RSYNC_CONFIG_FILE" $RSYNC_OPTS
            if [ $? -ne 0 ]; then
	    	echo "start failed? $?"
		rm -f $PIDFILE 
	    else  
                echo "."
            fi
        else
            echo "rsync daemon not enabled in /etc/default/rsync"
        fi
	;;

  *)
	echo "Usage: /etc/init.d/rsync {start|stop|reload|force-reload|restart}"
	exit 1
esac

exit 0
