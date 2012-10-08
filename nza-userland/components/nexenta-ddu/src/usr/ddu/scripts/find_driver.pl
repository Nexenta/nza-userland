#!/usr/bin/perl
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
# ident "@(#)find_driver.pl 1.11 09/02/24 SMI"
#

use strict;

my $exepath=`dirname $0`;
chop($exepath);
my $drvinfo_file = $exepath . "/driver.db";
my $output_file = "/tmp/dvt_ctl_info_file";
# define the index in component array:
my $i_class_code = 0;
my $i_vendor_id = 1;
my $i_device_id = 2;
my $i_subsystem_vendor_id = 3;
my $i_subsystem_id = 4;
my $i_pciclass_1 = 5;
my $i_pciclass_2 = 6;
my $i_model_name = 7;

my $i_revision_id = 8;
# define the index in result array (comparray):
my $i_driver = 9;
my $i_vendor_name = 10;
my $i_device_name = 11;
my $i_driver_name = 12;
my $i_driver_location = 13;
my $i_driver_version = 14;
my $i_driver_bit=15;

# define the result for driver
my $driver_yes = 1;
my $driver_3 = 2;
my $driver_o = 3;
my $driver_no = 4;

# using hash variable to define driver result string with length 1
my %driver_str_array = (
$driver_yes, "Y",
$driver_3, "T",	#Third-Party Driver
$driver_o, "O",	#Opensolaris Driver
$driver_no, "N"
);

my %driver_str_array_all = (
$driver_yes, "Solaris Driver Found",
$driver_3, "Third-Party Driver",
$driver_o, "Opensolaris Driver",
$driver_no, "No Solaris Driver"
);

# define the index in third party driver array (tpd_array):
my $tpd_name = 0;
my $tpd_location = 1;

# tpd_ for third party driver.
my $tpd_count = 0;
my @tpd_array; # record all the tpd name.

# installation notes.
my $inst_notes_num = 0;
my @inst_notes_array; # record all installation related notes.

# array for devices infomation
my (@comparray, $compnum);

# nVidia network devices with non-standard class code
my @nvidia_nic=("37", "38", "56", "57", "86", "8c", "df", "e6", "1c3", "268", "269", "372", "373", "3e5", "3e6", "3ee", "3ef", "450", "451", "452", "453");

