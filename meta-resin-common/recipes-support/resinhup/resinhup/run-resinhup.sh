#!/bin/bash

# Default values
TAG=1.0
FORCE=no
STAGING=no
LOGFILE=/tmp/`basename "$0"`.log
LOG=yes
ONLY_SUPERVISOR=no
NOREBOOT=no

# Don't run anything before this source as it sets PATH here
source /etc/profile

BOOT_MOUNTPOINT="$(grep $(blkid | grep resin-boot | cut -d ":" -f 1) /proc/mounts | cut -d ' ' -f 2)"

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

  --staging
        Do this update for devices in staging.
        By default resinhup assumes the devices are in production.

  -t <TAG>, --tag <TAG>
        Use a specific tag for resinhup image.
        Default: 1.0 .

  --remote <REMOTE>
        Run the updater with this remote configuration.
        This argument will be passed to resinhup and will be used as the location from
        which the update bundles will be downloaded.

  --hostos-version <HOSTOS_VERSION>
        Run the updater for this specific HostOS version.
        This is a mandatory argument.

  --supervisor-registry <SUPERVISOR REGISTRY>
        Update supervisor getting the image from this registry.

  --supervisor-tag <SUPERVISOR TAG>
        In the case of a successful host OS update, bring in a newer supervisor too
        using this tag.

  --only-supervisor
        Update only the supervisor.

  -n, --nolog
        By default tool logs to stdout and file. This flag deactivates log to
        $LOGFILE file.

  --no-reboot
        Don't reboot if update is successful. This is useful when debugging.
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
    /usr/bin/resin-device-progress --percentage 100 --state "Resin Update: Failed. Contact support..."
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
        /usr/bin/resin-device-progress --percentage 100 --state "Resin Update: Failed. Contact support..."
        exit 1
    fi
}

function runPreHacks {
    # we might need to repartition this so make sure it is unmounted
    log "Make sure resin-boot is unmounted..."
    if [ -z $BOOT_MOUNTPOINT ]; then
        log WARN "Mount point for resin-boot partition could not be found. Probably is already unmounted."
    else
        umount $BOOT_MOUNTPOINT &> /dev/null
    fi

    # can't fix label of BTRFS partition from container
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

    # Some old devices didn't have curl which we need for supervisor update
    # If that's the case, replace by wget usage
    if which curl &>/dev/null; then
        log "Curl hack: Curl in place."
    else
        script_path="/usr/bin/update-resin-supervisor"
        if ! [ -e $script_path ]; then
            log "Curl hack: Missing $script_path, aborting."
        fi
        sed --in-place "s|curl --silent --header \"User-Agent:\" --compressed|wget -qO-|" $script_path
        sed --in-place "s|curl -s --compressed|wget -qO-|" $script_path
    fi
}

function runPostHacks {
    # Switch from rce to docker - HostOS version with this change is 1.1.5
    log "Docker hack: Make switch from rce to docker backwards compatible"
    if version_gt $HOSTOS_VERSION "1.1.5" || [ "$HOSTOS_VERSION" == "1.1.5" ]; then
        if [ "$DOCKER" == "rce" ]; then
            # Stop rce first in all the ways possible :)
            systemctl stop rce &> /dev/null
            killall rce
            sleep 10 # wait for rce to gracefully shutdown
            dockerpid=$(pidof rce)
            kill -9 $dockerpid &> /dev/null

            if [ -d "$BTRFS_MOUNTPOINT/docker" ]; then
                log ERROR "$BTRFS_MOUNTPOINT/docker already exists"
            else
                mv -f $BTRFS_MOUNTPOINT/rce $BTRFS_MOUNTPOINT/docker
                sync
            fi
        else
            log "Docker hack: Avoided as docker is already switched from rce."
        fi
    else
        log "Docker hack: Avoided as requested hostOS version is not >= 1.1.5."
    fi
}

# Test if a version is greater than another
function version_gt() {
    test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"
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
        --staging)
            STAGING="yes"
            ;;
        -t|--tag)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            TAG=$2
            shift
            ;;
        --hostos-version)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            HOSTOS_VERSION=$2
            shift
            ;;
        --remote)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            REMOTE=$2
            shift
            ;;
        --supervisor-registry)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            SUPERVISOR_REGISTRY=$2
            shift
            ;;
        --supervisor-tag)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            UPDATER_SUPERVISOR_TAG=$2
            shift
            ;;
        --only-supervisor)
            ONLY_SUPERVISOR=yes
            ;;
        -n|--nolog)
            LOG=no
            ;;
        --no-reboot)
            NOREBOOT=yes
            ;;
        *)
            log ERROR "Unrecognized option $1."
            ;;
    esac
    shift
