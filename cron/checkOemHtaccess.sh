#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/scripts/working/

#   ------------------------------------------------------------------
#                               * * *
#                           Liddle Script
#                               * * *
#   -------------------------------------------------------------------
#                               * * *  
#                     Begin Main Script Variables
#                               * * * 
#   -------------------------------------------------------------------

#   Program name
PROGNAME=$(basename $0)

#   Directory script is being run from 
USRDIR=$(pwd)"/"

#   Directory of script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )""/"

#   Store new arguments given to script in array
NEWARGS=("${@}")

#   Store all arguments given to script in array
#ALLARGS[0]=""

#   Will be used for storage of all loaded arguments
#LOADEDARGS[0]=""

#   Will be used to store filtered arguments from script arguments
SCRIPTARGS[0]=""

#   Will be used to store filtered options from script arguments
OPTS[0]=""

#   Will be used to store number of arguments not options given to the script
ARGNUM=""

#   Used for counters in script
COUNT=0

#   Argument 1 Given to Script
ARG1=$1

#   Logfile name
LOG="${DIR}${PROGNAME}.log"

#   Pipe name
PIPE="${DIR}${PROGNAME}.pipe"

#   Set initial endphase variable
ENDPHASE="false"

#   Has the script finished the getState function yet
#   I.E. are the CMD and PHASE variables accurate
EXECUTION="false"

#   Has the script began logging yet
LOGGING="false"

#   Execution argument given or not 
EXARG="false"

PHASE=1
CMD=1

#   -------------------------------------------------------------------
#                               * * *
#                     End Main Script Variables
#                               * * *
#   -------------------------------------------------------------------

#   -------------------------------------------------------------------
#                               * * *
#                       Begin Script Functions
#                               * * *
#   -------------------------------------------------------------------

function cleanUp {

#           --------------------------------------------------
#                     Function to remove old files
#                     Ignores any arguments given
#           --------------------------------------------------

    if [ -e "${DIR}${PROGNAME}.end" ]; then

        rm -f "${DIR}${PROGNAME}.end"

    fi

    if [ -e "${DIR}${PROGNAME}.log" ]; then

        rm -f "${DIR}${PROGNAME}.log"

    fi
    if [ -e "${PIPE}" ]; then
        rm -f "${PIPE}"
    fi

}

function startLog {

#           --------------------------------------------------
#                       Function to begin Logging
#  Can recieve one argument to indicate that the log should be appended
#           --------------------------------------------------

#   Ensure that the named pipe does not already exist before creating it
    if [ ! -e ${PIPE} ]; then
        mkfifo $PIPE
    fi

    # Redirect output of stdout and stderr to outputs 3 and 4
    # which are empty by default
    exec 3>&1 4>&2
    
    # Check to see if the function has had continue passed to it
    # If it has then append the log rather than overriding
    # Tee takes from stdin and writes to file $LOG
    # Tee's stdin will redirect from the $PIPE (Redirection is the capturing of something)
    # Redirect tees stdout to 3 which is the stdout of the script
    # & makes this a background process
    if [ "${1}" == "continue" ]; then
        tee -a ${LOG} < $PIPE >&3 &
    else
        tee ${LOG} < $PIPE >&3 &
    fi

    # Save the process id of tee so it can be closed later
    TPID=$!

    # Redirects the stdout of the script to the $PIPE
    # Also redirects stderr to stdout so they are both redirected
    exec > $PIPE 2>&1
    # Indicate script has began logging
    LOGGING="true"

}

function endLog {

#           --------------------------------------------------
#                        Function to end Logging
#                      Ignores any arguments given
#           --------------------------------------------------

    # Restore stdout and stderr to their defaults and close 3 and 4
    exec 1>&3 3>&- 2>&4 4>&-
    # Wait until tee has closed, it will close because the named pipe has
    # by the closing of 3 and 4 
    wait $TPID
    # Finally remove the pipe
    rm $PIPE
    # Script no longer logging
    LOGGING="false"

}


