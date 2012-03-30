#!/bin/bash

mode="$1"
BASEL="/home/miago/nios2-linux/uClinux-dist"
SOPCINFOL="${BASEL}/fpga/linsoft.sopcinfo"
DTSL="${BASEL}/dts/device.dts"
MDTSL="${BASEL}/dts/mod_device.dts"
SOFL="${BASEL}/fpga/linsoft_time_limited.sof"
ZIMAGEL="${BASEL}/images/zImage.initramfs.gz"
QSYSL="${BASEL}/fpga/linsoft.qsys"
QPFL="${BASEL}/fpga/linsoft.qpf"
QSFL="${BASEL}/fpga/linsoft.qsf"
TOPL="${BASEL}/fpga/top.v"
NIOSHL="${BASEL}/../linux-2.6/arch/nios2/include/asm/nios.h"
CONFL="${BASEL}/linux-2.6.x/.config"

#Banner
echo " _______       _______ _______ _______ _____   _______ "
echo "|   _   |_____|_     _|       |       |     |_|     __|"
echo "|       |______||   | |   -   |   -   |       |__     |"
echo "|___|___|       |___| |_______|_______|_______|_______|"

case "$mode" in
	"dts")
	echo "dts generation tool with sopc2dts"

	if [ -a "$SOPCINFOL" ]; then
		echo "$SOPCINFOL does exist"
	else 
		echo "$SOPCINFOL does not exist"
		exit 1
	fi
	
	java -jar /home/miago/sopc2dts/tools/sopc2dts/sopc2dts.jar -i $SOPCINFOL -o $DTSL

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
	
	nios2-download -g -r $DEFAULT_PROJECT_ZIM
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
			/home/miago/altera/11.1sp2/quartus/sopc_builder/bin/qsys-edit "$QSYSL" && exit
		else
			#check for file sopcinfo
			if [ -a "$SOPCINFOL" ]; then
				echo "sopcinfo file last edited at:"
				stat -c %z $SOPCINFOL
			else
				echo "WARNING: sopcinfo file does not exist"
			fi
		fi
		
		#Quartus
		echo "did you change something in the QUARTUS project? [y/N]"
		read ans
		if ([ "$ans" == 'y' ]); then
			quartus "$QPFL" && exit
		else
			#check for file top file
			if [ -a "$TOPL" ]; then
				echo "top file last edited at:"
				stat -c %z $TOPL
			else
				echo "WARNING: top file does not exist"
			fi
		fi	
		
		#Dts file
		echo "does the DTS file need to be updated? [y/N]"
		read ans
		if ([ "$ans" == 'y' ]); then
			java -jar /home/miago/sopc2dts/tools/sopc2dts/sopc2dts.jar -i $SOPCINFOL -o $DTSL && exit
		else
			#check for dts file
			if [ -a "$DTSL" ]; then
				echo "dts file last edited at:"
				stat -c %z $DTSL
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
			if [ -a "$ZIMAGEL" ]; then
				echo "Project zImage edited at:"
				stat -c %z $ZIMAGEL
			else
				echo "WARNING: Project zImage does not exist"
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
			gnome-terminal -e "bash -c \"nios2-configure-sof $SOFL; exec bash\""&
		fi
	
		#download kernel
		echo "do you want me to download the kernel? [Y/n]"
		read ans
		if ([ -z "$ans" ] || [ "$ans" == 'y' ]); then
			nios2-download -g -r $ZIMAGEL 
		fi		
	;;
	"backup")
		#creates a zip file w the most important files
		tar zcvf backup.tar.gz $DTSL $SOPCINFOL $TOPL $NIOSHL $CONFL $QPFL $QSFL 
	;;
	
	"meld")
	
		echo "MELD DTS FILES"
		
		meld $DTSL $MDTSL
		
	
	;;
	
	"quartus")
	
		echo "OPEN QUARTUS PROJECT"
		
		quartus $QPFL
		
	
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
