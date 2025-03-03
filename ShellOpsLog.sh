###################################################################################################
#                             | ShellOpsLog - Command Logger |                                    #
#-------------------------------------------------------------------------------------------------#
#  - Logs all executed commands with timestamps.                                                  #
#  - Saves commands to a CSV file with the following columns: "Timestamp","User","Path","Command" #
#                                                                                                 #
# ## Usage ##                                                                                     #
#  - Load this script in your shell startup file (e.g. ~/.zshrc or ~/.bashrc).                    #
#         source /path/to/ShellOpsLog.sh                                                          #
#  - To begin logging, run:                                                                       #
#         start_operation_log                                                                     #
#     OR specify a custom path:                                                                   #
#         start_operation_log /path/to/logdir                                                     #
#     Use the -AutoStart option to start logging without confirmation:                            #
#         start_operation_log -AutoStart                                                          #
#  - To stop logging, run:                                                                        #
#         stop_operation_log                                                                      #
#                                                                                                 #
# ## Credits ##                                                                                   #
#   Created by DrorDvash                                                                          #
#   Repo: https://github.com/DrorDvash/ShellOpsLog                                                #
###################################################################################################

start_operation_log() {
    local auto_start=0
    local log_dir="$HOME/OperationLogs"

    # Process arguments: if "-AutoStart" is provided, set auto_start flag;
    # otherwise, treat the argument as a custom log directory.
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -AutoStart|-autostart)
                auto_start=1
                shift
                ;;
            *)
                log_dir="$1"
                shift
                ;;
        esac
    done

    # Return silently if logging is already active
    [ -n "$OPERATION_LOG_ACTIVE" ] && {
        echo "Logging already active: $OPERATION_LOG_FILE"
        return
    }

    # Generate log file path using current date (YYYY-MM-DD)
    local LOG_DATE
    LOG_DATE=$(date +"%Y-%m-%d")
    local DEFAULT_FILE="${log_dir%/}/operation_log_${LOG_DATE}.csv"

    # If not auto-starting, prompt the user for confirmation
    if [ "$auto_start" -ne 1 ]; then
        echo -n "Start logging this window to ${DEFAULT_FILE}? [Y/n] "
        read -r response
        case "${response:0:1}" in
            y|Y|"") ;;
            *) echo "Logging skipped"; return ;;
        esac
    fi

    # Create log directory if needed and add header if the file is new
    mkdir -p "$(dirname "$DEFAULT_FILE")"
    [ -f "$DEFAULT_FILE" ] || echo '"Timestamp","User","Path","Command"' > "$DEFAULT_FILE"

    # Define a logging helper function (do not export this)
    _operation_log_command() {
        local cmd="$1"
        printf '"%s","%s","%s","%s"\n' \
            "$(date "+%Y-%m-%d %H:%M:%S")" \
            "$(whoami)" \
            "$(pwd)" \
            "${cmd//\"/\"\"}" >> "$OPERATION_LOG_FILE"
    }

    # Shell-specific setup:
    if [ -n "$BASH_VERSION" ]; then
        # Save the original PROMPT_COMMAND if not already saved
        if [ -z "$ORIG_PROMPT_COMMAND" ]; then
            ORIG_PROMPT_COMMAND="$PROMPT_COMMAND"
        fi
        # PROMPT_COMMAND runs before each prompt; log the last command from history.
        PROMPT_COMMAND='_operation_log_command "$(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//")"'
    elif [ -n "$ZSH_VERSION" ]; then
        # Define a preexec hook for Zsh to log commands before they execute.
        _operation_preexec() { _operation_log_command "$1"; }
        autoload -Uz add-zsh-hook
        add-zsh-hook preexec _operation_preexec
    fi

    export OPERATION_LOG_ACTIVE=1
    export OPERATION_LOG_FILE="$DEFAULT_FILE"
    echo "Command logging active: $OPERATION_LOG_FILE"
}

stop_operation_log() {
    if [ -n "$OPERATION_LOG_ACTIVE" ]; then
        unset OPERATION_LOG_ACTIVE
        unset OPERATION_LOG_FILE
        if [ -n "$BASH_VERSION" ]; then
            PROMPT_COMMAND="$ORIG_PROMPT_COMMAND"
            unset ORIG_PROMPT_COMMAND
        elif [ -n "$ZSH_VERSION" ]; then
            autoload -Uz add-zsh-hook
            add-zsh-hook -d preexec _operation_preexec
        fi
        echo "Command logging stopped"
    else
        echo "No active logging session to stop"
    fi
}

###############################################################################
# Uncomment below to prompt question on any new windows/tab -> "Start logging this window to '<path>'? [Y/n]"
# start_operation_log
# OR
# start_operation_log "$(HOME)/Projects/MyClient"

# Uncomment below to auto-start logging
# start_operation_log -AutoStart
###############################################################################
