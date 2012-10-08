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
# ident "@(#)probe.sh 1.29 09/04/27 SMI"
#
#PCI CLASS CODES
#define	PCI_CLASS_NONE		0x0	/* class code for pre-2.0 devices */
#define	PCI_CLASS_MASS		0x1	/* Mass storage Controller class */
#define	PCI_CLASS_NET		0x2	/* Network Controller class */
#define	PCI_CLASS_DISPLAY	0x3	/* Display Controller class */
#define	PCI_CLASS_MM		0x4	/* Multimedia Controller class */
#define	PCI_CLASS_MEM		0x5	/* Memory Controller class */
#define	PCI_CLASS_BRIDGE	0x6	/* Bridge Controller class */
#define	PCI_CLASS_COMM		0x7	/* Communications Controller class */
#define	PCI_CLASS_PERIPH	0x8	/* Peripheral Controller class */
#define	PCI_CLASS_INPUT		0x9	/* Input Device class */
#define	PCI_CLASS_DOCK		0xa	/* Docking Station class */
#define	PCI_CLASS_PROCESSOR	0xb	/* Processor class */
#define	PCI_CLASS_SERIALBUS	0xc	/* Serial Bus class */
#define	PCI_CLASS_WIRELESS	0xd	/* Wireless Controller class */
#define	PCI_CLASS_INTIO		0xe	/* Intelligent IO Controller class */
#define	PCI_CLASS_SATELLITE	0xf	/* Satellite Communication class */
#define	PCI_CLASS_CRYPT		0x10	/* Encrytion/Decryption class */
#define	PCI_CLASS_SIGNAL	0x11	/* Signal Processing class */

#Driver version number --- modinfo
#scsi_vhci info: ./all_devices -L /scsi_vhci
#usb device: if there is usb_mid layer, get productname from this layer. get driver name from the last layer.
#How to detect infrared/bluetooth/winmodem  device

#Class code to be filtered
#"000600", "000601", "000602", "000603", "000604", "0005","000c05", "0008", "000380", "0000", "000b", "Motherboard"
# Normaly 000680 is a bridge device, but there are some nvidia network devices with 000680 classcode.

base_dir=`dirname $0`
platform=`uname -p`
bin_dir=`echo $base_dir |sed 's/scripts$/bin\//'`
ctl_file=/tmp/dvt_ctl_file
drv_pkg_file=$base_dir/drv_pkg_file
net_stat=0 #0,1,2,3 0:can connet to IPS 1:can not connect to IPS 2:No need to connect IPS as there is a driver for the device in the system 3. 3rd party driver.
matched_drv=
chg_format="sed -e 's/DEVID=//' -e 's/CLASS=//' -e 's/VENDOR=//'"
IFS='
'

rescan()
{
	matched_drv=
	net_stat=0
	candi=$1
	vendor_id=`echo $candi | awk -F: '{print $8}' | cut -d'=' -f2`
	device_id=`echo $candi | awk -F: '{print $2}' | cut -d'=' -f2`
	candi_path=`echo $candi | awk -F: '{print $4}'`:$vendor_id:$device_id
	candi_drv=`echo $candi | awk -F: '{print $5}'`
	if [ $candi_drv = "unknown" ] 
	then
		candi_probe=`${base_dir}/find_driver.pl $candi_path`
			
		pfexec /usr/bin/pkg refresh >/dev/null 2>&1
		if [ $? -ne 0 ]
		then
			net_stat=1
		fi
		if [ net_stat -eq 0 ]
		then
			candi_drv=`echo $candi_probe | cut -d: -f2`	
			if [ ! -z "$candi_drv" ]
			then
				candi_drv=`pfexec pkg search -r $candi_drv 2>/dev/null | grep driver_name | tail -1 | cut -d/ -f2 | cut -d@ -f1`
			fi
			if [ ! -z "$candi_drv" ]
			then
				for ii in `pfexec pkg list -aH $candi_drv 2>/dev/null | grep -v installed | awk '{print $1}' | sort | uniq`
				do
					found_drv=`echo $ii`
					if [ "$found_drv" = "$candi_drv" ]
					then
						matched_drv=$ii
						break
					fi	
				done
			fi
		fi
		if [ -z "$matched_drv" ]
		then
			drv_type=`echo $candi_probe | cut -d: -f1`
			if [ "$drv_type" = 2 ] || [ "$drv_type" = 3 ]
			then
				net_stat=3
				matched_drv=`echo $candi_probe | cut -d: -f2`
				echo "http:"`echo $candi_probe | cut -d: -f4` > /tmp/"$matched_drv".tmp
				pfexec chmod 666 /tmp/"$matched_drv".tmp
			fi
		fi


	else
		net_stat=2
	fi
		
}

