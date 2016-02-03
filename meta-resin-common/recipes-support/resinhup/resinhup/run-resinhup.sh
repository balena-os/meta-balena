#!/bin/bash

# Default values
TAG=latest
FORCE=no
LOGFILE=/tmp/`basename "$0"`.log
LOG=yes

# Help function
function help {
    cat << EOF
Wrapper to run host OS updates on resin distributions.
$0 <OPTION>

Options:
  -h, --help
        Display this help and exit.

  -f, --force
        Run the resinhup tool without fingerprints check and validation.

  -t <TAG>, --tag <TAG>
        Use a specific tag for resinhup image.
        Default: latest.

  -n, --nolog
        By default tool logs to stdout and file. This flag deactivates log to
        $LOGFILE file.
EOF
}

# If things fail try to bring board back to the initial state
function tryup {
    systemctl start resin-supervisor > /dev/null 2>&1
    systemctl start update-resin-supervisor.timer > /dev/null 2>&1
}

# Catch INT signals and try to bring things back
trap ctrl_c INT
function ctrl_c() {
    resin-device-progress --percentage 100 --state "Host OS Update: Failed. Contact support..."
    log "Trapped INT signal"
    tryup
    exit 1
}

# Log function helper
function log {
    # Address log levels
    case $1 in
        ERROR)
            loglevel=ERROR
            shift
            ;;
        WARN)
            loglevel=WARNING
            shift
            ;;
        *)
            loglevel=LOG
            ;;
    esac
    ENDTIME=$(date +%s)
    if [ "z$LOG" == "zyes" ]; then
        printf "[%09d%s%s\n" "$(($ENDTIME - $STARTTIME))" "][$loglevel]" "$1" | tee -a $LOGFILE
    else
        printf "[%09d%s%s\n" "$(($ENDTIME - $STARTTIME))" "][$loglevel]" "$1"
    fi
    if [ "$loglevel" == "ERROR" ]; then
        resin-device-progress --percentage 100 --state "Host OS Update: Failed. Contact support..."
        exit 1
    fi
}

#
# MAIN
#

# Log timer
STARTTIME=$(date +%s)

# Parse arguments
while [[ $# > 0 ]]; do
    arg="$1"

    case $arg in
        -h|--help)
            help
            exit 0
            ;;
        -f|--force)
            FORCE="yes"
            ;;
        -t|--tag)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            TAG=$2
            shift
            ;;
        -n|--nolog)
            LOG=no
            ;;
        *)
            log ERROR "Unrecognized option $1."
            ;;
    esac
    shift
done

resin-device-progress --percentage 10 --state "Host OS Update: Preparing..."

# Init log file
# LOGFILE init and header
if [ "$LOG" == "yes" ]; then
    echo "================"`basename "$0"`" HEADER START====================" > $LOGFILE
    date >> $LOGFILE
    echo "Force mode: $FORCE" >> $LOGFILE
    echo "Resinhup tag: $TAG" >> $LOGFILE
fi

# Get the slug
slug=$(jq -r .deviceType /mnt/conf/config.json)
if [ -z $slug ]; then
    log ERROR "Could not get the SLUG."
fi
log "Found slug $slug for this device."

# Avoid supervisor cleaning up resinhup and stop containers
log "Stop all containers..."
systemctl stop resin-supervisor > /dev/null 2>&1
systemctl stop update-resin-supervisor.timer > /dev/null 2>&1
rce stop $(rce ps -a -q) > /dev/null 2>&1

# Pull resinhup and tag it accordingly
log "Pulling resinhup..."
rce pull registry.resinstaging.io/resinhup/resinhup-$slug:$TAG
if [ $? -ne 0 ]; then
    tryup
    log ERROR "Could not pull registry.resinstaging.io/resinhup/resinhup-$slug:$TAG ."
fi
rce tag -f registry.resinstaging.io/resinhup/resinhup-$slug:$TAG resinhup

# Run resinhup
log "Running resinhup..."
resin-device-progress --percentage 50 --state "Host OS Update: Running..."
RESINHUP_STARTTIME=$(date +%s)
if [ "$FORCE" == "yes" ]; then
    log "Running in force mode..."
    rce run --privileged --rm --net=host -e RESINHUP_FORCE=yes --volume /:/host resinhup
else
    log "Not running in force mode..."
    rce run --privileged --rm --net=host                       --volume /:/host resinhup
fi
if [ $? -eq 0 ]; then
    RESINHUP_ENDTIME=$(date +%s)
    resin-device-progress --percentage 100 --state "Host OS Update: Done. Rebooting device..."
    log "Update suceeded in $(($RESINHUP_ENDTIME - $RESINHUP_STARTTIME)) seconds."
    # Everything is fine - Reboot
    log "Rebooting board in 5 seconds..."
    nohup bash -c " /bin/sleep 5 ; /sbin/reboot " &
else
    RESINHUP_ENDTIME=$(date +%s)
    # Don't tryup so support can have a chance to see what went wrong and how to recover
    log ERROR "Update failed after $(($RESINHUP_ENDTIME - $RESINHUP_STARTTIME)) seconds. Check the logs."
fi

# Success
exit 0
