#!/bin/bash

echo "OSSA Finder OIC&APEX files"
echo " * Current Version 1.3 * "
#
# History
# =====================================
# Version 1.2b Américo Moura
# Version 1.3b Corvalan / Valentinuzzi
# Version 1.3 Corvalan / Valentinuzzi
# Version 1.4 Valentinuzzi
# =====================================

# VARIABLES
os=$(uname -a)
start_time=$SECONDS
# END VARIABLES

# FUNCTIONS
print_elapsed (){
	if [[ "${os,,}" == *"linux"* ]]; then	   
	   eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"
	elif [[ "${os,,}" == *"sunos"* ]]; then
		eval "echo Elapsed time: $(gdate -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"
	else
	   echo "There are no time metrics available on this OS"
	fi
}

get_distribution_type()
{
    #local dtype
    # Assume unknown
    dtype="unknown"

    # First test against Fedora / RHEL / CentOS / generic Redhat derivative
    if [ -r /etc/rc.d/init.d/functions ]; then
        source /etc/rc.d/init.d/functions
        [ zz`type -t passed 2>/dev/null` == "zzfunction" ] && dtype="redhat"

    # Then test against SUSE (must be after Redhat,
    # I've seen rc.status on Ubuntu I think? TODO: Recheck that)
    elif [ -r /etc/rc.status ]; then
        source /etc/rc.status
        [ zz`type -t rc_reset 2>/dev/null` == "zzfunction" ] && dtype="suse"

    # Then test against Debian, Ubuntu and friends
    elif [ -r /lib/lsb/init-functions ]; then
        source /lib/lsb/init-functions
        [ zz`type -t log_begin_msg 2>/dev/null` == "zzfunction" ] && dtype="debian"

    # Then test against Gentoo
    elif [ -r /etc/init.d/functions.sh ]; then
        source /etc/init.d/functions.sh
        [ zz`type -t ebegin 2>/dev/null` == "zzfunction" ] && dtype="gentoo"

    # For Slackware we currently just test if /etc/slackware-version exists
    # and isn't empty (TODO: Find a better way :)
    elif [ -s /etc/slackware-version ]; then
        dtype="slackware"
    fi
    echo $dtype
}
# END FUNCTIONS

################################################################################################
# CAREFULLY CHECK THAT THE FILE TO BE PARSED IS UTF-8 ENCODED AND 'LF' END OF LINE MODE (UNIX) #
################################################################################################

echo "[`date`] ==== Validating prerequisites... ===="

#sudo apt install unzip
#mkdir processed
#mkdir temp_to_delete
#mkdir results

get_distribution_type
echo "DISTRO BASED ON: ${dtype}"

if [ "${dtype}" = "redhat" ] || [ "${dtype}" = "suse" ]; then
	{ # try
		sudo dnf install unzip
		##command1 &&
		#save your output
	} || { # catch
		sudo yum install unzip
		# save log for exception 
	}
elif  [ "${dtype}" = "debian" ]; then
	sudo apt install unzip
elif  [ "${dtype}" = "gentoo" ]; then
	sudo emerge -av unzip
elif  [ "${dtype}" = "archlinux" ]; then
	sudo pacman -S unzip
else
	echo "unsupported distro"
	#slackware
	#sudo installpkg unzip.txz #?
	exit 1
fi


[ ! -d "processed/" ] && mkdir -p "processed/"
[ ! -d "temp_to_delete/" ] && mkdir -p "temp_to_delete/"
[ ! -d "results/" ] && mkdir -p "results/"
# END PREREQUISITES


echo "[`date`] ==== Start verification ===="
echo " "
echo "[`date`] ==== Converting and processing... ===="
for file in *.iar
do
	newname=$(basename $file iar)zip
	cp $file "IAR_$newname"
	mv $file processed/
done

for file in *.par
do
	newname=$(basename $file par)zip
	cp $file "PAR_$newname"
	mv $file processed/
done

echo "[`date`] ==== Searching... ===="

for filename in *.zip
do
	partial_time=$SECONDS
	echo "[`date`] ==== File: ${filename} ===="
#ReadFile Dicc			
	while read line 
	do	
	#newline = "${line/$'\r'/}"  --saca el $ y el carriage pero no le gusta al zipgrep
    newline="${line}"   #--NOTA_GIU:siempre usar wordlist unix sino aparece lo siguiente: result:zipgrep -i $'password\r' IAR_INT_012_01.00.0006.zip
	#
	
	zipgrep -i $newline "${filename}" >> "log_${filename}.out"	
	
	done < wordlist_finderOSSA.txt;
	
#End ReadFile	
	elapsed=$(( SECONDS - partial_time ))
	print_elapsed
	echo " "
done

mv *zip temp_to_delete/
mv *out results/

echo "TOTAL ELAPSED TIME: "
elapsed=$(( SECONDS - start_time ))
print_elapsed
echo " "

echo "All occurrences are in 'results/' folder as .out files."
echo "You can delete all the .zip files that were created in 'temp_to_delete/'"
echo " "
echo "[`date`] ==== END VERIFICATION ===="
#exit
#-----------------------------------------------------------------------------------------------------------------------------

	
	
	