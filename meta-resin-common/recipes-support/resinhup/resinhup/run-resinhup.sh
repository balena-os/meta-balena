#!/bin/bash

# Default values
TAG=v1.1.3
FORCE=no
ALLOW_DOWNGRADES=no
STAGING=no
LOG=yes
ONLY_SUPERVISOR=no
NOREBOOT=no
CACHE=no
MAXRETRIES=5
SCRIPTNAME=run-resinhup.sh
DEFAULT_CURRENT_HOSTOS_VERSION=1.0.0

# Don't run anything before this source as it sets PATH here
source /etc/profile

# Help function
function help {
    cat << EOF
Wrapper to run host OS updates on resin distributions.
$SCRIPTNAME <OPTION>

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
        Default: $TAG

  --remote <REMOTE>
        Run the updater with this remote configuration.
        This argument will be passed to resinhup and will be used as the location from
        which the update bundles will be downloaded.

  --hostos-version <HOSTOS_VERSION>
        Run the updater for this specific HostOS version.
        Omit the 'v' in front of the version. e.g.: 1.2.3 and not v1.2.3.
        This is a mandatory argument.

  --supervisor-registry <SUPERVISOR REGISTRY>
        Update supervisor getting the image from this registry.

  --supervisor-tag <SUPERVISOR TAG>
        Before updating ResinOS, update Supervisor using this tag.
        Don't omit the 'v' in front of the version. e.g.: v1.2.3 and not 1.2.3.

  --only-supervisor
        Update only the supervisor.

  -n, --nolog
        By default tool logs to stdout and file. This flag deactivates log to file.

  --no-reboot
        Don't reboot if update is successful. This is useful when debugging.

  --max-retries
        Some commands will be tried a couple of times before failing the update.
        e.g. docker pulls
        By default: $MAXRETRIES retries.

  --cache
        Try to find cached images. If found, don't pull new ones but load the
        ones already there. To be used ONLY in development or demos.

  --allow-downgrades
        Allow updating to the same version or to an older one.
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
    /usr/bin/resin-device-progress --percentage 100 --state "ResinOS: Update failed."
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
    if [ "z$LOG" == "zyes" ] && [ -n "$LOGFILE" ]; then
        printf "[%09d%s%s\n" "$(($ENDTIME - $STARTTIME))" "][$loglevel]" "$1" | tee -a $LOGFILE
    else
        printf "[%09d%s%s\n" "$(($ENDTIME - $STARTTIME))" "][$loglevel]" "$1"
    fi
    if [ "$loglevel" == "ERROR" ]; then
        /usr/bin/resin-device-progress --percentage 100 --state "ResinOS: Update failed."
        exit 1
    fi
}

function retrycommand {
    local _command="$1"
    local _try=0
    local _max=$MAXRETRIES
    local _timeoutfactor=30
    local _timeout
    until [ $_try -ge $_max ]; do
        $_command && break
        _try=$(($_try+1))
        _timeout=$(($_timeoutfactor * ($RANDOM%$_max + 1)))
        log WARN "Retrying [$_try/$_max] in $_timeout seconds."
        sleep $_timeout
    done

    if [ $_try -ge $_max ]; then
        tryup
        log ERROR "Failed after $_max attempts!"
        exit 1
    fi
}

