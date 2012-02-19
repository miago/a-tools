#!/bin/bash

mode="$1"
DEFAULT_SOPCINFO="/home/miago/zhaw/BA/project/fpga/linsoft.sopcinfo"
DEFAULT_DTS="/home/miago/zhaw/BA/project/linux/device.dts"
DEFAULT_SOF="/home/miago/zhaw/BA/project/fpga/linsoft_time_limited.sof"
DEFAULT_PROJECT_ZIM="/home/miago/zhaw/BA/project/linux/zImage.initramfs.gz"
DEFAULT_DIRECT_ZIM="/home/miago/nios2-linux/uClinux-dist/images/zImage.initramfs.gz"
QSYS_LOCATION="/home/miago/zhaw/BA/project/fpga/linsoft.qsys"
QPF_LOCATION="/home/miago/zhaw/BA/project/fpga/linsoft.qpf"

#Banner
echo " _______       _______ _______ _______ _____   _______ "
echo "|   _   |_____|_     _|       |       |     |_|     __|"
echo "|       |______||   | |   -   |   -   |       |__     |"
echo "|___|___|       |___| |_______|_______|_______|_______|"

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
	
	meld $DEFAULT_DTS /home/miago/zhaw/BA/project/linux/mod_device.dts

	;;
	
	"sof")
	echo "Program SOF to Board"
	
	if [ -a "$DEFAULT_SOF" ]; then
		nios2-configure-sof $DEFAULT_SOF	
	else 
		nios2-configure-sof $DEFAULT_SOF
	fi 
	;;
	
	"nios")
	echo "program nios"
	#Don't know if it works correctly	
	export PATH=$PATH:/home/miago/altera/11.1sp2/nios2eds/bin:/home/miago/altera/11.1sp2/nios2eds/sdk2/bin
	export PATH=$PATH:/home/miago/altera/11.1sp2/nios2eds/bin/gnu/H-i686-pc-linux-gnu/bin
	
	nios2-download -g -r $DEFAULT_ZIM
	;;
	
	"status")
	echo "                file status" 
	echo "--------------------------------------------" 
	#sof
	if [ -a "$DEFAULT_SOF" ]; then
		echo "sof file last edited at:"
		stat -c %z $DEFAULT_SOF
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
	"flow")
		#Qsys
		echo "did you change QSYS project? [y/N]"
		read ans
		if ([ "$ans" == 'y' ]); then
			/home/miago/altera/11.1sp1/quartus/sopc_builder/bin/qsys-edit "$QSYS_LOCATION" && exit
		else
			#check for file sopcinfo
			if [ -a "$DEFAULT_SOPCINFO" ]; then
				echo "sopcinfo file last edited at:"
				stat -c %z $DEFAULT_SOPCINFO
			else
				echo "WARNING: sopcinfo file does not exist"
			fi
		fi
		
		#Quartus
		echo "did you change something in the QUARTUS project? [y/N]"
		read ans
		if ([ "$ans" == 'y' ]); then
			quartus "$QOF_LOCATION" && exit
		else
			#check for file top file
			if [ -a "/home/miago/zhaw/BA/project/fpga/top.v" ]; then
				echo "top file last edited at:"
				stat -c %z /home/miago/zhaw/BA/project/fpga/top.v
			else
				echo "WARNING: top file does not exist"
			fi
		fi	
		
		#Dts file
		echo "does the DTS file need to be updated? [y/N]"
		read ans
		if ([ "$ans" == 'y' ]); then
			java -jar /home/miago/sopc2dts/tools/sopc2dts/sopc2dts.jar -i $DEFAULT_SOPCINFO -o $DEFAULT_DTS && exit
		else
			#check for dts file
			if [ -a "$DEFAULT_DTS" ]; then
				echo "dts file last edited at:"
				stat -c %z $DEFAULT_DTS
			else
				echo "WARNING: dts file does not exist"
			fi
		fi
		
		#meld
		
		
		#ZIMAGE file
		echo "does the KERNEL need to be rebuilt? [y/N]"
		read ans
		if ([ "$ans" == 'y' ]); then
			cd ~/nios2-linux/uClinux-dist && make menuconfig
		else
			#check for project zimage file
			if [ -a "$DEFAULT_PROJECT_ZIM" ]; then
				echo "Project zImage edited at:"
				stat -c %z $DEFAULT_PROJECT_ZIM
			else
				echo "WARNING: Project zImage does not exist"
			fi
			
			#check for direct zimage file
			if [ -a "$DEFAULT_DIRECT_ZIM" ]; then
				echo "Direct zImage edited at:"
				stat -c %z $DEFAULT_DIRECT_ZIM
			else
				echo "WARNING: Direct zImage does not exist"
			fi
		fi
		
		#serial console
		echo "do you want me to open a minicom console for you? [Y/n]"
		read ans
		if ([ -z "$ans" ] || [ "$ans" == 'y' ]); then
			gnome-terminal -e "bash -c \"minicom; exec bash\""&
		fi
		
		#configure sof
		echo "do you want me to open a new terminal to configure the sof? [Y/n]"
		read ans
		if ([ -z "$ans" ] || [ "$ans" == 'y' ]); then
			gnome-terminal -e "bash -c \"nios2-configure-sof $DEFAULT_SOF; exec bash\""&
		fi
	
		#download kernel
		echo "do you want me to download the kernel? [Y/n]"
		read ans
		if ([ -z "$ans" ] || [ "$ans" == 'y' ]); then
			export PATH=$PATH:/home/miago/altera/11.1sp2/nios2eds/bin:/home/miago/altera/11.1sp2/nios2eds/sdk2/bin
			export PATH=$PATH:/home/miago/altera/11.1sp2/nios2eds/bin/gnu/H-i686-pc-linux-gnu/bin
			nios2-download -g -r $DEFAULT_PROJECT_ZIM 
		fi		
	;;
	*)
	echo "valid arguments:"
        echo "dts: generate new dts file end open meld"
        echo "sof: program sof"
        echo "nios: download software to nios2"
        echo "status: display status of several files"
        echo "flow: guide to all required steps"
	;;
esac

exit 0
