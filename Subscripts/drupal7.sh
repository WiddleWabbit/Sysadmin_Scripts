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

function drupal7 {

    vars[drupalENDLOOP]=false
    while [ ${vars[drupalENDLOOP]} == false ]; do
        case ${vars[drupalCMD]} in
 
#   -------------------------------------------------------------------
#                                Begin Here
#   -------------------------------------------------------------------



1) echo "Updating settings.php" || errorExit $vars[drupalCMD] $LINENO "Failed to display file update message" ;;
2) echo "..." || errorExit $vars[drupalCMD] $LINENO "Failed to display dots" ;;
3) vars[sedcmd]='s/'${vars[olduser]}'/'${vars[newuser]}'/g' || errorExit $vars[drupalCMD] $LINENO "Failed to setup sed command variable" ;;
4) sed -i ${vars[sedcmd]} /home/${vars[newuser]}/public_html/sites/default/settings.php || errorExit $vars[drupalCMD] $LINENO "Failed to update settings.php" ;;
5) vars[httpsdomain]=https://${vars[domain]} || errorExit $vars[drupalCMD] $LINENO "Failed to set https domain variable" ;;

6) sed -i '\&^\s*\$base_url&s&'\''.*'\''&'\'"${vars[httpsdomain]}"\''&' /home/${vars[newuser]}/public_html/sites/default/settings.php || errorExit $vars[drupalCMD] $LINENO "Failed to update settings.php" ;;
7) echo "Updated settings.php successfully"; echo || errorExit $vars[drupalCMD] $LINENO "Failed to echo settings.php success message" ;;

8) echo "Updating .htaccess" || errorExit $vars[drupalCMD] $LINENO "Failed to display file update message" ;;
9) echo "..." || errorExit $vars[drupalCMD] $LINENO "Failed to display dots" ;;
10) vars[non]='RewriteRule ^ http%{ENV:protossl}://%1%{REQUEST_URI} [L,R=301]' || errorExit $vars[drupalCMD] $LINENO "Failed to set non-www variable" ;;
11) vars[www]='RewriteRule ^ http%{ENV:protossl}://www.%{HTTP_HOST}%{REQUEST_URI} [L,R=301]' || errorExit $vars[drupalCMD] $LINENO "Failed to set www variable" ;;
12) vars[htaccess]="/home/${vars[newuser]}/public_html/.htaccess" || errorExit $vars[drupalCMD] $LINENO "Failed to set variable containing htaccess location" ;;
13) vars[lineno]=0; vars[htcommented]=""; vars[www_end]=""; vars[www_begin]=""; vars[non_end]=""; vars[non_begin]="" || errorExit $vars[drupalCMD] $LINENO "Failed to set other variables" ;; 
14) if [[ ${vars[comment]} == "" ]] || [[ ${vars[uncomment]} == "" ]]; then
        errorExit $vars[drupalCMD] $LINENO "The comment or uncomment variable is not set" 
    fi || errorExit $vars[drupalCMD] $LINENO "Failed to check the comment and uncomment variables" ;;
15) while read line
    do

    ((vars[lineno]++))

    # If this line matches the string associated with the last line of the www redirect
    if [[ $line == *"${vars[www]}"* ]]; then

        # Set www begin and end variables to the correct line numbers
        vars[www_end]=${vars[lineno]}
        vars[www_begin]=${vars[lineno]}
        vars[www_begin]=$((vars[www_begin]-2))

        # Check to see if it contains a #
        # It should only contain a hash if it is commented out
        if [[ $line == *"#"* ]]; then
            # If the script has already found the other redirect is commented
            if [[ ${vars[htcommented]} == "non" ]]; then

                vars[htcommented]="both"

            # Otherwise
            else

                vars[htcommented]="www"

            fi
        fi

    # If this line matches the string associated with the last line of the non-www redirect
    elif [[ $line == *"${vars[non]}"* ]]; then

        # Set non-www begin and end variables to the correct line numbers
        vars[non_end]=${vars[lineno]}
        vars[non_begin]=${vars[lineno]}
        vars[non_begin]=$((vars[non_begin]-1))

        # Check to see if it contains a #
        # It should only contain a hash if it is commented out
        if [[ $line == *"#"* ]]; then

            # If the script has already found the other redirect is commented
            if [[ ${vars[htcommented]} == "www" ]]; then

                vars[htcommented]="both"

            # Otherwise
            else

                vars[htcommented]="non"

            fi
        fi
    fi

    # Finish Here - Contains the file input
    done<${vars[htaccess]}

    # At this point the htcommented variable should contain which clause is commented
    # If neither are commented
    if [[ ${vars[htcommented]} == "" ]]; then

        # Set variable to match circumstance
        vars[htcommented]="neither"
        errorExit $vars[drupalCMD] $LINENO "Neither of the clauses are commented"

    fi || errorExit $vars[drupalCMD] $LINENO "Failed to read htaccess and set variables" ;;