function errorExit {

#           --------------------------------------------------
#                  Function for exit due to fatal error
#         Requires 3 Arguments, CMD Number, Line number and error
#           --------------------------------------------------

    echo ""
    echo "---------------------------------------------------"
    echo "                    FATAL ERROR                    "
    echo "---------------------------------------------------"
    echo ""
    echo "Script File: ${PROGNAME}"
    echo "Script Line: ${2}"
    echo "Error: ${3:-"Unknown Error"}" 1>&2

    if [ -e "${DIR}${PROGNAME}.end" ]; then
        echo ""
        rm -f "${DIR}${PROGNAME}.end" || echo "Error could not replace prior save" 
    fi

    #   Write the current command and the current phase to file if the execution variable is true
    #   This variable indicates whether the script has reached a stage where the CMD and PHASE
    #   variables are reliably accurate and not yet to be loaded
    if [ $EXECUTION == "true" ]; then
        END="${PHASE}\n${CMD}"
        echo -e $END>${DIR}${PROGNAME}.end || echo "Unable to save progress to file"
    else
        echo ""
        echo "Progress not saved"
        echo "Script progress variables not yet set"
    fi

    #   Save the arguments to file
    for arg in "${SCRIPTARGS[@]}"; do

        echo -e "${arg}">>"${DIR}${PROGNAME}.end" || echo "Unable to save arguments to file"

    done

 
    echo ""
    echo "Preparing to exit"
    echo ""
    if [ $LOGGING == "true" ]; then
        echo "Ending Log ----------------------------------------"; endLog || echo "Unable to close or remove logging pipe"
        echo "Exiting..."
    else
        echo "Logging not running..."
        echo "Exiting -------------------------------------------"
    fi
    echo ""
    exit 1

}

function trapped {

#           --------------------------------------------------
#                    Function for Trapping Interupts
#                      Ignores any arguments given
#           --------------------------------------------------

    errorExit ${CMD} ${LINENO} "Script terminated by user"
    
}

function loadFile {

#           --------------------------------------------------
#                    Function to load saved progress
#                      Ignores any arguments given
#           --------------------------------------------------


    if [ -r "${DIR}${PROGNAME}.end" ]; then
        
        # Start logging and append to the last log
        startLog continue
        echo "Fetching progress from file"
        # Fetch the phase and command variables from the saved file
        PHASE=$(sed '1q;d' ${DIR}${PROGNAME}.end) || errorExit $CMD $LINENO "Failed to read phase"
        CMD=$(sed '2q;d' ${DIR}${PROGNAME}.end) || errorExit $CMD $LINENO "Failed to read command"

        # Double check they are both integers
        if [[ "${PHASE}" =~ ^-?[0-9]+$ ]]; then
            echo "Successfully read prior phase"
        else
            errorExit $CMD $LINENO "Failed to interpret prior phase integer"
        fi
        if [[ "${CMD}" =~ ^-?[0-9]+$ ]]; then
            echo "Successfully read prior command"
        else
            errorExit $CMD $LINENO "Failed to interpret prior command integer"
        fi

        # Read all lines from save file and save as an array
        while IFS= read -r line; do

            LOADEDARGS[$COUNT]="${line}"
            ((COUNT++))

        done < "${DIR}${PROGNAME}.end"

        # Remove first two as they are the PHASE and CMD variables
        unset LOADEDARGS[1]
        unset LOADEDARGS[0]

        # Combine arguments from save file with all arguments array
        ALLARGS=("${ALLARGS[@]}" "${LOADEDARGS[@]}")

        # Reset count argument for use by other variables
        COUNT="0"

        echo "Continuing from prior exit"
        sleep 1
    else
        echo ""
        echo "---------------------------------------------------"
        echo "                    FATAL ERROR                    "
        echo "---------------------------------------------------"
        echo ""
        echo "Cannot find or cannot access saved progress file"
        echo "Exiting..."
        echo "---------------------------------------------------"
        echo ""
        exit 1
    fi

}

function getState {

#           --------------------------------------------------
#               Function for discovering existing progress
#              Takes no arguments only gets script argument
#                  - TO BE RUN UPON START OF SCRIPT -
#           --------------------------------------------------

    case ${ARG1} in

    #   Check for saved progress and question user for action if saved progress exists
    #   Otherwise begin logging and continue with script
    "") if [ -e "${DIR}${PROGNAME}.end" ]; then
            while :
                do
                read -p "A saved progress file exists, would you like to continue from the saved progress? (y/n)" CONT
                if [[ $CONT == "y" ]] || [[ $CONT == "Y" ]]; then
                    loadFile
                elif [[ $CONT == "n" ]] || [[ $CONT == "N" ]]; then
                    startLog
                else
                    echo "Please input a valid answer (y/n)"
                    continue
                fi
            break
            done
        else 
            startLog
        fi ;;
  
    #   help argument given, display help and exit
    "-h" | "help" | "--help") 
                echo ""  
                echo "---------------------------------------------------------------------"
                echo "                           LIDDLE SCRIPT                             "
                echo "---------------------------------------------------------------------"
                echo ""
                echo "       This script examines the htaccess of the account given"
                echo "                   for the dev site robots clause"
                echo ""
                echo "                  Accpets only one account argument"
                echo ""
                echo "                          VALID ARGUMENTS                            "
                echo "---------------------------------------------------------------------"
                echo ""
                echo "     -h | --help"              
                echo "                       Open the scripts help"
                echo ""
                echo "     -l | --load"
                echo "                       Resume script from prior point"
                echo ""
                echo "     -c | --cleanup"
                echo "                       Clean log file and saved progress file"
                echo ""
                echo "---------------------------------------------------------------------"                    
                echo ""
                EXARG="true"
                exit 1
                ;;

    # cleanup argument given, run cleanUp function and quit
    "--cleanup" | "--clean" | "-c") cleanUp
                                    EXARG="true"
                                    exit 1 ;; 
    #   resume argument given, restart with logging and ldfile argument
    "--load" | "-l")        EXARG="true"
                            loadFile
                            ;;
    #   Start log if another argument is given but is not a option
    *)                  startLog ;;
    esac
       
}