# Find out whether item $i has driver on solaris
# return $driver_yes for yes, $driver_no for no, $driver_3 for 3rd-party driver, $driver_o for opensolaris driver.
sub find_driver()
{
    my (@tmparray, $line, $position, $bufferline, $found, $old_found, $i, $third_party, $xorg_drv);


    my $device_id = $comparray[$i_device_id];
    my $vendor_id = $comparray[$i_vendor_id];
    
    my $class_code = $comparray[$i_class_code];

    my $subsystem_vendor_id = $comparray[$i_subsystem_vendor_id];
    my $subsystem_id = $comparray[$i_subsystem_id];

    my $revision_id = $comparray[$i_revision_id];
    $revision_id =~ s/^0+//;		        

    my $pci_allids = "pci$vendor_id\,$device_id\.$subsystem_vendor_id\.$subsystem_id\.$revision_id";
    my $pci_fullids = "pci$vendor_id\,$device_id\.$subsystem_vendor_id\.$subsystem_id";
    my $pci_subids = "pci$subsystem_vendor_id\,$subsystem_id";
    my $pci_revids = "pci$vendor_id\,$device_id\.$revision_id";
    my $pci_ids = "pci$vendor_id\,$device_id";
    

    my $pciclass_1 = substr($class_code, 2);
    my $classcode = $pciclass_1;
    $pciclass_1 = "pciclass,$pciclass_1";
    my $pciclass_2 = substr($class_code, 2, 4);
    $pciclass_2 = "pciclass,$pciclass_2";


#remove all the zeros padding in $vendor_id, $device_id, $subsystem_vendor_id, $subsystem_id, and then compare again.
    $vendor_id =~ s/^0+//;
    $device_id =~ s/^0+//;
    $subsystem_vendor_id =~ s/^0+//;
    $subsystem_id =~ s/^0+//;

    my $pci_allids_2 = "pci$vendor_id\,$device_id\.$subsystem_vendor_id\.$subsystem_id\.$revision_id";  
    my $pci_fullids_2 = "pci$vendor_id\,$device_id\.$subsystem_vendor_id\.$subsystem_id";
    my $pci_subids_2 = "pci$subsystem_vendor_id\,$subsystem_id";
    my $pci_revids_2 = "pci$vendor_id\,$device_id\.$revision_id";
    my $pci_ids_2 = "pci$vendor_id\,$device_id";

    my @keywords;
    $keywords[13] = $pci_allids;
    $keywords[12] = $pci_allids_2;
    $keywords[11] = $pci_fullids; 
    $keywords[10] = $pci_fullids_2;
    $keywords[9] = $pci_subids;
    $keywords[8] = $pci_subids_2;
    $keywords[7] = $pci_revids;
    $keywords[6] = $pci_revids_2;
    $keywords[5] = $pci_ids;
    $keywords[4] = $pci_ids_2;
    $keywords[3] = $pciclass_1;
    $keywords[2] = "";
    $keywords[1] = $pciclass_2;
    $keywords[0] = "";

    my @record_items;

    unless (open (FP, $drvinfo_file)) {
        die "Error: cannot open file: $drvinfo_file\n";
    }

    $found = 0; 
    $old_found = 0;
    $third_party = 0;     
   
    while ( $line = <FP> ) { # Read one line each time
        chop ($line);        

	@record_items = split (/\t/, $line);

        # All Solaris driver records have been searched, 
        # and the first 3rd-party record is being read.        
	if (($record_items[2] eq "T") && ($third_party == 0))        
        {
             $third_party = 1; 
             if (($old_found > 0) && ($bufferline !=~ /vgatext/))
             {
                  $line = $bufferline;   
                  goto FOUND_DRV;
            }   
        }

        $found = 0;
  
        $i = 7;
	while (($i > 0) && ($found == 0))         
        {
	   if (($record_items[0] eq $keywords[$i*2 -1]) or ($record_items[0] eq $keywords[$i*2-2]))
            {
		$found = $i;
            }

            $i = $i -1;	
        }

        if ($found != 0)  #Anomly handling
	{
            if ( $line =~ /^pciclass,0180/ ) #Only work for these 3 devices. 
            { 
	            if ( $comparray[$i_vendor_id] != 1095 or 
                         not $comparray[$i_device_id] =~ /3112|3114|3512/ ) 
                    {
		               $found = 0;
	            }
            }
	}

        if ($found != 0) #Anomly handling
	{
            if ($record_items[1] eq "e1000g") 
            {
                    if (not $classcode eq "020000")
		    {	
                        $found = 0;
                    }
            }
        }

	if ($found != 0) #Anomly handling
	{
            if ($record_items[1] eq "aac") 
            {
                    if ( not $classcode =~ /^0104/ )
		    {	
                        $found = 0;
                    }
            }
        }

	if ($found == 7)
	{ 
FOUND_DRV:
	    close(FP);
            @tmparray = split (/\t/, $line);
	
	    $comparray[$i_driver_name] = $tmparray[1];
	    $comparray[$i_driver_bit] = $tmparray[3];
            $comparray[$i_driver_location] = $tmparray[4];

	    my $driver_status = $tmparray[2];
	

            if ($driver_status eq "T") { # third-party driver
		    return ($driver_3);
            } elsif ($driver_status eq "S") {	# solaris driver
                return ($driver_yes);
            } elsif ($driver_status eq "O") {	# solaris driver
                return ($driver_o);
            } else {	# bad driver.db
                die "Error: bad driver.db\n" ;
            }

        }
        elsif ($old_found < $found) 
        {
		$old_found = $found;
                $bufferline = $line;
        }
        else
        {
		$found = $old_found;
        }  
	

    } # end while
    
    if ($found > 0)	
    {
	$line = $bufferline;
	
	goto FOUND_DRV;
    }
    else
    {
    	close(FP);
    	$comparray[$i_driver_bit] = "N";
    	return ($driver_no);
    }	
}