function runPreHacks {
    local _boot_mountpoint

    if which blkid &> /dev/null; then
        _boot_mountpoint="$(grep $(blkid | grep resin-boot | cut -d ":" -f 1) /proc/mounts | cut -d ' ' -f 2)"
    else
        log WARN "Can't rely on blkid to detect boot partition mountpoint. Fallback to version based detection..."
        if version_gt $CURRENT_HOSTOS_VERSION "1.12.0" || [ "$CURRENT_HOSTOS_VERSION" == "1.12.0" ]; then
            # Boot partition is mounted in /mnt/boot
            _boot_mountpoint=/mnt/boot
        else
            # Boot partition is mounted in /boot
            _boot_mountpoint=/boot
        fi
    fi

    # We might need to repartition boot partition so make sure it is unmounted
    log "Make sure resin-boot is unmounted..."
    if [ -z $_boot_mountpoint ]; then
        log WARN "Mount point for resin-boot partition could not be found. It is probably already unmounted."
    else
        log "Boot partition detected in $_boot_mountpoint ."
    fi
    # FIXME: support old devices
    if [ "$_boot_mountpoint" = "/boot" ]; then
        umount $_boot_mountpoint &> /dev/null
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
    log "Cleanup docker images..."
    $DOCKER rmi -f $RESINHUP_REGISTRY:$TAG-$SLUG  &> /dev/null
    $DOCKER rmi -f registry.resinstaging.io/resin/resinos:$HOSTOS_VERSION-$SLUG &> /dev/null
    $DOCKER rmi -f resin/resinos:$HOSTOS_VERSION-$SLUG &> /dev/null

    # This is just an optimization so next time docker starts it won't have to index everything
    # risking the systemd service to timeout.
    # Migrate docker images to docker engine 1.10 - HostOS version with this change is 1.1.5
    log "Migrating to engine 1.10..."
    if version_gt $HOSTOS_VERSION "1.1.5" || [ "$HOSTOS_VERSION" == "1.1.5" ]; then
        if [ "$DOCKER" == "rce" ]; then
            log "Running engine migrator 1.10... please wait..."
            DOCKER_MIGRATOR="registry.resinstaging.io/resinhup/$arch-v1.10-migrator"
            retrycommand "$DOCKER pull $DOCKER_MIGRATOR"
            $DOCKER run --rm -v /var/lib/rce:/var/lib/docker $DOCKER_MIGRATOR -s btrfs
            if [ $? -eq 0 ]; then
                log "Migration to engine 1.10 done."
            else
                log ERROR "Migration to engine 1.10 failed."
            fi
            $DOCKER rmi -f $DOCKER_MIGRATOR
        else
            log "No need to migrate to engine 1.10 as docker switch is already there"
        fi
    else
        log "No need to migrate to engine 1.10 as you are not updating to a version >= 1.1.5."
    fi

    # Switch from rce to docker - HostOS version with this change is 1.1.5
    log "Docker hack: Make switch from rce to docker backwards compatible"
    if version_gt $HOSTOS_VERSION "1.1.5" || [ "$HOSTOS_VERSION" == "1.1.5" ]; then
        if [ "$DOCKER" == "rce" ]; then
            # Stop rce first in all the ways possible :)
            systemctl stop rce &> /dev/null
            killall rce &> /dev/null
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

function cachedpull() {
    local _image="$1"
    local _image_escaped=$(echo "$_image" | sed -r "s/[\/\.:-]/_/g")

    if [ "$CACHE" == "yes" ]; then
        if [ "$($DOCKER images -q ${_image})" == "" ]; then
            if [ -f $BTRFS_MOUNTPOINT/resinhup/cache/${_image_escaped}.tar.gz ]; then
                log "Found cached image [${_image}]. Loading it..."
                $DOCKER load < $BTRFS_MOUNTPOINT/resinhup/cache/${_image_escaped}.tar.gz
            else
                log "Did not find cached image [${_image}]. Pulling..."
                retrycommand "$DOCKER pull ${_image}"
                log "Caching image..."
                mkdir -p $BTRFS_MOUNTPOINT/resinhup/cache
                $DOCKER save ${_image} | gzip > $BTRFS_MOUNTPOINT/resinhup/cache/${_image_escaped}.tar.gz
            fi
        else
            log "Image already pulled [${_image}]. No need to use any cache or pull."
        fi
    else
        log "Pulling ${_image}..."
        retrycommand "$DOCKER pull ${_image}"
    fi
}

function setCurrentVersion() {
	local _version_file=/etc/os-release
	if [ ! -f "$_version_file" ]; then
		CURRENT_HOSTOS_VERSION=$DEFAULT_CURRENT_HOSTOS_VERSION
		return
	fi
	CURRENT_HOSTOS_VERSION=$(cat "$_version_file" | grep VERSION= | cut -d= -f2 | tr -d '"' | head -n1)
	if [[ ! $CURRENT_HOSTOS_VERSION =~ ^([0-9]+\.)([0-9]+\.)([0-9]+)(\-[a-zA-Z0-9]+)?(\+rev[0-9]+)?$ ]]; then
		CURRENT_HOSTOS_VERSION=$DEFAULT_CURRENT_HOSTOS_VERSION
		return
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
        --max-retries)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            MAXRETRIES=$2
            shift
            ;;
        --cache)
            CACHE=yes
            ;;
        --allow-downgrades)
            ALLOW_DOWNGRADES=yes
            ;;
        *)
            log ERROR "Unrecognized option $1."
            ;;
    esac
    shift