function getArgs {

#   ------------------------------------------------------------------
#   Function for filtering execution arguments out of script arguments
#              Takes no arguments only gets script argument
#   ------------------------------------------------------------------

    if [ "${1}" == "args" ]; then

        #   If EXARG is true, an argument was given as the first one that changed the script state
        #   therefore the first argument should be ignored
        if [ "${EXARG}" == "true" ]; then

            #   For each argument stored in the all args array (Stored by the loadFile function) store in the script args array
            for i in "${ALLARGS[@]}"; do

                SCRIPTARGS[$COUNT]="${i}"
                ((COUNT++))

            done

            #   For each argument given to the script initally minus the first one as it was an argument store in the scriptargs array
            for i in "${NEWARGS[@]:1}"; do

                SCRIPTARGS[$COUNT]="${i}"
                ((COUNT++))

            done

        #   If EXARG is false, then no execution argument to modify the state was given as the first argument
        elif [ "${EXARG}" == "false" ]; then

            #   For each argument stored in the all args array (Stored by the loadFile function) store in the script args array
            for i in "${ALLARGS[@]}"; do

                SCRIPTARGS[$COUNT]="${i}"
                ((COUNT++))

            done

            #   For each argument given to the script initially store them in the script args array
            for i in "${NEWARGS[@]}"; do

                SCRIPTARGS[$COUNT]="${i}"
                ((COUNT++))

            done

        else

            #   EXARG should only be equal to true or false
            errorExit $CMD $LINENO "Invalid EXARG value given"

        fi
    
        #   Return count variable to 0 for use by other functions    
        COUNT=0
        #   Store the number of arguments given
        ARGNUM=${#SCRIPTARGS[@]}

    elif [ "${1}" == "opts" ]; then

        if [ "${EXARG}" == "true" ]; then
            
            for i in "${NEWARGS[@]:1}"; do

                OPTS[$COUNT]="${i}"
                ((COUNT++))

            done

        elif [ "${EXARG}" == "false" ]; then

            for i in "${NEWARGS[@]}"; do

                OPTS[$COUNT]="${i}"
                ((COUNT++))
            
            done
            
        else

            #   EXARG should only be equal to true or false
            errorExit $CMD $LINENO "Invalid EXARG value given"
            
        fi

        #   Return count variable to 0 for use by other functions
        COUNT=0

    fi

}

#           --------------------------------------------------
#                        Script Phase Definitions
#
#                           --  Variables --
#
#                              $SCRIPTARGS
#                 contains arguments given to the script
#                                $ARGNUM
#                 contains the number of arguments as above
#                                 $OPTS
#                 contains the options given to the script
#                                 $LOG
#                   contains the path of the log file
#                                 $DIR
#                   contains the directory of the script
#                              $PROGNAME
#                    contains the name of the script
#                               $USRDIR
#          contains the directory of the user running the script
#                                $HOME
#                   Contains the users home directory
#
#           --------------------------------------------------

function phase1 {

    ENDLOOP=false
    while [ ${ENDLOOP} = false ]; do
        case ${CMD} in
            1) line1='RewriteCond %{HTTP_HOST} ^dev.oemgroup.com.au$' || errorExit $CMD $LINENO "Could not set line 1 variable"
               line2='RewriteRule ^robots\.txt$ robots_dev.txt' || errorExit $CMD $LINENO "Could not set line 2 variable"
               filelocation="/home/${SCRIPTARGS[0]}/public_html/.htaccess"
               if [ ! -e $filelocation ]; then
                    echo "User does not exist"
                    cleanUp
                    exit 1
               fi;;
            2) if fgrep -q "${line1}" $filelocation; then
                    line1_exists=1
                    if fgrep -q "${line2}" $filelocation; then
                        line2_exists=1
                    else
                        line2_exists=0
                    fi
               else
                    line1_exists=0
               fi || errorExit $CMD $LINENO "Error checking for lines" ;;
            3) bothlines=$((line1_exists + line2_exists))
               if [ $bothlines == 2 ]; then 
                    # Both lines exist we should exit as this is how it should be
                    cleanUp
                    exit 1
               else
                    # Both lines do not exist we should double check that there is not only one line missing
                    if [ $bothlines == 0 ]; then
                        # Both lines are missing we should add them
                        addlines=1
                    else
                        # Only one line is missing we should error and exit as this is not ok
                        errorExit $CMD $LINENO "Only one line is missing, needs debugging"
                    fi
               fi  || errorExit $CMD $LINENO "Error processing state" ;;
            4) ENDLOOP=true ;;
        esac
        ((CMD++))
    done

}