xorg_driver()
{
video_info=/tmp/video_info
temp_str=
x_log=
x_conf=
x_run=


ps -e | grep "Xorg" > /dev/null
if [ $? -eq 0 ]
then
        x_run="Xorg"
        x_log="/var/log/Xorg.0.log"
        if [ -f /etc/X11/xorg.conf ]
        then
                x_conf="/etc/X11/xorg.conf"
        elif [ -f /etc/X11/.xorg.conf ]
        then
                x_conf="/etc/X11/.xorg.conf"
        fi
fi

if [ ! -z "${x_run}" ]
then
        if [ -s ${x_log} ]
        then
                x_driver_list=`cat ${x_log} | grep "New driver is" | awk -F\" '{ print $2 }'`
                for driver_list in $x_driver_list
                do
                        if [ ! -z "${driver_list}" ]
                        then
                                if [ -z "${x_driver}" ]
                                then
                                        x_driver=$driver_list
                                fi
                        fi
                done
        fi

        if [ -z "${x_driver}" ]
        then
                if [ ! -z "${x_conf}" ] && [ -s ${x_conf} ]
                then
                        device_section_index_total=`grep -n '^Section\ \"Device\"' ${x_conf} | awk -F: '{ print $1 }'`
                        for device_section_index in ${device_section_index_total}
                        do
                                if [ ! -z "${device_section_index}" ]
                                then
                                        device_section_line=`sed -n "${device_section_index}"p ${x_conf}`
                                        while [ "${device_section_line}" != "EndSection" ]
                                        do
                                                if [ -z `echo "${device_section_line}" | sed -n '/^[ \t]*#/p'` ] && [ ! -z `echo "${device_section_line}" | grep "Driver"` ]
                                                then
#                                                       x_driver=`echo ${device_section_line} | awk -F\" '{ print $2 }'`"||""${x_driver}"
                                                        driver_list=`echo ${device_section_line} | awk -F\" '{ print $2 }'`
                                                        if [ -z "${x_driver}" ]
                                                        then
                                                                x_driver=$driver_list
                                                        fi
                                                        break
                                                fi
                                                device_section_index=`expr ${device_section_index} + 1`
                                                device_section_line=`sed -n "${device_section_index}"p ${x_conf}`
                                        done
                                fi
                        done
                fi
        fi

        if [ -z "${x_driver}" ]
        then
                x_driver=${video_driver}
        fi

        echo ${x_driver}
fi
}
network()
{
	index=0
	NIC_keywords_file=$base_dir/NIC_keywords
	#wifi_keywords_file=$base_dir/wireless_NIC_keywords

	NIC_info_file=/tmp/dvt_network_info_file
	NIC_interfaces_file=/tmp/dvt_network_NIC_interfaces_file
	all_interfaces_file=/tmp/dvt_network_all_interfaces_file
	driver_problem_file=/tmp/dvt_network_driver_problem_file

	temp_file=/tmp/dvt_network_temp
	temp_file_2=/tmp/dvt_network_temp_2
	temp_file_3=/tmp/dvt_network_temp_3
	temp_pci_path_file=/tmp/dvt_network_temp_pci_path


	# Get the keywords of NIC.
	# CLASS=00020000 indicates a device is a NIC.
	# Non-standard class code NIC is organized by 
	#     class code to improve search efficiency.

	grep "CLASS=" $NIC_keywords_file > $temp_file

	i=1
	total_IDs=`cat $temp_file | wc -l`
	while [ $i -le $total_IDs ]; do
		line=`sed -n $i'p' $temp_file`
		keys1[$i]=`echo $line | awk -F":" '{print $1}'`
		keys2[$i]=`echo $line | awk -F":" '{print $2}'`
		i=`expr $i + 1`
	done
	rm -f $temp_file

	lines=`cat $ctl_file | wc -l`
	i=1
	while [ $i -le $lines ]; do
		line=`sed -n $i'p' $ctl_file`
		j=1
		while [ $j -le $total_IDs ]; do
			result=`echo $line | grep ${keys1[$j]}`
			if [ ! -z $result ]; then
				if [ ! -z ${keys2[$j]} ]; then
					devid=`echo $line | awk -F":" '{print $2}' | cut -d'=' -f2`
					result=`echo ${keys2[$j]} | grep $devid`
				fi
			fi
			if [ ! -z $result ]; then
				echo $line >> $temp_file
				break
			fi
			j=`expr $j + 1`
		done
		i=`expr $i + 1`
	done
	rm -f $temp_file_2
	lines=
	line=


	if [ -s $temp_file ]
	then
		mv -f $temp_file $NIC_info_file

		#cat $NIC_info_file
		for i in `cat $NIC_info_file`
		do
			if [ ! -z $1 ]
			then
				rescan $i
				echo ${index}::$i:$net_stat:$matched_drv | eval $chg_format
			else
				echo ${index}::$i | eval $chg_format
			fi
				((index=index+1))
		done

		rm -f $NIC_info_file
	fi
}
storage()
{
	index=100
	c_file=/tmp/str_ctrl_file
	c_file1=/tmp/str_ctrl_file_1
	c_file2=/tmp/str_ctrl_file_2
	c_file3=/tmp/str_ctrl_file_3
	c_file4=/tmp/str_ctrl_file_4
	c_file5=/tmp/str_ctrl_file_5
	str_class_code="CLASS=000100|CLASS=000101|CLASS=000104|CLASS=000105|CLASS=000106|CLASS=000107|CLASS=000180|CLASS=000c04"

	cat $ctl_file | egrep ${str_class_code}  > $c_file

	# deal with the out put like this:
	# "American Megatrends Inc. MegaRAID:DEVID=0x1960:CLASS=00010400:/pci@3,0/pci8086,b154/pci8086,b154/pci1028,493:amr"

	# deal with same kind of controllers
	cat $c_file | awk -F: '{print $1}' | sort | uniq -c > $c_file2
	if [ ! -s $c_file2 ]
	then
		echo hcts_msg[100102,1,$c_file2]
		exit 102

	fi

	while read inline
	do
		inst=`echo $inline | awk '{print $1}'`
		if [ $inst -gt 1 ]
		then
			ctrl=`echo $inline |
	awk '
	{
		for(i=2; i<NF; i++)
		printf("%s ", $i)
		printf("%s", $i)
		printf("\n")
	}'`

			cat $c_file | fgrep "${ctrl}:" >$c_file3
			:>$c_file4
			i=1
			while [ $i -le $inst ]
			do
			    #cat $c_file3 | sed -n "$i"p | sed "s;$ctrl;${ctrl} (${i});g" >> $c_file4
			    cat $c_file3 | sed -n "$i"p | sed "s;:;(${i}) :;1" >> $c_file4
			    ((i = $i + 1))
			done
			cat $c_file | fgrep -v "${ctrl}:" > $c_file5
			cat $c_file4 $c_file5 > $c_file
		fi
	done<$c_file2



	#cat $c_file
	for i in `cat $c_file`
	do
		if [ ! -z $1 ]
		then
			rescan $i
			echo ${index}::$i:$net_stat:$matched_drv | eval $chg_format
		else
			echo ${index}::$i | eval $chg_format
		fi
			((index=index+1))
	done

	rm -f $c_file $c_file1 $c_file2 $c_file3 $c_file4 $c_file5
}
audio()
{
	index=200
	audio_class="CLASS=00040100|CLASS=00040300"

	for i in `cat $ctl_file | /usr/bin/egrep -e ${audio_class}`
	do
		if [ ! -z $1 ]
		then
			rescan $i
			echo ${index}::$i:$net_stat:$matched_drv | eval $chg_format
		else
			echo ${index}::$i | eval $chg_format
		fi
		((index=index+1))
	done
}

