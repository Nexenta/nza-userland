#!/usr/bin/ksh
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
# Copyright 2008 Sun Microsystems, Inc. All rights reserved.
# Use is subject to license terms.
#
# ident "@(#)det_info.sh 1.12 09/02/26 SMI"
#
#This script output the controller detail information to a file under /tmp
#controller dev path as a parameter

base_dir=`dirname $0`
platform=`uname -p`
bin_dir=`echo $base_dir |sed 's/scripts$/bin\//'`
str_class_code="CLASS=000100|CLASS=000101|CLASS=000104|CLASS=000105|CLASS=000106|CLASS=000107|CLASS=000180|CLASS=000c04"

if [ -z "$1" ]
then
	exit 1
else
	dev_path=$1
fi

if [ "$1" = "cpu" ] || [ "$1" = "memory" ]
then
	o_file="$1"_"$$"
	echo "/tmp/$o_file"
	if [ "$1" = "cpu" ]
	then
		${bin_dir}/dmi_info -C >/tmp/$o_file 2>/dev/null
	else
		${bin_dir}/dmi_info -m >/tmp/$o_file 2>/dev/null
	fi
else
	o_file=`echo $dev_path | tr -d '/@,'`
	echo "/tmp/$o_file" #output file name for GUI
	${bin_dir}/all_devices -v -d $dev_path >/tmp/$o_file 2>/dev/null
fi

chmod 666 /tmp/$o_file 2>/dev/null

if [ "`wc /tmp/$o_file | awk '{print $1}'`" -le 1 ]
then
	${bin_dir}/bat_detect -d $dev_path >/tmp/$o_file 2>/dev/null
fi

if [ -z "$2" ]
then
	exit 0
else
	class_code=$2
fi

echo $class_code |  egrep ${str_class_code} >/dev/null 2>&1
echo BBB
if [ $? = 0 ]
then
	IFS='
'	echo AAAA
	d_path=`echo $1 | cut -d: -f1`
	hd_info=`pfexec ${bin_dir}/hd_detect -c $d_path | sort | uniq`
	if [ ! -z "$hd_info" ]
	then
		disk_info=/tmp/disk_info_tmp
		for i in `echo "$hd_info"`
		do
			disk_name=`echo $i | cut -d: -f1`
			disk_path=`echo $i | cut -d: -f3`
			pfexec ${bin_dir}/hd_detect -m $disk_path > $disk_info
			disk_driver=`cat  $disk_info | grep driver | awk -F: '{print $2}'`	
			disk_capacity=`cat $disk_info | grep Capacity | awk -F: '{print $2}'`	
			echo "DISK :	${disk_name}" >>/tmp/$o_file
			echo "   Capacity :	${disk_capacity}" >>/tmp/$o_file
			echo "   Driver   :	${disk_driver}" >>/tmp/$o_file
			echo "   Path     :	${disk_path}" >>/tmp/$o_file
			echo "	" >>/tmp/$o_file
		done
		rm -rf $disk_info >/dev/null 2>&1
	fi
fi
