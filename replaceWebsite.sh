#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/scripts/

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

function phase1 {

    core[ENDLOOP]=false
    while [ ${core[ENDLOOP]} == false ]; do
        case ${core[CMD]} in
 
#   -------------------------------------------------------------------
#                                Begin Here
#   -------------------------------------------------------------------



1) echo; 
   echo 'Entering user data collection phase' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
2) read -p 'The cPanel User Replacing the other: ' vars[user] || errorExit $core[CMD] $LINENO "Read command failed" ;;
3) read -p 'The cPanel User that is being replaced: ' vars[replaceduser] || errorExit $core[CMD] $LINENO "Read command failed" ;;
4) read -p 'The domain of the account being replaced (with www/nonwww and no trailing slash): ' vars[domain] || errorExit $core[CMD] $LINENO "Read command failed" ;;
5) read -p 'Replacing cPanel users, Database suffix (from format cpaneluser_suffix): ' vars[database] || errorExit $core[CMD] $LINENO "Read command failed" ;;
6) read -p 'Replacing cPanel users, Database user suffix (from format cpaneluser_suffix: ' vars[dbuser] || errorExit $core[CMD] $LINENO "Read command failed" ;;
7) read -p 'Database suffix, of cPanel user to be Replaced (from format cpaneluser_suffix): ' vars[olddatabase] || errorExit $core[CMD] $LINENO "Read command failed" ;;
8) read -p 'Database User suffix, of cPanel user to be Replaced (from format cpaneluser_suffix): ' vars[olddbuser] || errorExit $core[CMD] $LINENO "Read command failed" ;;
9) read -s -p 'Database password, for user being replaced: ' vars[olddbpass] || errorExit $core[CMD] $LINENO "Read command failed" ;;
10) echo
    while :
        do
            read -p 'What CMS is in use on the website: ' vars[cms]
            if [[ "${vars[cms]}" == *"rupal"* ]] && [[ "${vars[cms]}" == *"7"* ]];
            then
                vars[drupalCMD]="1"
                vars[cms]="drupal7"
                while :
                do
                    read -p 'Which url redirect would you like to be active? (www/nonwww)' vars[htaccess_active]
                    if [[ ${vars[htaccess_active]} == "www" ]];
                    then
                        vars[comment]="non"
                        vars[uncomment]="www"
                        break
                    elif [[ ${vars[htaccess_active]} == "nonwww" ]];
                    then
                        vars[comment]="www"
                        vars[uncomment]="non"
                        break
                    else
                        continue
                    fi
                    break
                done
                break
            elif [[ "${vars[cms]}" == *"agento"* ]] && [[ "${vars[cms]}" == *"2"* ]];
            then
                vars[cms]=magento2
                vars[magento2CMD]=1
                break
            elif [[ "${vars[cms]}" == *"skip"* ]];
                then
                break
            else
                echo "Please input a valid value (Drupal7, Magento2, skip): "
                continue
            fi
                break
            done ;;
11) echo
    echo
    echo -e "User: "
    echo -e "\e[92m"${vars[replaceduser]}
    echo
    echo -e "\e[0mBeing Replaced By: "
    echo -e "\e[36m"${vars[user]}
    echo
    echo -e "\e[0mReplacing Users Database Name: "
    echo -e "\e[36m"${vars[user]}"_"${vars[database]}
    echo
    echo -e "\e[0mReplacing Users Database Username: "
    echo -e "\e[36m"${vars[user]}"_"${vars[dbuser]}
    echo
    echo -e "\e[0mOverridden Users Database Name: "
    echo -e "\e[92m"${vars[replaceduser]}"_"${vars[olddatabase]}
    echo
    echo -e "\e[0mOverridden Users Database Username: "
    echo -e "\e[92m"${vars[replaceduser]}"_"${vars[olddbuser]}
    echo
    echo -e "\e[0mOverridden Users Database Password: "
    echo -e "\e[92m"${vars[olddbpass]}
    echo
    echo -e "\e[0mDomain Applied Final Account: "
    echo -e "\e[92m"${vars[domain]}
    echo
    echo -e "\e[0mEnd of Overview"
    echo
    echo || errorExit $core[CMD] $LINENO "Failed to output user data entry" ;;
12) read -n 1 -s -p "[ Press any key to continue ]"
    echo
    echo || errorExit $core[CMD] $LINENO "Failed read any key command" ;;





13) echo 'Beginning cPanelaccount backups' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
14) /scripts/pkgacct ${vars[replaceduser]} /root/tmpbackup/ || errorExit $core[CMD] $LINENO "${replaceduser} Backup Failed" ;;
15) /scripts/pkgacct ${vars[user]} /home/${vars[user]} || errorExit $core[CMD] $LINENO "${user} Backup Failed" ;;
16) echo 'Backups completed' || errorExit $core[CMD] $LINENO "Failed to display backup completion message" ;;
17) echo 'Backup of original account located in /home/' || errorExit $core[CMD] $LINENO "Failed to display location of original account backup" ;;