function phase2 {

    ENDLOOP=false
    while [ ${ENDLOOP} = false ]; do
        case ${CMD} in
            1) occurance=0
               modrewrite=0 
               enteredrewrite=0 
               lineno=0 
               beginwrite=0 || errorExit $CMD $LINENO "Error Setting Variables" ;;
            2) while read p; do

                    ((lineno++))

                    # Record the opening and closing of modules in the htaccess file
                    if [[ $p == *"<IfModule"* ]]; then
                        ((occurance++))
                    elif [[ $p == *"/IfModule"* ]]; then
                        ((occurance--))
                    fi
                    
                    # Check to see if we have found the mod_rewrite.c section yet
                    if [[ $p == *"mod_rewrite.c"* ]]; then
                        enteredrewrite=1
                    fi

                    # We are in the rewrite section when occurance reaches 0 then the mod_rewrite.c has closed
                        if [[ $enteredrewrite == 1 ]]; then
                            if [[ $occurance == 0 ]]; then
                            echo "Htaccess missing Dev Robots Clause"
                            echo "Rewrite of .htaccess required for:"
                            echo "- ${SCRIPTARGS[0]}"
                            beginwrite=$lineno
                            awk "NR==${beginwrite}{print \"\n    RewriteCond %{HTTP_HOST} ^dev.oemgroup.com.au$ \n    RewriteRule ^robots\\\.txt$ robots_dev.txt\"}1" $filelocation >"${filelocation}.tmp" || errorExit $CMD $LINENO "Error with rewrite command"
                            mv ${filelocation}.tmp $filelocation
                            echo "Automated file writing complete"
                            echo "Dev Robots clause added successfully"
                            chown ${SCRIPTARGS[0]}:${SCRIPTARGS[0]} $filelocation
                            echo "Ownership changed successfully"
                            echo "Exiting... "
                            cleanUp
                            exit 1
                        fi
                    fi

               done <$filelocation || errorExit $CMD $LINENO "Error with file modifications" ;;
            3) ENDLOOP=true ;;
        esac
        ((CMD++))
    done

}

#   -------------------------------------------------------------------
#                               * * *
#                        End Script Functions
#                               * * *
#   -------------------------------------------------------------------

#   -------------------------------------------------------------------
#                               * * *
#                            Begin Traps
#                               * * *
#   -------------------------------------------------------------------

#   Trap to watch for interupt, runs trapped function
trap trapped SIGHUP SIGINT SIGTERM


#   -------------------------------------------------------------------
#                               * * *
#                             End Traps
#                               * * *
#   -------------------------------------------------------------------

#   -------------------------------------------------------------------
#                               * * *
#                             Run Script
#                               * * *
#   -------------------------------------------------------------------

# Check the starting state of the script, e.g. first run, resuming old
# progress etc..
getState

# Get any arguments given to the script and filter out the options
# like -h or -l, then store them in the SCRIPTARGS array
# Then do the same with the options
# The number of arguments can be accessed with the variable $ARGNUM
getArgs args
getArgs opts

# Set the execution variable to true to indicate the scripts CMD and PHASE
# Variables accurately represent the scripts progress
EXECUTION="true"

#           --------------------------------------------------
#                           Script Phases Run
#
#                           --  Variables --
#
#                              $SCRIPTARGS
#                 contains arguments given to the script
#                                $ARGNUM
#                 contains the number of arguments as above
#                                 $OPTS
#                 contains the options given to the script
#                                 $LOG
#                   contains the path of the log file
#                                 $DIR
#                   contains the directory of the script
#                              $PROGNAME
#                    contains the name of the script
#                               $USRDIR
#          contains the directory of the user running the script
#                                $HOME
#                   Contains the users home directory    
#
#           --------------------------------------------------

    while [ ${ENDPHASE} = false ]; do
        case ${PHASE} in
            1) phase1 
                CMD=1
                ;;
            2) phase2
                CMD=1
                ;;
            3) ENDPHASE=true ;;
        esac
        ((PHASE++))
    done

#           --------------------------------------------------
#                           Script Phases End
#           --------------------------------------------------

# Stop Logging
endLog
# Cleanup the log and any other files left
cleanUp

#   -------------------------------------------------------------------
#                               * * *
#                             End Script
#                               * * *
#   -------------------------------------------------------------------
