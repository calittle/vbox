#!/bin/bash
# VirtualBox Control Script

title="VBox Virtual Machine Control Panel"
prompt="Select an option: "
options=("Start VM" "Stop VM" "Reset VM" "Hibernate VM")
VMNAME=$1
if [ -z "$VMNAME" ]
  then
    	echo "Usage: vb <virtual machine name>"
    	echo "Virtual Machines:"
	VBoxManage list vms   
 exit
fi


echo "$title"
PS3="$prompt"

function getState {
STATE=$(VBoxManage showvminfo $VMNAME --machinereadable | grep 'VMState=' | cut -d '"' -f2)
echo The virtual machine $VMNAME is currently $STATE.
}
getState
select opt in "${options[@]}" "Quit"; do
	case "$REPLY" in
		1)
			echo $opt
			if [ $STATE != "running" ]
			  then
				echo Starting $VMNAME...			
				nohup VBoxHeadless --startvm $VMNAME &
			else
				echo $VMNAME is already running. Ignoring useless command.
			fi
			;;
		3)
			echo $opt
                        if [ $STATE != "running" ]
                          then
                                echo $VMNAME is not running. Ignoring useless command.
                          else
                        read -r -p "Are you sure? [y/N] " response
                        response=${response,,}    # tolower
                        if [[ "$response" =~ ^(yes|y)$ ]]
                          then
                                VBoxManage controlvm $VMNAME reset
                        fi
                        fi
                        ;;
		2)
			echo $opt
			if [ $STATE != "running" ]
			  then
				echo $VMNAME is not running. Ignoring useless command.
			  else
			read -r -p "Are you sure? [y/N] " response
			response=${response,,}    # tolower
			if [[ "$response" =~ ^(yes|y)$ ]]
			  then
				VBoxManage controlvm $VMNAME poweroff
			fi
			fi
			;;
		4)
			echo $opt
			if [ $STATE != "running" ]
                          then
                                echo $VMNAME is not running. Ignoring useless command.
                          else
                        read -r -p "Are you sure? [y/N] " response
                        response=${response,,}    # tolower
                        if [[ "$response" =~ ^(yes|y)$ ]]
                          then
                                VBoxManage controlvm $VMNAME savestate
                        fi
                        fi
                        ;;
		$(( ${#options[@]}+1 )) )
			echo Goodbye.
			break
			;;
		*) echo Invalid option;continue;;
	esac
	REPLY=
	getState
done

