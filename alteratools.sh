#!/bin/bash


mode="$1"
DEFAULT_SOPCINFO="/home/miago/zhaw/BA/project/fpga/linsoft.sopcinfo"
DEFAULT_DTS="/home/miago/zhaw/BA/project/linux/device.dts"
DEFAULT_SOF_1="/home/miago/zhaw/BA/project/fpga/linsoft_time_limited.sof"
DEFAULT_SOF_2="/home/miago/zhaw/BA/project/fpga/linsoft.sof"
DEFAULT_PROJECT_ZIM="/home/miago/zhaw/BA/project/linux/zImage.initramfs.gz"
DEFAULT_DIRECT_ZIM="/home/miago/nios2-linux/uClinux-dist/images/zImage.initramfs.gz"

if [ -z "$mode" ]; then
	echo "no oop"
fi

case "$mode" in
	"dts")
	echo "dts generation tool with sopc2dts"
	echo "sopcinfo file (default $DEFAULT_SOPCINFO): "
	read location
	
	if [ -z "$location" ]; then
		echo "assume default location $DEFAULT_SOPCINFO"
		location=$DEFAULT_SOPCINFO
	else
		echo "use provided location $location"
	fi
	
	if [ -a "$location" ]; then
		echo "$location does exist"
	else 
		echo "$location does not exist"
		exit 1
	fi
	
	java -jar /home/miago/sopc2dts/tools/sopc2dts/sopc2dts.jar -i $location -o $DEFAULT_DTS
	
	meld /home/miago/zhaw/BA/project/linux/device.dts /home/miago/zhaw/BA/project/linux/mod_device.dts

	;;
	
	"sof")
	echo "Program SOF to Board"
	
	if [ -a "$DEFAULT_SOF_1" ]; then
		nios2-configure-sof $DEFAULT_SOF_1	
	else 
		nios2-configure-sof $DEFAULT_SOF_1
	fi 
	;;
	
	"nios")
	echo "program nios"
	nios2-download -g -r $DEFAULT_ZIM
	;;
	
	"status")
	echo "                file status" 
	echo "--------------------------------------------" 
	#sof
	if [ -a "$DEFAULT_SOF_1" ]; then
		echo "sof file last edited at:"
		stat -c %z $DEFAULT_SOF_1
	else
		echo "sof file does not exist <-------------------"
	fi
	#sopcinfo
	if [ -a "$DEFAULT_SOPCINFO" ]; then
		echo "sopcinfo file last edited at:"
		stat -c %z $DEFAULT_SOPCINFO
	else
		echo "sopcinfo file does not exist <--------------"
	fi
	#dts
	if [ -a "$DEFAULT_DTS" ]; then
		echo "dts file last edited at:"
		stat -c %z $DEFAULT_DTS
	else
		echo "dts file does not exist <-------------------"
	fi
	#zImage project
	if [ -a "$DEFAULT_PROJECT_ZIM" ]; then
		echo "zImage project"
		stat -c %z $DEFAULT_PROJECT_ZIM
	else
		echo "project zim file does not exist <-----------"
	fi
	#zImage direct
	if [ -a "$DEFAULT_DIRECT_ZIM" ]; then
		echo "zImage direct"
		stat -c %z $DEFAULT_DIRECT_ZIM
	else
		echo "direct zim file does not exist <------------"
	fi
	echo "--------------------------------------------"
	;;
esac

exit 0