done

/usr/bin/resin-device-progress --percentage 10 --state "Resin Update: Preparing..."

# Check that HostOS version was provided
if [ -z "$HOSTOS_VERSION" ]; then
    log ERROR "--hostos-version is required."
fi

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

# Detect BTRFS_MOUNTPOINT
if [ -d /mnt/data ]; then
    BTRFS_MOUNTPOINT=/mnt/data
elif [ -d /mnt/data-disk ]; then
    BTRFS_MOUNTPOINT=/mnt/data-disk
else
    log ERROR "Can't find the resin-data mountpoint."
fi

# Run pre hacks
runPreHacks

# Detect containers engine
if which docker &> /dev/null; then
    DOCKER=docker
elif which rce &> /dev/null; then
    DOCKER=rce
else
    log ERROR "Can't detect the containers engine on the host OS."
fi

# Detect arch
source /etc/supervisor.conf
arch=`echo "$SUPERVISOR_IMAGE" | sed -n "s/.*\/\([a-zA-Z0-9]*\)-.*/\1/p"`
if [ -z "$arch" ]; then
    log ERROR "Can't detect arch from /etc/supervisor.conf ."
else
    log "Detected arch: $arch ."
fi

# We need to stop update-resin-supervisor.timer otherwise it might restart supervisor which
# will delete downloaded layers. Same for cron jobs.
systemctl stop update-resin-supervisor.timer > /dev/null 2>&1
/etc/init.d/crond stop > /dev/null 2>&1 # We might have cron jobs which restart supervisor

# Supervisor update
if [ ! -z "$UPDATER_SUPERVISOR_TAG" ]; then
    log "Supervisor update requested through arguments ."
    /usr/bin/resin-device-progress --percentage 25 --state "Resin Update: Updating supervisor..."

    # Default UPDATER_SUPERVISOR_IMAGE to the one in /etc/supervisor.conf
    if [ -z "$SUPERVISOR_REGISTRY" ]; then
        UPDATER_SUPERVISOR_IMAGE=$SUPERVISOR_IMAGE
    else
        UPDATER_SUPERVISOR_IMAGE="$SUPERVISOR_REGISTRY/resin/$arch-supervisor"
    fi

    log "Update to supervisor $UPDATER_SUPERVISOR_IMAGE:$UPDATER_SUPERVISOR_TAG..."

    log "Updating supervisor..."
    if [[ $(readlink /sbin/init) == *"sysvinit"* ]]; then
        # Supervisor update on sysvinit based OS
        $DOCKER pull "$UPDATER_SUPERVISOR_IMAGE:$UPDATER_SUPERVISOR_TAG"
        if [ $? -ne 0 ]; then
            tryup
            log ERROR "Could not update supervisor to $UPDATER_SUPERVISOR_IMAGE:$UPDATER_SUPERVISOR_TAG ."

        fi
        $DOCKER tag -f "$SUPERVISOR_IMAGE:$SUPERVISOR_TAG" "$SUPERVISOR_IMAGE:latest"
    else
        # Supervisor update on systemd based OS
        /usr/bin/update-resin-supervisor --supervisor-image $UPDATER_SUPERVISOR_IMAGE --supervisor-tag $UPDATER_SUPERVISOR_TAG
        if [ $? -ne 0 ]; then
            tryup
            log ERROR "Could not update supervisor to $UPDATER_SUPERVISOR_IMAGE:$UPDATER_SUPERVISOR_TAG ."
        fi
    fi
else
    log "Supervisor update not requested through arguments ."
fi

# That's it if we only wanted supervisor update
if [ "$ONLY_SUPERVISOR" == "yes" ]; then
    log "Update only of the supervisor requested."
    exit 0
fi

