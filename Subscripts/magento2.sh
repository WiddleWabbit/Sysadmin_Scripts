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

function magento2 {

    vars[magento2ENDLOOP]=false
    while [ ${vars[magento2ENDLOOP]} == false ]; do
        case ${vars[magento2CMD]} in
 
#   -------------------------------------------------------------------
#                                Begin Here
#   -------------------------------------------------------------------



1) echo "Updating env.php" || errorExit $vars[magento2CMD] $LINENO "Failed to display file update message" ;;
2) echo "..." || errorExit $vars[magento2CMD] $LINENO "Failed to display dots" ;;
3) vars[sedcmdmagento2]='s;'${vars[olduser]}';'${vars[newuser]}';g' || errorExit $vars[magento2CMD] $LINENO "Failed to setup sed command variable" ;;
4) sed -i ${vars[sedcmdmagento2]} /home/${vars[newuser]}/public_html/app/etc/env.php || errorExit $vars[magento2CMD] $LINENO "Failed to update env.php" ;;
5) echo "Updated env.php successfully"; echo || errorExit $vars[magento2CMD] $LINENO "Failed to display env.php modification success message" ;;

6) echo "Updating database URL's" || errorExit $vars[magento2CMD] $LINENO "Failed to display database update message" ;;
7) echo "..." || errorExit $vars[magento2CMD] $LINENO "Failed to display dots" ;;
8) vars[url_query]='UPDATE  `'${vars[newuser]}'_'${vars[olddatabase]}'`.`core_config_data` SET  `value` =  '\'http://${vars[domain]}/\'' WHERE  `core_config_data`.`config_id` =2;' || errorExit $vars[magento2CMD] $LINENO "Failed to set database query variables" ;;
9) vars[securl_query]='UPDATE  `'${vars[newuser]}'_'${vars[olddatabase]}'`.`core_config_data` SET  `value` =  '\'https://${vars[domain]}/\'' WHERE  `core_config_data`.`config_id` =3;' || errorExit $vars[magento2CMD] $LINENO "Failed to set database update query variable" ;;
10) vars[cookie_query]='UPDATE  `'${vars[newuser]}'_'${vars[olddatabase]}'`.`core_config_data` SET  `value` =  '\'${vars[domain]}\'' WHERE  `core_config_data`.`config_id` =92;' || errorExit $vars[magento2CMD] $LINENO "Failed to set database update variable" ;;
11) vars[sql4]='USE '${vars[newuser]}'_'${vars[olddatabase]} || errorExit $vars[magento2CMD] $LINENO "Failed to set database update variable" ;;
12) vars[sql5]=${vars[newuser]}'_'${vars[olddatabase]} || errorExit $vars[magento2CMD] $LINENO "Failed to set database update variable" ;;
13) mysql -u root -pT79\]Kf\(xhrd7YqJ -h localhost ${vars[sql5]} << EOF
${vars[sql4]};
SET foreign_key_checks=0;
${vars[url_query]};
${vars[securl_query]};
${vars[cookie_query]};
EOF
# errorExit $vars[magento2CMD] $LINENO "Failed to update database" ;;
echo "Updated DB Entries Successfully"
echo 
;;

14) echo "Updating crontab" || errorExit $vars[magento2CMD] $LINENO "Failed to display crontab update message" ;;
15) echo "..." || errorExit $vars[magento2CMD] $LINENO "Failed to display dots" ;;
16) echo "IGNORE CRONTAB UPDATE" ;;#su -c 'crontab -l' -s /bin/bash ${vars[olduser]} > tmpcron || errorExit $vars[magento2CMD] $LINENO "Failed to copy ${vars[newuser]}'s crontab to file" ;;
17) echo "..." ;;#vars[sedcmd2magento2]='s;'${vars[olduser]}';'${vars[newuser]}';g' || errorExit $vars[magento2CMD] $LINENO "Failed to set sed crontab update variable" ;;
18) echo "..." ;;#sed -i ${vars[sedcmd2magento2]} tmpcron || errorExit $vars[magento2CMD] $LINENO "Failed to edit temporary cron file" ;;
19) echo "..." ;;#chown ${vars[newuser]}:${vars[newuser]} tmpcron || errorExit $vars[magento2CMD] $LINENO "Failed to change ownership of temporary crontab file" ;;
20) echo "..." ;;#su -c 'crontab tmpcron' -s /bin/bash ${vars[newuser]} || errorExit $vars[magento2CMD] $LINENO "Failed to replace ${vars[newuser]}'s crontab with file" ;;
21) echo "..." ;;#rm -f tmpcron || errorExit $vars[magento2CMD] $LINENO "Failed to delete temporary file" ;;

22) echo "Updating .htaccess" || errorExit $vars[magento2CMD] $LINENO "Failed to display htaccess update message" ;;
23) echo "..." || errorExit $vars[magento2CMD] $LINENO "Failed to display dots" ;;
24) vars[replaceht_magento2]='s/!^dev/!^www/g' || errorExit $vars[magento2CMD] $LINENO "Failed to set sed htaccess modification variable" ;;
25) vars[replaceht2_magento2]='s/http:\/\/dev/http:\/\/www/g' || errorExit $vars[magento2CMD] $LINENO "Failed to set sed htaccess modification variable" ;;
26) if [[ ${vars[olduser]} == "deoem" ]] && [[ ${vars[newuser]} == "oem" ]]; then sed -i -- ${vars[replaceht_magento2]} /home/${vars[newuser]}/public_html/.htaccess; fi || errorExit $vars[magento2CMD] $LINENO "Failed to run sed command to modify htaccess" ;;
27) if [[ ${vars[olduser]} == "deoem" ]] && [[ ${vars[newuser]} == "oem" ]]; then sed -i -- ${vars[replaceht2_magento2]} /home/${vars[newuser]}/public_html/.htaccess; fi || errorExit $vars[magento2CMD] $LINENO "Failed to run sed command to modify htaccess" ;;

28) su -c /home/${vars[newuser]}/usr/scripts/clear.sh -s /bin/bash ${vars[newuser]} || errorExit $vars[magento2CMD] $LINENO "Failed to clear cache and redeploy magento 2 files" ;;

29) echo "Completed changes to .htaccess"; echo "Completed Magento 2 Related Changes" || errorExit $vars[magento2CMD] $LINENO "Failed to print Magento 2 completion message" ;;
30) vars[magento2ENDLOOP]=true ;;

#   -------------------------------------------------------------------
#                                 End Here
#   -------------------------------------------------------------------

        esac
        ((vars[magento2CMD]++))
    done

}