done

# Detect BTRFS_MOUNTPOINT
if [ -d /mnt/data ]; then
    BTRFS_MOUNTPOINT=/mnt/data
elif [ -d /mnt/data-disk ]; then
    BTRFS_MOUNTPOINT=/mnt/data-disk
else
    log ERROR "Can't find the resin-data mountpoint."
fi

# Init log file
# LOGFILE init and header
LOGFILE=$BTRFS_MOUNTPOINT/resinhup/$SCRIPTNAME.log
mkdir -p $(dirname $LOGFILE)
if [ "$LOG" == "yes" ]; then
    echo "================$SCRIPTNAME HEADER START====================" > $LOGFILE
    date >> $LOGFILE
    echo "Force mode: $FORCE" >> $LOGFILE
    echo "Resinhup tag: $TAG" >> $LOGFILE
    echo "Allow downgrades: $ALLOW_DOWNGRADES" >> $LOGFILE
fi

# Determine current host OS version
setCurrentVersion()
if [ -z "$CURRENT_HOSTOS_VERSION" ]; then
	log ERROR "Can't determine current host OS version."
fi

/usr/bin/resin-device-progress --percentage 10 --state "ResinOS: Preparing update..."

# Check that HostOS version was provided
if [ -z "$HOSTOS_VERSION" ]; then
    log ERROR "--hostos-version is required."
fi

# Init log file
# LOGFILE init and header
if [ "$LOG" == "yes" ]; then
    echo "================$SCRIPTNAME HEADER START====================" > $LOGFILE
    date >> $LOGFILE
    echo "Force mode: $FORCE" >> $LOGFILE
    echo "Resinhup tag: $TAG" >> $LOGFILE
    echo "Allow downgrades: $ALLOW_DOWNGRADES" >> $LOGFILE
fi

# Get the slug
if [ -f /mnt/boot/config.json ]; then
    CONFIGJSON=/mnt/boot/config.json
elif [ -f /mnt/conf/config.json ]; then
    CONFIGJSON=/mnt/conf/config.json
elif [ -f /mnt/data-disk/config.json ]; then
    CONFIGJSON=/mnt/data-disk/config.json
else
    log ERROR "Don't know where config.json is."
fi
SLUG=$(jq -r .deviceType $CONFIGJSON)
APIKEY=$(jq -r .apiKey $CONFIGJSON)
DEVICEID=$(jq -r .deviceId $CONFIGJSON)

if [ -z $SLUG ]; then
    log ERROR "Could not get the SLUG."
fi
log "Found slug $SLUG for this device."

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
    /usr/bin/resin-device-progress --percentage 25 --state "ResinOS: Updating supervisor..."

    # Before doing anything make sure the API has the version we want to update to
    # Otherwise we risk that next time update-resin-supervisor script gets called,
    # the supervisor version will change back to the old one
    supervisor_id=`curl -s "https://api.resin.io/v2/supervisor_release?apikey=$APIKEY" | jq -r ".d[] | select(.supervisor_version == \"$UPDATER_SUPERVISOR_TAG\" and .device_type == \"$SLUG\") | .id // empty"`
    if [ -z "$supervisor_id" ]; then
        log ERROR "Could not get the supervisor version id ($UPDATER_SUPERVISOR_TAG) from the API ."
    fi
    curl -s "https://api.resin.io/v2/device($DEVICEID)?apikey=$APIKEY" -X PATCH -H 'Content-Type: application/json;charset=UTF-8' --data-binary "{\"supervisor_release\": \"$supervisor_id\"}" > /dev/null 2>&1

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
        retrycommand "$DOCKER pull $UPDATER_SUPERVISOR_IMAGE:$UPDATER_SUPERVISOR_TAG"
        $DOCKER tag -f "$UPDATER_SUPERVISOR_IMAGE:$UPDATER_SUPERVISOR_TAG" "$UPDATER_SUPERVISOR_IMAGE:latest"
    else
        # Supervisor update on systemd based OS
        retrycommand "/usr/bin/update-resin-supervisor --supervisor-image $UPDATER_SUPERVISOR_IMAGE --supervisor-tag $UPDATER_SUPERVISOR_TAG"

        # Remove the old supervisor
        systemctl stop resin-supervisor > /dev/null 2>&1
        for image_id in $($DOCKER images | grep supervisor | grep -v latest | grep -v "$UPDATER_SUPERVISOR_TAG" | awk '{print $3}' | sort -u); do
            log "Removing old supervisor image with ID $image_id..."
            $DOCKER rmi -f $image_id
        done
    fi
else
    log "Supervisor update not requested through arguments ."
fi

# That's it if we only wanted supervisor update
if [ "$ONLY_SUPERVISOR" == "yes" ]; then
    log "Update only of the supervisor requested."
    exit 0
fi

# Avoid supervisor cleaning up resinhup and stop containers
/usr/bin/resin-device-progress --percentage 50 --state "ResinOS: Preparing update..."
log "Stopping all containers..."
systemctl stop resin-supervisor > /dev/null 2>&1
$DOCKER stop $($DOCKER ps -a -q) > /dev/null 2>&1
log "Removing all containers..."
$DOCKER rm $($DOCKER ps -a -q) > /dev/null 2>&1
/usr/bin/resin-device-progress --percentage 50 --state "ResinOS: Preparing update..."

# Pull resinhup - rce can only pull from v1 (resin staging registry)
if [ "$DOCKER" == "rce" ]; then
    RESINHUP_REGISTRY="registry.resinstaging.io/resin/resinhup"
    RESINOS_REGISTRY="registry.resinstaging.io/resin/resinos"
else
    RESINHUP_REGISTRY="resin/resinhup-test"
    RESINOS_REGISTRY="resin/resinos"
fi
cachedpull "$RESINHUP_REGISTRY:$TAG-$SLUG"

# Cache resinos image too
if [ "$CACHE" = "yes" ]; then
    cachedpull "$RESINOS_REGISTRY:$HOSTOS_VERSION-$SLUG"
fi

# Run resinhup
log "Running resinhup for version $HOSTOS_VERSION ..."
/usr/bin/resin-device-progress --percentage 70 --state "ResinOS: Running updater..."
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
if [ "$ALLOW_DOWNGRADES" == "yes" ]; then
    RESINHUP_ENV="$RESINHUP_ENV -e ALLOW_DOWNGRADES=yes"
fi
RESINHUP_ENV="$RESINHUP_ENV -e VERSION=$HOSTOS_VERSION"

$DOCKER rm -f resinhup > /dev/null 2>&1
$DOCKER run --privileged --name resinhup --net=host $RESINHUP_ENV \
    --volume /:/host \
    --volume /lib/modules:/lib/modules:ro \
    --volume /var/run/$DOCKER.sock:/var/run/$DOCKER.sock \
    $RESINHUP_REGISTRY:$TAG-$SLUG
RESINHUP_EXIT=$?

# Save logs
$DOCKER logs resinhup >> $LOGFILE 2>&1
$DOCKER rm -f resinhup > /dev/null 2>&1

# RESINHUP_EXIT
#   0 - update succeeded
#   1 - update failed
#   2 - only intermediate step was done and will continue after reboot
#   3 - device already updated at a requested version or later
if [ $RESINHUP_EXIT -eq 0 ] || [ $RESINHUP_EXIT -eq 2 ] || [ $RESINHUP_EXIT -eq 3 ]; then
    RESINHUP_ENDTIME=$(date +%s)

    if [ $RESINHUP_EXIT -eq 0 ]; then
        /usr/bin/resin-device-progress --percentage 90 --state "ResinOS: Finalizing update..."
        runPostHacks
        /usr/bin/resin-device-progress --percentage 100 --state "ResinOS: Done. Rebooting..."
    elif [ $RESINHUP_EXIT -eq 2 ]; then
        /usr/bin/resin-device-progress --percentage 100 --state "ResinOS: Intermediate step done. Rebooting device..."
    elif [ $RESINHUP_EXIT -eq 3 ]; then
        /usr/bin/resin-device-progress --percentage 100 --state "ResinOS: Already updated. Rebooting device..."
    fi
    log "Update suceeded in $(($RESINHUP_ENDTIME - $RESINHUP_STARTTIME)) seconds."
    RESINHUP_EXIT=0

    # Everything is fine - Reboot
    if [ "$NOREBOOT" == "no" ]; then
        log "Rebooting board in 5 seconds..."
        nohup bash -c " /bin/sleep 5 ; /sbin/reboot " > /dev/null 2>&1 &
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
