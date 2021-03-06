#!/bin/bash
#
# Simple VirtualBox menu control using dialog
#

INPUT=/tmp/menu.sh.$$
STATE=
VMNAME=
OUTPUT=/tmp/output.sh.$$
OUTPUT1=/tmp/output1.sh.$$

trap "rm $OUTPUT1; rm $OUTPUT; rm $INPUT; exit" SIGHUP SIGINT SIGTERM
function bug(){
echo "        _ _ _       _    ___  ";
echo "       | (_) |     | |  |__ \ ";
echo "   __ _| |_| |_ ___| |__   ) |";
echo "  / _\` | | | __/ __| '_ \ / / ";
echo " | (_| | | | || (__| | | |_|  ";
echo "  \__, |_|_|\__\___|_| |_(_)  ";
echo "   __/ |                      ";
echo "  |___/                       ";
}
function killvm(){
        if [ $STATE != "running" ]
          then
                dialog --title "Warning" --msgbox "${VMNAME} is not running; cannot shutdown." 5 55
          else
                dialog --title "Confirm" --yesno "Really power off $VMNAME?" 5 55
                if [ $? = 0 ]
                  then
                        dialog --title "Response" --infobox "${VMNAME} is powering off." 5 55
                        VBoxManage controlvm $VMNAME poweroff
                fi
        fi
}
function resetvm(){
        if [ $STATE != "running" ]
          then
                dialog --title "Warning" --msgbox "${VMNAME} is not running; cannot reset." 5 55
          else
                dialog --title "Confirm" --yesno "Really reset $VMNAME?" 5 55
                if [ $? = 0 ]
                  then
                        dialog --title "Response" --infobox "${VMNAME} is restarting." 5 55
                        VBoxManage controlvm $VMNAME reset
                fi
        fi
}
function startvm(){
        if [ $STATE = "running" ]
          then
                dialog --title "Warning" --msgbox "${VMNAME} is running; cannot start." 5 55
          else
	 	dialog --title "Response" --infobox "${VMNAME} is starting." 5 55
                #nohup VBoxHeadless --startvm $VMNAME 2>&1 &
		VBoxManage startvm "$VMNAME" --type headless
        fi
}
function sleepvm(){
        if [ $STATE != "running" ]
          then
                dialog --title "Warning" --msgbox "${VMNAME} is not running; cannot sleep." 5 55
          else
                dialog --title "Confirm" --yesno "Really hibernate $VMNAME?" 5 55
                if [ $? = 0 ]
                  then
                        dialog --title "Response" --infobox "${VMNAME} is hibernating." 5 55
                        VBoxManage controlvm $VMNAME savestate
                fi
        fi
}
function mainmenu(){
        menuitem=
        if [ 1$VMNAME = "1" ]
         then
                listvm;
        fi

        #get state of selected VM
        STATE=$(VBoxManage showvminfo $VMNAME --machinereadable | grep 'VMState=' | cut -d '"' -f2)

        dialog --clear  --backtitle "VirtualBox Command Menu" --title "[ VM Control Panel: Main Menu  ]" --menu "Selected VM [${VMNAME}] is ${STATE}.\nChoose the TASK" 25 55 10 List "Displays a list of known VMs" Start "Start a VM (Power on/Restore)" Kill "Stop a VM (Power off)" Reset "Reset a VM (Power cycle)" Quiesce "Hibernate a VM (Sleep)" Show "Show Running VMs" Exit "Exit to the shell" 2>"${INPUT}"
	
	menuitem=$(<"${INPUT}")

        case $menuitem in
            List) listvm;;
            Start) startvm;;
            Kill) killvm;;
            Reset) resetvm;;
            Quiesce) sleepvm;;
	    Show) listvmsrunning;;
            Exit) break;;
            *) break;;
        esac
}
#
# List VM
#
function listvmsrunning(){
	VBoxManage list runningvms | cut -d '{' -f1 > $OUTPUT1
	VBoxManage list runningvms | cut -d '"' -f2 > $OUTPUT
        dialog --clear --backtitle "VirtualBox Command Menu" --title "[ VM Control Panel: List RUNNING VMs ]" --menu "Select a VM to control" 25 55 10 `paste -d ' ' $OUTPUT $OUTPUT1` 2>"${INPUT}"
        VMNAME=$(<"${INPUT}")
	
}
function listvm(){
        #VBoxManage list vms > $OUTPUT
        VBoxManage list vms | cut -d '{' -f1 > $OUTPUT1
        VBoxManage list vms | cut -d '"' -f2 > $OUTPUT
        dialog --clear --backtitle "VirtualBox Command Menu" --title "[ VM Control Panel: List VMs ]" --menu "Select a VM to control" 25 55 10 `paste -d ' ' $OUTPUT $OUTPUT1` 2>"${INPUT}"
        VMNAME=$(<"${INPUT}")
}
bug;
while true
do
        mainmenu;
done

# if temp files found, delete em
[ -f $OUTPUT1 ] && rm $OUTPUT1
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT
