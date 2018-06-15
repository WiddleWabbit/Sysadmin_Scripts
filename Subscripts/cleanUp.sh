#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/scripts/Subscripts

#   -------------------------------------------------------------------
#                                * * *
#                            Liddle Script
#                                * * *
#
#      All variables should be stored in the vars associative array
#      and accessed from there to allow saving of variables in case
#      of an error. Any variables not stored in there will not be
#      saved.
#
#      All arguments are stored in the args array and can be accessed
#      from there under 0,1.. etc. Keep in mind arguments added
#      when loading will be ignored.
#
#      To use the template, begin each command with a number
#      followed by the right parenthese. The number should begin at
#      one and increment up from there with each command. This is 
#      to allow progress to be saved in the event of errors etc.
#
#      The following functions can be used:
#
#           - cleanUp
#           No Arguments, precursor to the script exiting.
#           Cleans up temporary files creating from running
#           the script.
#
#           - startLog
#           Can recieve one argument "continue"
#           Starts the logging process
#           Passing continue appends log otherwise overrides 
#
#           - endLog
#           No Arguments, ends logging.
#           Needs to be run before exiting of script.
#           Is run by errorExit function.
#
#           - errorExit
#           Requires 3 arguments,
#           $core[CMD] variable, $LINENO variable and error message.
#           Use to save and exit the script.
#
#      Valid core script variables are listed below for use.         
#
#   -------------------------------------------------------------------
#
#                              $args[]
#                 contains arguments given to the script
#                            $core[ARGNUM]
#                 contains the number of arguments as above
#                             $core[LOG]
#                   contains the path of the log file
#                             $core[DIR]
#                   contains the directory of the script
#                           $core[PROGNAME]
#                    contains the name of the script
#                           $core[USRDIR]
#      contains the current directory of the user running the script
#
#   -------------------------------------------------------------------

function transferCleanup {

    vars[transferCleanupENDLOOP]=false
    while [ ${vars[transferCleanupENDLOOP]} == false ]; do
        case ${vars[transferCleanupCMD]} in
 
#   -------------------------------------------------------------------
#                                Begin Here
#   -------------------------------------------------------------------



1) echo "Moving backup file" || errorExit $vars[transferCleanupCMD] $LINENO "Failed to display file transfer message" ;;
2) echo "..." || errorExit $vars[transferCleanupCMD] $LINENO "Failed to display dots" ;;
3) if [ -e "/home/cpmove-${vars[replaceduser]}.tar.gz" ]; then
       if [ ${vars[replaceduser]} == "oemused" ]; then
           mv "/home/cpmove-${vars[replaceduser]}.tar.gz" /home/nimda/transfer/deused/ || errorExit $vars[transferCleanupCMD] $LINENO "Failed to move account backup file"
       elif [ ${vars[replaceduser]} == "oem" ]; then
           mv "/home/cpmove-${vars[replaceduser]}.tar.gz" /home/nimda/transfer/deoem/ || errorExit $vars[transferCleanupCMD] $LINENO "Failed to move account backup file"
       else
           mv "/home/cpmove-${vars[replaceduser]}.tar.gz" /home/nimda/transfer/ || errorExit $vars[transferCleanupCMD] $LINENO "Failed to move account backup file"
       fi
   else
       errorExit $vars[transferCleanupCMD] $LINENO "Unable to find account backup file"
   fi ;;

4) echo "Checking for backed up files" || errorExit $vars[transferCleanupCMD] $LINENO "Failed to display backed up files check message" ;;
5) echo "..." || errorExit $vars[transferCleanupCMD] $LINENO "Failed to display dots" ;;
6) if [[ ${vars[replaceduser]} == "oemused" ]] && [[ ${vars[user]} == "deused" ]]; then
        if [ -n "$(ls -A /home/deused/usr/files/)" ]; then
            echo "";rm -rf /home/deused/usr/files/*; echo "Cleaning out usr/files directory";echo "" || errorExit $vars[transferCleanupCMD] $LINENO "Failed to delete files"
        else
            echo "No Files located in /home/deused/usr/files/" || errorExit $vars[transferCleanupCMD] $LINENO "Failed echo command"
        fi || errorExit $vars[transferCleanupCMD] $LINENO "Failed to search for files"
   fi ;;
7) if [[ ${vars[replaceduser]} == "oem" ]] && [[ ${vars[user]} == "deoem" ]]; then
        if [ -n "$(ls -A /home/deoem/usr/files/)" ]; then
            echo "";rm -rf /home/deoem/usr/files/*; echo "Cleaning out usr/files directory";echo "" || errorExit $vars[transferCleanupCMD] $LINENO "Failed to delete files"
        else
            echo "No Files located in /home/deoem/usr/files/" || errorExit $vars[transferCleanupCMD] $LINENO "Failed echo command"
        fi || errorExit $vars[transferCleanupCMD] $LINENO "Failed to search for files"
   fi ;;

8) echo "Checking for recorded modified files" || errorExit $vars[transferCleanupCMD] $LINENO "Failed to display recorded modified files check message" ;;
9) echo "..." || errorExit $vars[transferCleanupCMD] $LINENO "Failed to display dots" ;;
10) if [[ ${vars[replaceduser]} == "oemused" ]] && [[ ${vars[user]} == "deused" ]]; then
        if [ -n "$(ls -A /home/deused/usr/modifiedfiles/)" ]; then
            for file in /home/deused/usr/modifiedfiles/*
            do
                mv ${file} /home/nimda/transfer/deused/; echo "Transferred ${file}" || errorExit ${vars[transferCleanupCMD]} $LINENO "Failed to transfer ${file}"
            done
        fi
   fi ;;
11) if [[ ${vars[replaceduser]} == "oem" ]] && [[ ${vars[user]} == "deoem" ]]; then
        if [ -n "$(ls -A /home/deoem/usr/modifiedfiles/)" ]; then
            for file in /home/deoem/usr/modifiedfiles/*
            do
                mv ${file} /home/nimda/transfer/deoem/; echo "Transferred ${file}" || errorExit ${vars[transferCleanupCMD]} $LINENO "Failed to transfer ${file}"
            done
        fi
   fi ;;

12) echo "Preparing to make permission changes to files for transfer" || errorExit $vars[transferCleanupCMD] $LINENO "Failed to display permission change perparation message" ;;
13) echo "..." || errorExit $vars[transferCleanupCMD] $LINENO "Failed to display dots" ;;
14) chown -R nimda /home/nimda/transfer || errorExit ${vars[transferCleanupCMD]} $LINENO "Failed to change file owner" ;;
15) chgrp -R nimda /home/nimda/transfer || errorExit ${vars[transferCleanupCMD]} $LINENO "Failed to change file group" ;;

16) while :
    do
        echo ""
        echo "Moved saved modified files..."
        echo ""
        echo "Please use FTP to tranfer files from /home/nimda/transfer/deoem"
        echo -e "Files will be \e[31mdeleted\e[39m with completion of script"
        echo ""
        echo "Complete script and delete files by typing 'finish'"
        echo "(to complete script without deletion of files type 'cancel')"
        echo ""
        read -p "Input:" finish
        
        if [[ ${vars[replaceduser]} == "oemused" ]] && [[ ${vars[user]} == "deused" ]]; then
            if [[ "${finish}" == "finish" ]]; then
                rm -rf /home/nimda/transfer/deused/*
                break
            elif [ "${finish}" == "cancel"  ]; then
                break
            else
                continue
            fi
        elif [[ ${vars[replaceduser]} == "oem" ]] && [[ ${vars[user]} == "deoem" ]]; then
            if [ "${finish}" == "finish" ]; then
                rm -rf /home/nimda/transfer/deoem/*
                break
            elif [ "${finish}" == "cancel" ]; then
                break
            else
                continue
            fi
        else
            if [ "${finish}" == "finish" ]; then
                echo "Account combination not specified in script, please delete files manually."
                break
            elif [ "${finish}" == "cancel" ]; then
                break
            else
                continue
            fi
        fi
        break
        done;;

17) vars[transferCleanupENDLOOP]=true ;;

#   -------------------------------------------------------------------
#                                 End Here
#   -------------------------------------------------------------------

        esac
        ((vars[transferCleanupCMD]++))
    done

}
