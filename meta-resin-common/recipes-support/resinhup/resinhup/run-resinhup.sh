#!/bin/bash

# Default values
TAG=latest
SUPERVISOR_TAG=
FORCE=no
LOGFILE=/tmp/`basename "$0"`.log
LOG=yes

source /etc/profile

# Help function
function help {
    cat << EOF
Wrapper to run host OS updates on resin distributions.
$0 <OPTION>

Options:
  -h, --help
        Display this help and exit.

  -f, --force
        Run the resinhup tool withut fingerprints check and validation.

  -t <TAG>, --tag <TAG>
        Use a specific tag for resinhup image.
        Default: latest.

  -s <SUPERVISOR TAG>, --supervisor-tag <SUPERVISOR TAG>
        In the case of a successful host OS update, bring in a newer supervisor too
        using this tag.

  -n, --nolog
        By default tool logs to stdout and file. This flag deactivates log to
        $LOGFILE file.
EOF
}

# If things fail try to bring board back to the initial state
function tryup {
    systemctl start resin-supervisor > /dev/null 2>&1
    systemctl start update-resin-supervisor.timer > /dev/null 2>&1
    /etc/init.d/crond start > /dev/null 2>&1
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

function runhacks {
    # we might need to repartition this so make sure it is unmounted
    umount /boot

    # can't fix label of BTRFS partition from container
    if [ -d /mnt/data ]; then
        BTRFS_MOUNTPOINT=/mnt/data
    elif [ -d /mnt/data-disk ]; then
        BTRFS_MOUNTPOINT=/mnt/data-disk
    else
        log ERROR "Can't find the resin-data mountpoint."
    fi
    btrfs filesystem label $BTRFS_MOUNTPOINT resin-data

    # Some devices never actually update /etc/timestamp because they are hard-rebooted.
    # Force a /etc/timestamp update so we don't get into TLS issues.
    # This assumes that current date is valid - which should be because we can't remotely
    # update a device with outdated time (vpn would not be available so ssh would not
    # work).
    # Only applies on sysvinit systems
    if [[ $(readlink /sbin/init) == *"sysvinit"* ]]; then
        log "Save timestamp..."
        date -u +%4Y%2m%2d%2H%2M%2S > /etc/timestamp
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
        -s|--supervisor-tag)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            SUPERVISOR_TAG=$2
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
if [ -f /mnt/conf/config.json ]; then
    slug=$(jq -r .deviceType /mnt/conf/config.json)
elif [ -f /mnt/data-disk/config.json ]; then
    slug=$(jq -r .deviceType /mnt/data-disk/config.json)
else
    log ERROR "Don't know where config.json is."
fi
if [ -z $slug ]; then
    log ERROR "Could not get the SLUG."
fi
log "Found slug $slug for this device."

# Avoid supervisor cleaning up resinhup and stop containers
log "Stopping all containers..."
systemctl stop resin-supervisor > /dev/null 2>&1
systemctl stop update-resin-supervisor.timer > /dev/null 2>&1
rce stop $(rce ps -a -q) > /dev/null 2>&1
log "Removing all containers..."
rce rm $(rce ps -a -q) > /dev/null 2>&1
/etc/init.d/crond stop > /dev/null 2>&1 # We might have cron jobs which restart supervisor

# Pull resinhup and tag it accordingly
log "Pulling resinhup..."
rce pull registry.resinstaging.io/resinhup/resinhup-$slug:$TAG
if [ $? -ne 0 ]; then
    tryup
    log ERROR "Could not pull registry.resinstaging.io/resinhup/resinhup-$slug:$TAG ."
fi
rce tag -f registry.resinstaging.io/resinhup/resinhup-$slug:$TAG resinhup

# Run hacks
runhacks

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
RESINHUP_EXIT=$?
if [ $RESINHUP_EXIT -eq 0 ] || [ $RESINHUP_EXIT -eq 2 ]; then # exitcode 0 means update done while exit code 2 means that only intermediate step was done and will continue after reboot
    RESINHUP_ENDTIME=$(date +%s)

    # Hack rpi2 supervisor image: resin/rpi-supervisor -> resin/armv7hf-supervisor
    source /etc/supervisor.conf
    if [ "$SUPERVISOR_IMAGE" == "resin/rpi-supervisor" ] && [ "$slug" == "raspberry-pi2" ]; then
        log "On rpi2 we hack a docker tag for resin-supervisor..."
        rce tag -f resin/rpi-supervisor resin/armv7hf-supervisor
    fi

    if [ $RESINHUP_EXIT -eq 0 ]; then
        if [ ! -z $SUPERVISOR_TAG ]; then
            # Update supervisor
            resin-device-progress --percentage 75 --state "Host OS Update: Done. Updating supervisor..."
            log "Updating supervisor..."
            rce pull "$SUPERVISOR_IMAGE:$SUPERVISOR_TAG"
            if [ $? -ne 0 ]; then
                tryup
                log ERROR "Could not pull $SUPERVISOR_IMAGE:$TAG ."
            fi
            rce tag -f "$SUPERVISOR_IMAGE:$SUPERVISOR_TAG" "$SUPERVISOR_IMAGE:latest"
        fi
        resin-device-progress --percentage 100 --state "Host OS Update: Done. Rebooting device..."
    else
        resin-device-progress --percentage 100 --state "Host OS Update: Please restart update after reboot..."
    fi
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
exit $RESINHUP_EXIT