# Generate device_name, save it in array $comparry.
# Get driver status, save it in the array.
sub analyse()
{
    my ($i, $vendor_id, $device_id, $class_code);

	# nVidia network controllers do not use standard classcode
	# correct this with these codes.
	$vendor_id = $comparray[$i_vendor_id] ;
	$device_id = $comparray[$i_device_id] ;
	$device_id =~ s/^0+//;	# Remove 00 
	if ( $vendor_id eq "10de" ) {
            for (@nvidia_nic) {
                if ( $_ eq $device_id ) {
                        $comparray[$i_class_code] = "00020000" ;
                }
            }
	}

        $class_code = $comparray[$i_class_code];

        if ($class_code eq "00060000") { # host bridge
            #$comparray[$i_driver] = $driver_yes; # Ignore bridges
            $comparray[$i_driver] = $driver_no; # Ignore bridges
        } 
        else {
            $comparray[$i_driver] = find_driver();
        } #end if
       printf  "$comparray[$i_driver]:$comparray[$i_driver_name]:$comparray[$i_driver_location]:$comparray[$i_driver_bit]\n";
       
	
}
sub auto_check()
{

    my @tmparray; 
    my $line;
    if (!open(fp_prt, $output_file)) {
        die "Internal error, generated $output_file missing!\n" ;
    }

    while ( $line = <fp_prt> ) {
        if ( $line =~ /class-code:/ ) {	#find compatible list
           @tmparray = split (/:/, $line);
	   chomp $tmparray[1];
           $tmparray[1] = sprintf("%08s",$tmparray[1]) ;	
           $comparray[$i_class_code] = $tmparray[1] ;
	   $comparray[$i_pciclass_1] = substr($tmparray[1],2,4) ;
	   $comparray[$i_pciclass_2] = substr($tmparray[1],2,6) ;
        }
        elsif ( $line =~ /device-id:/ ) {
           @tmparray = split (/:/, $line) ;
	   chomp $tmparray[1];
           $comparray[$i_device_id] = $tmparray[1] ;
            
        }
        elsif ( $line =~ /subsystem-id:/ ) {
           @tmparray = split (/:/, $line) ;
	   chomp $tmparray[1];
           $comparray[$i_subsystem_id] = sprintf("%04s",$tmparray[1]) ;
        }
        elsif ( $line =~ /subsystem-vendor-id:/ ) {
           @tmparray = split (/:/, $line) ;
	   chomp $tmparray[1];
           $comparray[$i_subsystem_vendor_id] = sprintf("%04s",$tmparray[1]);
        }
        elsif ( $line =~ /vendor-id:/ ) {
           @tmparray = split (/:/, $line) ;
	   chomp $tmparray[1];
           $comparray[$i_vendor_id] = sprintf("%04s",$tmparray[1]) ;
        }
	elsif ( $line =~ /revision-id:/ ){
           @tmparray = split (/:/, $line) ;
	   chomp $tmparray[1];
	   $tmparray[1] = sprintf("%08s",$tmparray[1]) ;
           $comparray[$i_revision_id] = substr($tmparray[1], 6, 2);		
        }
    } #end of while
    close (fp_prt);
}
my $command_dir=`dirname $0`;
chomp $command_dir;
$command_dir=~  s/scripts$/bin/;
my $platform=`uname -p`;
chomp $platform;

`$command_dir/all_devices -v -d $ARGV[0] > $output_file`;
auto_check();
analyse();
`rm -f $output_file`;