18) echo 'Beginning Extraction' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
19) tar -xvzf /home/${vars[user]}/cpmove-${vars[user]}.tar.gz -C /home/${vars[replaceduser]} || errorExit $core[CMD] $LINENO "Extraction of ${user} backup failed" ;;
20) rm -f /home/${vars[user]}/cpmove-${vars[user]}.tar.gz || errorExit $core[CMD] $LINENO "Deletion of ${user} backup file following extraction failed" ;;





21) echo 'Begin ownership change of files' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
22) chown -R ${vars[replaceduser]} /home/${vars[replaceduser]}/cpmove-${vars[user]}/homedir/public_html || errorExit $core[CMD] $LINENO "Failed to change backup files owner" ;;
23) chgrp -R ${vars[replaceduser]} /home/${vars[replaceduser]}/cpmove-${vars[user]}/homedir/public_html || errorExit $core[CMD] $LINENO "Failed to change backup files group" ;;
24) chgrp nobody /home/${vars[replaceduser]}/cpmove-${vars[user]}/homedir/public_html || errorExit $core[CMD] $LINENO "Failed to reset public_html permissions" ;;
25) echo "Ownership changes successfull"; echo || errorExit $core[CMD] $LINENO "Failed to display phase exit message" ;;





26) echo 'Begin Transfer' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
27) rm -rf /home/${vars[replaceduser]}/public_html/{,.[!.],..?}* || errorExit $core[CMD] $LINENO "Deletion of ${vars[replaceduser]} files failed" ;;
28) mv /home/${vars[replaceduser]}/cpmove-${vars[user]}/homedir/public_html/* /home/${vars[replaceduser]}/public_html/ || errorExit $core[CMD] $LINENO "Transfer of non-hidden files failed" ;;
29) mv -f /home/${vars[replaceduser]}/cpmove-${vars[user]}/homedir/public_html/.[^.]* /home/${vars[replaceduser]}/public_html/ || errorExit $core[CMD] $LINENO "Transfer of hidden files failed" ;;
30) echo "Transfer successfull"; echo || errorExit $core[CMD] $LINENO "Failed to display phase exit message" ;;




31) echo 'Begin Database Modifications' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
32) vars[olddata]=${vars[replaceduser]}'_'${vars[olddatabase]}
   vars[olduser]=${vars[replaceduser]}'_'${vars[olddbuser]}
   vars[newdata]=${vars[user]}'_'${vars[database]}
   vars[deldat]='uapi --user='${vars[replaceduser]}' Mysql delete_database name='${vars[olddata]}''
   vars[delusr]='uapi --user='${vars[replaceduser]}' Mysql delete_user name='${vars[olduser]}'' || errorExit $core[CMD] $LINENO "Failed to set variables" ;;
33) ${vars[deldat]} || errorExit $core[CMD] $LINENO "Failed to delete old database" ;;
34) ${vars[delusr]} || errorExit $core[CMD] $LINENO "Failed to delete old database user" ;;
35) vars[mkdat]='uapi --user='${vars[replaceduser]}' Mysql create_database name='${vars[olddata]}
   vars[mkusr]='uapi --user='${vars[replaceduser]}' Mysql create_user name='${vars[olduser]}' password='${vars[olddbpass]}
   vars[priv]='uapi --user='${vars[replaceduser]}' Mysql set_privileges_on_database user='${vars[olduser]}' database='${vars[olddata]}' privileges=ALL%20PRIVILEGES' || errorExit $core[CMD] $LINENO "Failed to set database creation variables" ;;
36) ${vars[mkdat]} || errorExit $core[CMD] $LINENO "Failed database creation" ;;
37) ${vars[mkusr]} || errorExit $core[CMD] $LINENO "Failed database user creation" ;;
38) ${vars[priv]} || errorExit $core[CMD] $LINENO "Failed database privilege designation" ;;
39) mysql -u root -pT79\]Kf\(xhrd7YqJ -h localhost ${vars[olddata]} << EOF
   USE ${vars[olddata]};
   SET foreign_key_checks=0;
   SOURCE /home/${vars[replaceduser]}/cpmove-${vars[user]}/mysql/${vars[newdata]}.sql
EOF
#    errorExit $core[CMD] $LINENO "Failed to make database data transfer from backup"
;;






40) echo 'Checking CMS' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
41) if [[ ${vars[cms]} == "drupal7" ]]; then
        vars[olduser]=${vars[user]}
        vars[newuser]=${vars[replaceduser]}
        . /root/scripts/Subscripts/drupal7.sh || errorExit $core[CMD] $LINENO "Failed to add external script"
        echo || errorExit ${core[CMD]} $LINENO "Failed to display Drupal 7 Phase Echo"
        echo "--------------------------------------------------------------------------------------------------------------------" || errorExit ${core[CMD]} $LINENO "Failed to display Drupal 7 Phase Echo"
        echo "Beginning Drupal 7 Specific Modifications" || errorExit ${core[CMD]} $LINENO "Failed to display Drupal 7 Phase Echo"
        echo "--------------------------------------------------------------------------------------------------------------------" || errorExit ${core[CMD]} $LINENO "Failed to display Drupal 7 Phase Echo" 
        echo || errorExit ${core[CMD]} $LINENO "Failed to display Drupal 7 Phase Echo"
        drupal7 || errorExit $core[CMD] $LINENO "Failed to run Drupal 7 changes script"
        echo "--------------------------------------------------------------------------------------------------------------------" || errorExit ${core[CMD]} $LINENO "Failed to display Drupal 7 Phase End Echo"
        echo "Successfully Completed Drupal 7 Specific Modifications" || errorExit ${core[CMD]} $LINENO "Failed to display Drupal 7 Phase Echo"
        echo "--------------------------------------------------------------------------------------------------------------------" || errorExit ${core[CMD]} $LINENO "Failed to display Drupal 7 Phase End Echo"
        echo || errorExit ${core[CMD]} $LINENO "Failed to display Drupal 7 Phase End Echo"
   elif [[ ${vars[cms]} == "magento2" ]]; then
        vars[olduser]=${vars[user]}
        vars[newuser]=${vars[replaceduser]}
        . /root/scripts/Subscripts/magento2.sh || errorExit $core[CMD] $LINENO "Failed to run external script"
        echo || errorExit ${core[CMD]} $LINENO "Failed to display Magento 2 Phase Echo"
        echo "--------------------------------------------------------------------------------------------------------------------" || errorExit ${core[CMD]} $LINENO "Failed to display Magento 2 Phase Echo"
        echo "Beginning Magento 2 Specific Modifications" || errorExit ${core[CMD]} $LINENO "Failed to display Magento 2 Phase Echo"
        echo "--------------------------------------------------------------------------------------------------------------------" || errorExit ${core[CMD]} $LINENO "Failed to display Magento 2 Phase Echo"
        echo || errorExit ${core[CMD]} $LINENO "Failed to display Magento 2 Phase Echo"
        magento2 || errorExit $core[CMD] $LINENO "Failed to run Magento 2 changes script"
        echo "--------------------------------------------------------------------------------------------------------------------" || errorExit ${core[CMD]} $LINENO "Failed to display Magento 2 Phase End Echo"
        echo "Successfully Completed Magento 2 Specific Modifications" || errorExit ${core[CMD]} $LINENO "Failed to display Magento 2 Phase Echo"
        echo "--------------------------------------------------------------------------------------------------------------------" || errorExit ${core[CMD]} $LINENO "Failed to display Magento 2 Phase End Echo"
        echo || errorExit ${core[CMD]} $LINENO "Failed to display Magento 2 Phase End Echo"
   fi ;;




42) echo 'Beginning Cleanup of Transfer Files' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
43) rm -rf /home/${vars[replaceduser]}/cpmove-${vars[user]}/ || errorExit $core[CMD] $LINENO "Failed to delete extracted user folder from /home/${vars[removeduser]}" ;;
44) . /root/scripts/Subscripts/cleanUp.sh || errorExit $core[CMD] $LINENO "Failed to add external script" ;;
45) echo || errorExit ${core[CMD]} $LINENO "Failed to display Cleanup Phase Echo"
    echo "--------------------------------------------------------------------------------------------------------------------" || errorExit ${core[CMD]} $LINENO "Failed to display Cleanup Phase Echo"
    echo "Beginning Cleanup" || errorExit ${core[CMD]} $LINENO "Failed to display Cleanup Echo"
    echo "--------------------------------------------------------------------------------------------------------------------" || errorExit ${core[CMD]} $LINENO "Failed to display Cleanup Phase Echo"
    echo || errorExit ${core[CMD]} $LINENO "Failed to display Cleanup Phase Echo"
    transferCleanup || errorExit $core[CMD] $LINENO "Failed to run transfer cleanup" 
    echo || errorExit ${core[CMD]} $LINENO "Failed to display Cleanup Phase End Echo"
    echo "--------------------------------------------------------------------------------------------------------------------" || errorExit ${core[CMD]} $LINENO "Failed to display Cleanup Phase End Echo"
    echo "Successfully Completed Transfer Cleanup" || errorExit ${core[CMD]} $LINENO "Failed to display Cleanup Phase Echo"
    echo "--------------------------------------------------------------------------------------------------------------------" || errorExit ${core[CMD]} $LINENO "Failed to display Cleanup Phase End Echo"
    echo || errorExit ${core[CMD]} $LINENO "Failed to display Cleanup Phase End Echo" ;;
46) echo; echo "Account Replacement Successfull"; echo || errorExit ${core[CMD]} $LINENO "Failed to display final success message" ;;
47) core[ENDLOOP]=true ;;

#   -------------------------------------------------------------------
#                                 End Here
#   -------------------------------------------------------------------

        esac
        ((core[CMD]++))
    done

}

. /root/scripts/Liddle/core.liddle
