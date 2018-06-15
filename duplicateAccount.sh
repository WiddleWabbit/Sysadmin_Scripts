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
2) read -p 'The new cPanel User: ' vars[user] || errorExit $core[CMD] $LINENO "Read command failed" ;;
3) read -s -p 'The new cPanel Users Password: ' vars[password] ; echo || errorExit ${core[CMD]} $LINENO "Read command failed" ;;
4) read -p 'The disk quota to be assigned to the account (in MB): ' vars[quota] || errorExit $core[CMD] $LINENO "Read command failed" ;;
5) read -p 'The domain of the new account (with www if applicable): ' vars[domain] || errorExit $core[CMD] $LINENO "Read command failed" ;;
6) read -p 'The cPanel User that is being duplicated: ' vars[olduser] || errorExit $core[CMD] $LINENO "Read command failed" ;;
7) read -p 'Original cPanel users, Database suffix (from format cpaneluser_suffix): ' vars[database] || errorExit $core[CMD] $LINENO "Read command failed" ;;
8) read -p 'Original cPanel users, Database user suffix (from format cpaneluser_suffix: ' vars[dbuser] || errorExit $core[CMD] $LINENO "Read command failed" ;;
9) read -s -p 'Original database password: ' vars[dbpass] || errorExit $core[CMD] $LINENO "Read command failed" ;;
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
    echo -e "New User: "
    echo -e "\e[92m"${vars[user]}
    echo
    echo -e "\e[0mNew User Password: "
    echo -e "\e[92m"${vars[password]}
    echo
    echo -e "\e[0mNew Users Quota: "
    echo -e "\e[92m"${vars[quota]}
    echo
    echo -e "\e[0mNew Users Domain: "
    echo -e "\e[92m"${vars[domain]}
    echo
    echo -e "\e[0mUser Being Duplicated: "
    echo -e "\e[36m"${vars[olduser]}
    echo
    echo -e "\e[0mDuplicated Users Database Name: "
    echo -e "\e[36m"${vars[olduser]}"_"${vars[database]}
    echo
    echo -e "\e[0mDuplicated Users Database Username: "
    echo -e "\e[36m"${vars[olduser]}"_"${vars[dbuser]}
    echo
    echo -e "\e[0mDuplicated Users Database Password: "
    echo -e "\e[36m"${vars[dbpass]}
    echo
    echo -e "\e[0mEnd of Overview"
    echo
    echo || errorExit $core[CMD] $LINENO "Failed to output user data entry" ;;
12) read -n 1 -s -p "[ Press any key to continue ]"
    echo
    echo || errorExit $core[CMD] $LINENO "Failed read any key command" ;;


13) echo 'Beginning cPanelaccount creation' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
14) yes | /scripts/wwwacct ${vars[domain]} ${vars[user]} ${vars[password]} ${vars[quota]} paper_lantern n y n 1 1 1 1 0 0 y root default 0 0 default n.wheat@oemgroup.com.au || errorExit $core[CMD] $LINENO "Failed to create account" ;;
15) echo 'Account creation completed' || errorExit $core[CMD] $LINENO "Failed to display backup completion message" ;;

16) echo 'Beginning cPanelaccount backups' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
17) /scripts/pkgacct ${vars[olduser]} /home/${vars[user]} || errorExit $core[CMD] $LINENO "${vars[olduser]} Backup Failed" ;;
18) echo 'Backup completed' || errorExit $core[CMD] $LINENO "Failed to display backup completion message" ;;
19) echo 'Backup of original account located in /home/' || errorExit $core[CMD] $LINENO "Failed to display location of original account backup" ;;





20) echo 'Beginning Extraction' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
21) tar -xvzf /home/${vars[user]}/cpmove-${vars[olduser]}.tar.gz -C /home/${vars[user]} || errorExit $core[CMD] $LINENO "Extraction of ${vars[user]} backup failed" ;;
22) rm -f /home/${vars[user]}/cpmove-${vars[olduser]}.tar.gz || errorExit $core[CMD] $LINENO "Deletion of ${user} backup file following extraction failed" ;;





23) echo 'Begin ownership change of files' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
24) chown -R ${vars[user]} /home/${vars[user]}/cpmove-${vars[olduser]}/homedir/public_html || errorExit $core[CMD] $LINENO "Failed to change backup files owner" ;;
25) chgrp -R ${vars[user]} /home/${vars[user]}/cpmove-${vars[olduser]}/homedir/public_html || errorExit $core[CMD] $LINENO "Failed to change backup files group" ;;
26) chgrp nobody /home/${vars[user]}/cpmove-${vars[olduser]}/homedir/public_html || errorExit $core[CMD] $LINENO "Failed to reset public_html permissions" ;;
27) echo "Ownership changes successfull"; echo || errorExit $core[CMD] $LINENO "Failed to display phase exit message" ;;





