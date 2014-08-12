#!/usr/bin/sh

. /lib/svc/share/smf_include.sh

assembled=$(/usr/bin/svcprop -p config/assembled $SMF_FMRI)

if [ "$assembled" == "true" ] ; then
    exit $SMF_EXIT_OK
fi

if [ -f /etc/svc/profile/nexenta_ndmp.xml ]; then
    svccfg apply /etc/svc/profile/nexenta_ndmp.xml
    svcadm refresh system/ndmpd:default

fi

svccfg -s $SMF_FMRI setprop config/assembled = true
svccfg -s $SMF_FMRI refresh

