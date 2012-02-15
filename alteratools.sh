#!/bin/bash


mode="$1"
DEFAULT_SOPCINFO="/home/miago/zhaw/BA/versions/lcd/fpga/linsoft.sopcinfo"
DEFAULT_DTS="/home/miago/zhaw/BA/versions/lcd/linux/device.dts"

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
	

	;;
	"sof")
	echo "program fpga"
	;;
	"nios")
	echo "program nios"
	;;
esac

exit 0