video()
{
	index=300
	video_class="CLASS=00030000"

	xorg_drv=`xorg_driver`
		
	for i in `cat $ctl_file | /usr/bin/grep ${video_class}` 
	do
		if [ ! -z "$xorg_drv" ]
		then
			 i="`echo $i | awk -F":" '{printf "%s:%s:%s:%s::%s:%s:%s\n", $1,$2,$3,$4,$6,$7,$8}' | eval sed 's/::/:"$xorg_drv":/g'`"
		fi
		if [ ! -z $1 ]
		then
			rescan $i
			echo ${index}::$i:$net_stat:$matched_drv | eval $chg_format
		else
			echo ${index}::$i | eval $chg_format
		fi
		((index=index+1))
	done
}
cd_dvd()
{
	index=400
	dvt_cd_dev_tmpfile=/tmp/dvt_cd_dev_tmpfile
	dvt_cd_ctl_tmpfile=/tmp/dvt_cd_ctl_tmpfile
	dvt_cd_ctl_tmpfile1=/tmp/dvt_cd_ctl_tmpfile1
	pfexec ${bin_dir}/all_devices -v -t ddi_block:cdrom | sort | uniq |awk -F')' '{print $2}' > $dvt_cd_dev_tmpfile
	rm -f $dvt_cd_ctl_tmpfile
	for i in `cat $dvt_cd_dev_tmpfile`
	do
		dev_pci_path=`echo $i | cut -d: -f4`
		pfexec ${bin_dir}/all_devices -p ${dev_pci_path} >> $dvt_cd_ctl_tmpfile
	done
	cat $dvt_cd_ctl_tmpfile 2>/dev/null | sort | uniq > $dvt_cd_ctl_tmpfile1
	for i in `cat ${dvt_cd_ctl_tmpfile1}`
	do
		ctl_pci_path=`echo $i | cut -d: -f4`
		if [ ! -z $1 ]
		then
			rescan $i
			echo ${index}::$i:$net_stat:$matched_drv | eval $chg_format
		else
			echo ${index}::$i | eval $chg_format
		fi
		p_index=${index}
		((index=index+1))
		for j in `cat ${dvt_cd_dev_tmpfile} | grep ":${ctl_pci_path}"`
		do
			echo ${index}:${p_index}:$j | awk -F":" '{printf "%s:%s:%s::%s:%s:%s:%s\n", $1,$2,$3,$6,$7,$8,$9}'
			((index=index+1))
		done
	done

	rm -f $dvt_cd_dev_tmpfile
	rm -f $dvt_cd_ctl_tmpfile
	rm -f $dvt_cd_ctl_tmpfile1
}
usb()
{
	index=500
	usb_class="CLASS=000c0300|CLASS=000c0310|CLASS=000c0320"
	temp_file1=/tmp/dvt_tmp_file1
	
	cat $ctl_file | egrep -e ${usb_class} > $temp_file1
	for i in `cat $temp_file1`
	do
		if [ ! -z $1 ]
		then
			rescan $i
			echo ${index}::$i:$net_stat:$matched_drv | eval $chg_format
		else
			echo ${index}::$i | eval $chg_format
		fi
		p_index=${index}
		((index=index+1))
		pci_path=`echo $i | cut -d: -f4`
		ctl_drv_name=`echo $i | cut -d: -f5`
		for j in `pfexec ${bin_dir}/all_devices -L  $pci_path`	
		do
			dev_pci_path=`echo $j | cut -d: -f3`
			dev_drv_name=`echo $j | cut -d: -f4`
			if [ $dev_drv_name = "usb_mid" ]
			then
				echo ${index}:${p_index}:$j 
				((index=index+1))
			else
				up_dev_pci_path=`echo $dev_pci_path | awk -F"/" '{for(i=2;i<NF;i++)
					printf("/%s",$i)}'`
				p_name=`pfexec ${bin_dir}/all_devices | grep "${up_dev_pci_path}:usb_mid"`
				if [ $? -eq 0 ]
				then
					p_name=`echo ${p_name} | sed 's/^	*(Dev)//' | cut -d: -f1`
					echo "${index}:${p_index}:(${p_name})${j}"
					((index=index+1))
				else
					echo ${index}:${p_index}:${j}
					((index=index+1))
				fi
			fi
		 done
	done

	rm -f $temp_file1
}
battery()
{
	index=700
	battery_tmpfile=/tmp/battery_tmpfile
	battery_tmpfile1=/tmp/battery_tmpfile1
	battery_tmpfile2=/tmp/battery_tmpfile2
	if [ -f ${bin_dir}/bat_detect ]
	then
		${bin_dir}/bat_detect -l > $battery_tmpfile
		for i in `cat $battery_tmpfile`
		do
			${bin_dir}/bat_detect -d $i > $battery_tmpfile1
			vendor=`grep battery.vendor $battery_tmpfile1 | cut -d: -f2 | tr -d \'`
			model=`grep battery.model $battery_tmpfile1 | cut -d: -f2 | tr -d \' | tr -d ' '`
			tech=`grep battery.reporting.technology $battery_tmpfile1 | cut -d: -f2 | tr -d \'`
			per=`grep battery.charge_level.percentage $battery_tmpfile1 | cut -d: -f2 | tr -d \'`
			charge_des=`grep battery.charge_level.design $battery_tmpfile1 | cut -d: -f2 | tr -d \'`
			charge_cur=`grep battery.charge_level.current $battery_tmpfile1 | cut -d: -f2 | tr -d \'`
			echo "scale = 1" > $battery_tmpfile2
			echo "$charge_des/1000" >> $battery_tmpfile2
			charge_des=`bc < $battery_tmpfile2`
			echo "scale = 1" > $battery_tmpfile2
			echo "$charge_cur/1000" >> $battery_tmpfile2
			charge_cur=`bc < $battery_tmpfile2`
			dev_path=$i
			driver=`grep info.solaris.driver  $battery_tmpfile1 | cut -d: -f2 | tr -d \'`
			echo ${index}::${vendor} ${charge_des}Wh ${tech} ${model} \( ${per}%  ${charge_cur}Wh \):::${dev_path}:${driver}:0:Attached:
			((index=index+1))
		done
		rm -f $battery_tmpfile $battery_tmpfile1 $battery_tmpfile2
	fi
}
cpu()
{
	index=800
	cpu_tmpfile=/tmp/cpu_tmpfile
	cpu_tmpfile1=/tmp/cpu_tmpfile1
	cpu_num=`${bin_dir}/dmi_info -C | grep "CPU Number" | cut -d":" -f2` 
	cpu_type=`${bin_dir}/dmi_info -C | grep "CPU Type" | cut -d":" -f2` 
	cpu_core=`${bin_dir}/dmi_info -C | grep "cores" | cut -d":" -f2` 

	echo ${index}::${cpu_num} X ${cpu_type}, ${cpu_core}-core:::cpu:---:0:Attached:
}
memory()
{
	index=801
	phy_mem=`${bin_dir}/dmi_info -m | grep "Physical Memory" | cut -d: -f2`
	max_mem=`${bin_dir}/dmi_info -m | grep "Maximum Memory Support" | cut -d: -f2`
	if [ ! -z "$max_mem" ]
	then
		max_mem="; $max_mem maximum"
	fi

	echo ${index}::${phy_mem} ${max_mem}:::memory:---:0:Attached:
}
others()
{
	index=600
	other_class="CLASS=00030000|CLASS=000c0300|CLASS=000c0310|CLASS=000c0320|CLASS=00040100|CLASS=00040300|CLASS=000100|CLASS=000101|CLASS=000104|CLASS=000105|CLASS=000106|CLASS=000107|CLASS=000180|CLASS=000c04|CLASS=0006|CLASS=00020000|CLASS=00028000|CLASS=0005|CLASS=0008|CLASS=000a|CLASS=000b"
	for i in `cat $ctl_file | egrep -v -e ${other_class}`
	do
		if [ ! -z $1 ]
		then
			rescan $i
			echo ${index}::$i:$net_stat:$matched_drv | eval $chg_format
		else
			echo ${index}::$i | eval $chg_format
		fi
		((index=index+1))
	done
}

init()
{
	pfexec ${bin_dir}/all_devices -s 
}

#Main()


if [ "$1" = "network" ]
then
	pfexec ${bin_dir}/all_devices -c | egrep -v 'CLASS=0000|CLASS=0005|CLASS=000b|CLASS=000c05|CLASS=000380|CLASS=0008|^Motherboard' > $ctl_file
fi
if [ ! -s "$ctl_file" ]
then
	pfexec ${bin_dir}/all_devices -c | egrep -v 'CLASS=0000|CLASS=0005|CLASS=000b|CLASS=000c05|CLASS=000380|CLASS=0008|^Motherboard' > $ctl_file
fi

chmod 666 $ctl_file 2>/dev/null

if [ "$2" = "rescan" ] 
then
	$1 $2
else
	$1
fi

rm -f $ctl_file 2>/dev/null