16) # Now we begin acting on the information we have collected
    # If the www is meant to be commented
    if [[ ${vars[comment]} == "www" ]]; then

        # Is it already commented? if not
        if [[ ${vars[htcommented]} != "www" ]] && [[ ${vars[htcommented]} != "both" ]]; then

            # Setup and run the sed command to comment it using the line numbers we recorded
            vars[sedcmd_commentwww]=${vars[www_begin]}","${vars[www_end]}" s/^/#/"
            sed -i -e "${vars[sedcmd_commentwww]}" ${vars[htaccess]}; echo "Commenting .htaccess lines ${vars[www_begin]} - ${vars[www_end]}"

        fi

    # If the non-www is meant to be commented
    elif [[ ${vars[comment]} == "non" ]]; then

        # Is it already commented? if not
        if [[ ${vars[htcommented]} != "non" ]] && [[ ${vars[htcommented]} != "both" ]]; then

            # Setup and run the sed command to comment it using the line numbers we recorded
            vars[sedcmd_commentnon]=${vars[non_begin]}","${vars[non_end]}" s/^/#/"
            sed -i -e "${vars[sedcmd_commentnon]}" ${vars[htaccess]}; echo "Commenting .htaccess lines ${vars[non_begin]} - ${vars[non_end]}"

        fi

    # Otherwise if nothing was specified to be commented
    else

        # Something should have been specified
        errorExit ${vars[drupalCMD]} $LINENO "Nothing specified to be commented"

    fi || errorExit $vars[drupalCMD] $LINENO "Failed make comments to htaccess" ;;
17) # If the www was meant to be uncommented
    if [[ ${vars[uncomment]} == "www" ]]; then

        # Is it already uncommented? if not
        if [[ ${vars[htcommented]} == "www" ]] || [[ ${vars[htcommented]} == "both" ]]; then

            # Create the sed command to uncomment it and run the command
            vars[sedcmd_uncommentwww]=${vars[www_begin]}","${vars[www_end]}" s/#//"
            sed -i -e "${vars[sedcmd_uncommentwww]}" ${vars[htaccess]}; echo "Uncommenting lines ${vars[www_begin]} - ${vars[www_end]}"

        fi

    # If the non-www was meant ot be uncommented
    elif [[ ${vars[uncomment]} == "non" ]]; then

        # Is it already uncommented? if not
        if [[ ${vars[htcommented]} == "non" ]] || [[ ${vars[htcommented]} == "both" ]]; then

            # Create the sed command to uncomment it and run the command
            vars[sedcmd_uncommentnon]=${vars[non_begin]}","${vars[non_end]}" s/#//"
            sed -i -e "${vars[sedcmd_uncommentnon]}" ${vars[htaccess]}; echo "Uncommenting lines ${vars[non_begin]} - ${vars[non_end]}"

        fi

    # Otherwise if nothing was specified to be uncommented
    else

        # Something should have been specified to be uncommented
        errorExit ${vars[drupalCMD]} $LINENO "Nothing specified to be uncommented"

    fi || errorExit $vars[drupalCMD] $LINENO "Failed make uncomments to htaccess" ;;
 
18) echo "Completed changes to .htaccess"; echo || errorExit $vars[drupalCMD] $LINENO "Failed to print drupal 7 completion message" ;;

19) echo "Clearing Drupal 7 Cache.." || errorExit $vars[drupalCMD] $LINENO "Failed to echo cache clearing commencement message" ;;
20) drush -r /home/deused/www/ cc || errorExit $vars[drupalCMD] $LINENO "Failed to clear drupal cache" ;;
21) echo "Cache Cleared Successfully" || errorExit $vars[drupalCMD] $LINENO "Failed to print drupal 7 cache clearing completion message" ;;

22) vars[drupalENDLOOP]=true ;;

#   -------------------------------------------------------------------
#                                 End Here
#   -------------------------------------------------------------------

        esac
        ((vars[drupalCMD]++))
    done

}