# Migrate docker images to docker engine 1.10 - HostOS version with this change is 1.1.5
log "Migrating to engine 1.10..."
if version_gt $HOSTOS_VERSION "1.1.5" || [ "$HOSTOS_VERSION" == "1.1.5" ]; then
    if [ "$DOCKER" == "rce" ]; then
        log "Running engine migrator 1.10... please wait..."
        DOCKER_MIGRATOR="registry.resinstaging.io/resinhup/$arch-v1.10-migrator"
        $DOCKER pull $DOCKER_MIGRATOR
        $DOCKER run --rm -v /var/lib/rce:/var/lib/docker $DOCKER_MIGRATOR -s btrfs
        if [ $? -eq 0 ]; then
            log "Migration to engine 1.10 done."
        else
            log ERROR "Migration to engine 1.10 failed."
        fi
    else
        log "No need to migrate to engine 1.10 as docker switch is already there"
    fi
else
    log "No need to migrate to engine 1.10 as you are not updating to a version >= 1.1.5."
fi

# Avoid supervisor cleaning up resinhup and stop containers
/usr/bin/resin-device-progress --percentage 50 --state "Resin Update: Preparing host OS update..."
log "Stopping all containers..."
systemctl stop resin-supervisor > /dev/null 2>&1
$DOCKER stop $($DOCKER ps -a -q) > /dev/null 2>&1
log "Removing all containers..."
$DOCKER rm $($DOCKER ps -a -q) > /dev/null 2>&1
/usr/bin/resin-device-progress --percentage 50 --state "Resin Update: Preparing host OS update..."

# Pull resinhup and tag it accordingly
log "Pulling resinhup..."
$DOCKER pull registry.resinstaging.io/resinhup/resinhup-$slug:$TAG
if [ $? -ne 0 ]; then
    tryup
    log ERROR "Could not pull registry.resinstaging.io/resinhup/resinhup-$slug:$TAG ."
fi

# Run resinhup
log "Running resinhup for version $HOSTOS_VERSION ..."
/usr/bin/resin-device-progress --percentage 75 --state "Resin Update: Running host OS update..."
RESINHUP_STARTTIME=$(date +%s)

# Setup -e arguments
RESINHUP_ENV=""
if [ "$FORCE" == "yes" ]; then
    RESINHUP_ENV="$RESINHUP_ENV -e RESINHUP_FORCE=yes"
fi
if [ "$STAGING" == "yes" ]; then
    RESINHUP_ENV="$RESINHUP_ENV -e RESINHUP_STAGING=yes"
fi
if [ -n "$REMOTE" ]; then
    RESINHUP_ENV="$RESINHUP_ENV -e REMOTE=$REMOTE"
fi
RESINHUP_ENV="$RESINHUP_ENV -e VERSION=$HOSTOS_VERSION"

$DOCKER run --privileged --rm --net=host $RESINHUP_ENV \
    --volume /:/host \
    --volume /lib/modules:/lib/modules:ro \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    registry.resinstaging.io/resinhup/resinhup-$slug:$TAG
RESINHUP_EXIT=$?
# RESINHUP_EXIT
#   0 - update done
#   2 - only intermediate step was done and will continue after reboot
#   3 - device already updated at a requested version or later
if [ $RESINHUP_EXIT -eq 0 ] || [ $RESINHUP_EXIT -eq 2 ] || [ $RESINHUP_EXIT -eq 3 ]; then
    RESINHUP_ENDTIME=$(date +%s)

    if [ $RESINHUP_EXIT -eq 0 ]; then
        /usr/bin/resin-device-progress --percentage 100 --state "Resin Update: Done. Rebooting device..."
        runPostHacks
    elif [ $RESINHUP_EXIT -eq 2 ]; then
        /usr/bin/resin-device-progress --percentage 100 --state "Resin Update: Intermediate step done. Rebooting device..."
    elif [ $RESINHUP_EXIT -eq 3 ]; then
        /usr/bin/resin-device-progress --percentage 100 --state "Resin Update: Device already at requested version..."
    fi
    log "Update suceeded in $(($RESINHUP_ENDTIME - $RESINHUP_STARTTIME)) seconds."

    # Everything is fine - Reboot
    if [ "$NOREBOOT" == "no" ]; then
        log "Rebooting board in 5 seconds..."
        nohup bash -c " /bin/sleep 5 ; /sbin/reboot " &
    else
        log "'No-reboot' requested."
    fi
else
    RESINHUP_ENDTIME=$(date +%s)
    # Don't tryup so support can have a chance to see what went wrong and how to recover
    log ERROR "Update failed after $(($RESINHUP_ENDTIME - $RESINHUP_STARTTIME)) seconds. Check the logs."
fi

# Success
exit $RESINHUP_EXIT
