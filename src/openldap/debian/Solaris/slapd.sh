#! /usr/bin/ksh93

#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright 2010 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#
# ident	"@(#)ldap-olslapd	1.1	10/01/28 SMI"
#

source /lib/svc/share/smf_include.sh

typeset -r LDAPUSR=openldap
typeset -r LDAPGRP=openldap
typeset -r VARRUNDIR=/var/run/openldap
typeset -r PIDFILE=${VARRUNDIR}/slapd.pid
typeset -r CONF_FILE=/etc/openldap/slapd.conf
typeset -r SLAPD="/usr/lib/slapd -u ${LDAPUSR} -g ${LDAPGRP} -f ${CONF_FILE}"

[[ ! -f ${CONF_FILE} ]] && exit $SMF_EXIT_ERR_CONFIG


case "$1" in
start)
        if [[ ! -d ${VARRUNDIR} ]] ; then
		/usr/bin/mkdir -m 755 ${VARRUNDIR} || exit $SMF_EXIT_ERR_CONFIG
		/usr/bin/chown ${LDAPUSR}:${LDAPGRP} ${VARRUNDIR}
        else
		/bin/rm -f ${PIDFILE}
	fi

        exec ${SLAPD} 2>&1
        ;;
stop)
	# Use the actual contract, not ${PIDFILE}
	smf_kill_contract $2 TERM 1 30
        ret=$?
        [ $ret -ne 0 ] && exit 1
	exit $ret
        ;;
*)
        print "Usage: $0 {start|stop}"
        exit 1
        ;;
esac

# not reached