28) echo 'Begin Transfer' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
29) rm -rf /home/${vars[user]}/public_html/{,.[!.],..?}* || errorExit $core[CMD] $LINENO "Deletion of ${vars[user]} files failed" ;;
30) mv /home/${vars[user]}/cpmove-${vars[olduser]}/homedir/public_html/* /home/${vars[user]}/public_html/ || errorExit $core[CMD] $LINENO "Transfer of non-hidden files failed" ;;
31) mv -f /home/${vars[user]}/cpmove-${vars[olduser]}/homedir/public_html/.[^.]* /home/${vars[user]}/public_html/ || errorExit $core[CMD] $LINENO "Transfer of hidden files failed" ;;
32) echo "Transfer successfull"; echo || errorExit $core[CMD] $LINENO "Failed to display phase exit message" ;;




33) echo 'Begin Database Creation and Transfer' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
34) vars[olddata]=${vars[olduser]}'_'${vars[database]}
    vars[usrdata]=${vars[user]}'_'${vars[database]}
    vars[mkdat]='uapi --user='${vars[user]}' Mysql create_database name='${vars[user]}'_'${vars[database]}
    vars[mkusr]='uapi --user='${vars[user]}' Mysql create_user name='${vars[user]}'_'${vars[dbuser]}' password='${vars[dbpass]}
    vars[priv]='uapi --user='${vars[user]}' Mysql set_privileges_on_database user='${vars[user]}'_'${vars[dbuser]}' database='${vars[user]}'_'${vars[database]}' privileges=ALL%20PRIVILEGES' || errorExit $core[CMD] $LINENO "Failed to set variables" ;;
35) ${vars[mkdat]} || errorExit $core[CMD] $LINENO "Failed to create new database" ;;
36) ${vars[mkusr]} || errorExit $core[CMD] $LINENO "Failed to create new database user" ;;
37) ${vars[priv]} || errorExit $core[CMD] $LINENO "Failed to assign privileges to new database user" ;;
38) mysql -u root -pT79\]Kf\(xhrd7YqJ -h localhost ${vars[usrdata]} << EOF
   USE ${vars[usrdata]};
   SET foreign_key_checks=0;
   SOURCE /home/${vars[user]}/cpmove-${vars[olduser]}/mysql/${vars[olddata]}.sql
EOF
#    errorExit $core[CMD] $LINENO "Failed to make database data transfer from backup"
;;

39) echo "Transfer successfull"; echo || errorExit $core[CMD] $LINENO "Failed to display phase exit message" ;;


40) echo 'Begin Cron Transfer' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
41) cat /home/${vars[user]}/cpmove-${vars[olduser]}/cron/${vars[olduser]} > /var/spool/cron/${vars[user]} || errorExit $core[CMD] $LINENO "Failed to transfer cron jobs" ;;
42) echo "Transfer successfull"; echo || errorExit $core[CMD] $LINENO "Failed to display phase exit message" ;;



43) echo 'Checking CMS' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
44) if [[ ${vars[cms]} == "drupal7" ]]; then
        vars[olddatabase]=${vars[database]} || errorExit $core[CMD] $LINENO "Failed to create variable"
        vars[newuser]=${vars[user]} || errorExit $core[CMD] $LINENO "Failed to create variable"
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
        vars[olddatabase]=${vars[database]} || errorExit $core[CMD] $LINENO "Failed to create variable"
        vars[newuser]=${vars[user]} || errorExit $core[CMD] $LINENO "Failed to create variable"
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




45) echo 'Beginning Cleanup of Transfer Files' || errorExit $core[CMD] $LINENO "Failed to display phase entry message" ;;
46) rm -rf /home/${vars[user]}/cpmove-${vars[olduser]}/ || errorExit $core[CMD] $LINENO "Failed to delete extracted user folder from /home/${vars[user]}" ;;

47) echo; echo "Account Duplication Successfull"; echo || errorExit ${core[CMD]} $LINENO "Failed to display final success message" ;;
48) core[ENDLOOP]=true ;;

#   -------------------------------------------------------------------
#                                 End Here
#   -------------------------------------------------------------------

        esac
        ((core[CMD]++))
    done

}

. /root/scripts/Liddle/core.liddle
