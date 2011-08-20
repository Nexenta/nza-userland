#!/bin/bash

START_DATE="Tue Feb 16 21:36:53 2010"

path=$1
if test "x$path" = x; then
	echo "Usage: $0 <relpath within GATEROOT=$GATEROOT>"
	exit 1;
fi
#cd $GATEROOT; hg pull

revs=$(cd $GATEROOT; hg qseries | awk -F- '/^bkport\-/ {print $2}' | awk -F\. '{print $1}' | grep -v reworked)
revs_reworked=$(cd $GATEROOT; hg qseries | awk -F- '/^bkport\-reworked\-/ {print $3}' | awk -F\. '{print $1}')
revs="$revs $revs_reworked"

if test "x$path" = xiscsi; then
	paths="usr/src/cmd/iscsid usr/src/cmd/iscsiadm usr/src/uts/common/io/scsi/adapters/iscsi usr/src/uts/intel/iscsi"
elif test "x$path" = xcomstar; then
	paths="usr/src/uts/intel/stmf usr/src/uts/intel/stmf_sbd usr/src/uts/intel/iscsit usr/src/uts/intel/idm usr/src/uts/common/io/comstar usr/src/lib/libstmf usr/src/lib/libiscsit usr/src/cmd/stmfadm usr/src/cmd/itadm usr/src/cmd/stmfsvc usr/src/uts/intel/fcoe usr/src/uts/intel/fcoet usr/src/uts/common/sys/fcoe usr/src/uts/common/io/fcoe usr/src/pkgdefs/SUNWfcoeu usr/src/pkgdefs/SUNWfcoet usr/src/lib/libfcoe usr/src/cmd/fcinfo"
elif test "x$path" = xiscsitgt; then
	paths="usr/src/lib/libiscsitgt usr/src/cmd/iscsi/iscsitadm usr/src/cmd/iscsi/iscsitgtd"
elif test "x$path" = xzfs; then
	paths="usr/src/lib/libzfs usr/src/lib/libzpool usr/src/cmd/zfs usr/src/cmd/zpool usr/src/cmd/zdb usr/src/cmd/zdump usr/src/cmd/zinject usr/src/cmd/ztest usr/src/uts/common/fs/zfs usr/src/uts/intel/zfs usr/src/cmd/mdb/common/modules/zfs usr/src/grub/grub-0.97/stage2/zfs-include"
elif test "x$path" = xcifs; then
	paths="usr/src/uts/common/smbsrv usr/src/uts/intel/smbsrv usr/src/lib/smbsrv usr/src/lib/smbsrv/libmlrpc usr/src/lib/smbsrv/libmlsvc usr/src/lib/smbsrv/libsmb usr/src/lib/smbsrv/libsmbns usr/src/lib/smbsrv/libsmbrdr usr/src/cmd/smbsrv usr/src/cmd/smbsrv/dtrace usr/src/cmd/smbsrv/smbadm usr/src/cmd/smbsrv/smbd usr/src/cmd/smbsrv/smbstat usr/src/uts/common/fs/smbsrv"
elif test "x$path" = xidmap; then
	paths="usr/src/cmd/idmap/idmapd usr/src/lib/libadutils usr/src/lib/libidmap usr/src/lib/nsswitch/ad usr/src/cmd/idmap/idmap"
elif test "x$path" = xndmp; then
	paths="usr/src/cmd/ndmpd usr/src/cmd/ndmpadm usr/src/cmd/ndmpstat"
elif test "x$path" = xkrb5; then
	paths="usr/src/lib/gss_mechs/mech_krb5 usr/src/cmd/krb5 usr/src/lib/krb5 usr/src/lib/pam_modules/krb5 usr/src/uts/common/gssapi/mechs/krb5"
elif test "x$path" = xintel_pci; then
	paths="usr/src/uts/intel/io/acpica usr/src/uts/intel/io/pci"
else
	paths=$path
fi

missing_revs=""
for p in $paths; do
	path_revs=$(cd $GATEROOT/$p; hg log -d ">$START_DATE" .|awk -F: '/changeset:/ {print $3}')
	for r in $path_revs; do
		if ! echo $revs | grep -w $r >/dev/null; then
			if echo $missing_revs | grep -w $r >/dev/null; then
				echo "$r: NOT FOUND (see above)"
			else
				cd $GATEROOT/$p
				hg log -v -r $r | grep bkport >/dev/null && continue
				echo "$r: NOT FOUND"
				hg log -v -r $r
				missing_revs="$r $missing_revs"
			fi
		else
			echo "$r: OK"
		fi
	done
done
