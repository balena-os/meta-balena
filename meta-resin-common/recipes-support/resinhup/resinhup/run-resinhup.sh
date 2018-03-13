#!/bin/bash

# Default values
TAG=v1.2.1
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
SUPERVISOR_RELEASE_UPDATE=yes

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

  --no-supervisor-release-update
        By default the script updates the supervisor to the version that ships
        with the target host OS releases, if that is newer than the version run
        on the device. This tag switches this default update method, and no
        supervisor update is performed, unless a version tag is provided (see
        the previous option).

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

    # Earlier BeagleBone releases might fail to update due to memory pressure.
    # The fix for this was released in v1.24.0, for versions below that apply
    # changes manually
    if [ "$SLUG" == "beaglebone-black" ] ||
       [ "$SLUG" == "beaglebone-green" ] ||
       [ "$SLUG" == "beaglebone-green-wifi" ]; then
           if version_gt $CURRENT_HOSTOS_VERSION "1.24.0" || [ "$CURRENT_HOSTOS_VERSION" == "1.24.0" ]; then
               log "BeagleBone memory hack: no changes required."
           else
               log "BeagleBone memory hack: applying memory settings."
               sysctl -w vm.min_free_kbytes="8192" vm.dirty_ratio="5" vm.dirty_background_ratio="10"
           fi
    fi
}

function dockerCleanRepo {
    local repo=$1
    $DOCKER images --no-trunc | grep "${repo}" | awk '{ print $3 }' | uniq | xargs -t $DOCKER rmi -f  &> /dev/null 2>&1 || true
}

function runPostHacks {
    log "Cleanup docker images..."
    dockerCleanRepo "$RESINHUP_REGISTRY"
    dockerCleanRepo "registry.resinstaging.io/resin/resinos"
    dockerCleanRepo "resin/resinos"

    # This is just an optimization so next time docker starts it won't have to index everything
    # risking the systemd service to timeout.
    # Migrate docker images to docker engine 1.10 - HostOS version with this change is 1.1.5
    log "Migrating to engine 1.10..."
    if version_gt $HOSTOS_VERSION "1.1.5" || [ "$HOSTOS_VERSION" == "1.1.5" ]; then
        if [ "$DOCKER" == "rce" ]; then
            log "Running engine migrator 1.10... please wait..."
            DOCKER_MIGRATOR="registry.resinstaging.io/resinhup/$arch-v1.10-migrator"
            cachedpull "$DOCKER_MIGRATOR"
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

function getSupervisorVersionFromRelease() {
    # When updating, check if the target resinOS version has newer default supervisor
    # than what is running on the device at the moment. If there is, fill out the
    # UPDATER_SUPERVISOR_TAG parameter, plus some some helper parameters so not to
    # redo work in the next step (pulling the supervisor)

    if [ "$STAGING" == "yes" ]; then
        DEFAULT_SUPERVISOR_VERSION_URL_BASE="https://s3.amazonaws.com/resin-staging-img/"
    else
        DEFAULT_SUPERVISOR_VERSION_URL_BASE="https://s3.amazonaws.com/resin-production-img-cloudformation/"
    fi
    DEFAULT_SUPERVISOR_VERSION_URL="${DEFAULT_SUPERVISOR_VERSION_URL_BASE}images/${SLUG}/${HOSTOS_VERSION}/VERSION"

    # Get supervisor version for target resinOS release, it is in format of "a.b.c-shortsha", e.g. "4.1.2-f566dc4dd241",
    # and tag new version for the device if it's newer than the current version, from the API
    DEFAULT_SUPERVISOR_VERSION=$(curl -s "$DEFAULT_SUPERVISOR_VERSION_URL" | sed 's/-.*//')
    if [ -z "$DEFAULT_SUPERVISOR_VERSION" ] || [ -z "${DEFAULT_SUPERVISOR_VERSION##*xml*}" ]; then
        log ERROR "Could not get the default supervisor version for this resinOS release, bailing out."
    else
        CURRENT_SUPERVISOR_VERSION=$(curl -s "${API_ENDPOINT}/v2/device(${DEVICEID})?\$select=supervisor_version&apikey=${APIKEY}" | jq -r '.d[0].supervisor_version')
        if [ -z "$CURRENT_SUPERVISOR_VERSION" ]; then
            log ERROR "Could not get current supervisor version from the API, bailing out."
        else
            if version_gt "$DEFAULT_SUPERVISOR_VERSION" "$CURRENT_SUPERVISOR_VERSION" ; then
                log "Supervisor update: will be upgrading from v${CURRENT_SUPERVISOR_VERSION} to v${DEFAULT_SUPERVISOR_VERSION}"
                UPDATER_SUPERVISOR_TAG="v${DEFAULT_SUPERVISOR_VERSION}"
                # Get the supervisor id and image name
                if data=$(curl -s "${API_ENDPOINT}/v2/supervisor_release?\$select=id,image_name&\$filter=((device_type%20eq%20'$SLUG')%20and%20(supervisor_version%20eq%20'$UPDATER_SUPERVISOR_TAG'))&apikey=${APIKEY}" | jq -e -r '.d[0].id,.d[0].image_name'); then
                    read UPDATER_SUPERVISOR_ID UPDATER_SUPERVISOR_IMAGE_NAME <<<$data
                    log "Extracted supervisor vars: ID: $UPDATER_SUPERVISOR_ID; Image Name: $UPDATER_SUPERVISOR_IMAGE_NAME"
                fi
            else
                log "Supervisor update: no update needed."
            fi
        fi
    fi
}

function pullSupervisor() {
    # Pulling the supervisor, and preparing to update things later
    # This can work with either manually set supervisor tag, or automatically
    # set from the target resinOS update.
    # Just pull the image, if requested, through cache, and do the update steps
    # later when the rest of the update is successful.
    # One thing is always updated in this step: the supervisor.conf with the image name,
    # which includes the remote registry to call from. It should be the same for all 1.X
    # devices now regardless of version, so updating it all the time (and not atomically
    # as the update goes) should be correct under these assumptions.

    log "Supervisor update requested through arguments..."
    /usr/bin/resin-device-progress --percentage 25 --state "ResinOS: Preparing supervisor..."

    # When requesting default supervisor update, this variable would be already filled
    # out by the supervisor version check function. If empty, try to figure the image out.
    if [ -z "$UPDATER_SUPERVISOR_IMAGE_NAME" ]; then
        # Default UPDATER_SUPERVISOR_IMAGE to the one in supervisor.conf
        if [ -z "$SUPERVISOR_REGISTRY" ]; then
            UPDATER_SUPERVISOR_IMAGE=$SUPERVISOR_IMAGE
        else
            UPDATER_SUPERVISOR_IMAGE="$SUPERVISOR_REGISTRY/resin/$arch-supervisor"
        fi
    else
        UPDATER_SUPERVISOR_IMAGE=$UPDATER_SUPERVISOR_IMAGE_NAME
    fi

    log "Pulling supervisor $UPDATER_SUPERVISOR_IMAGE:$UPDATER_SUPERVISOR_TAG..."
    cachedpull "$UPDATER_SUPERVISOR_IMAGE:$UPDATER_SUPERVISOR_TAG"
}

function updateSupervisorConf() {
    # Update the supervisor config file with the new image and tag values.
    # If needed mount the new root filesystem as well.

    local _mountnewroot="$1"
    if [ "$_mountnewroot" == "yes" ]; then
        _newroot_mountpoint="/tmp/newroot"
        local _current_root_device
        local _new_root_number
        _current_root_device=$(findmnt -n --raw --evaluate --output=source /)
        case $_current_root_device in
            *2)
                _new_root_number=3
                ;;
            *3)
                _new_root_number=2
                ;;
            *)
                log ERROR "Current root partition ${_current_root_device} is not first or second root partition, aborting."
                ;;
        esac
        local _new_root_device="${_current_root_device%?}${_new_root_number}"
        log "Mounting new rootfs from ${_new_root_device} to ${_newroot_mountpoint}"
        mkdir -p ${_newroot_mountpoint}
        mount "${_new_root_device}" "${_newroot_mountpoint}"
        SUPERVISORCONFPATH="${_newroot_mountpoint}${SUPERVISORCONF}"
    else
        SUPERVISORCONFPATH="$SUPERVISORCONF"
    fi

    log "Updating ${SUPERVISORCONFPATH}"
    if grep -q "SUPERVISOR_IMAGE" "${SUPERVISORCONFPATH}"; then
        sed --in-place "s|SUPERVISOR_IMAGE=.*|SUPERVISOR_IMAGE=$UPDATER_SUPERVISOR_IMAGE|" "${SUPERVISORCONFPATH}"
    else
        echo "SUPERVISOR_IMAGE=$UPDATER_SUPERVISOR_IMAGE" >> ${SUPERVISORCONFPATH}
    fi
    if grep -q "SUPERVISOR_TAG" "${SUPERVISORCONF}"; then
        sed --in-place "s|SUPERVISOR_TAG=.*|SUPERVISOR_TAG=$UPDATER_SUPERVISOR_TAG|" "${SUPERVISORCONFPATH}"
    else
        echo "SUPERVISOR_TAG=$UPDATER_SUPERVISOR_TAG" >> ${SUPERVISORCONFPATH}
    fi

    if [ "$_mountnewroot" == "yes" ]; then
        log "Unmounting ${_newroot_mountpoint}"
        umount ${_newroot_mountpoint} &> /dev/null
    fi
}

# Actually updating the supervisor by tagging the new version as "latest" and updating the API
function updateSupervisor() {
    log "Updating supervisor tag..."
    $DOCKER tag -f "$UPDATER_SUPERVISOR_IMAGE:$UPDATER_SUPERVISOR_TAG" "$UPDATER_SUPERVISOR_IMAGE:latest"

    log "Setting supervisor version in the API"
    if [ -z "$UPDATER_SUPERVISOR_ID" ]; then
        UPDATER_SUPERVISOR_ID=$(curl -s "${API_ENDPOINT}/v2/supervisor_release?\$select=id,image_name&\$filter=((device_type%20eq%20'$SLUG')%20and%20(supervisor_version%20eq%20'$UPDATER_SUPERVISOR_TAG'))&apikey=${APIKEY}" | jq -e -r '.d[0].id')
    fi
    curl -s "${API_ENDPOINT}/v2/device($DEVICEID)?apikey=$APIKEY" -X PATCH -H 'Content-Type: application/json;charset=UTF-8' --data-binary "{\"supervisor_release\": \"$UPDATER_SUPERVISOR_ID\"}" > /dev/null 2>&1
}

#
# MAIN
#

# Log timer
STARTTIME=$(date +%s)

# Parse arguments
while [[ $# -gt 0 ]]; do
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
            SUPERVISOR_RELEASE_UPDATE=no
            shift
            ;;
        --no-supervisor-release-update)
            SUPERVISOR_RELEASE_UPDATE=no
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
setCurrentVersion
if [ -z "$CURRENT_HOSTOS_VERSION" ]; then
	log ERROR "Can't determine current host OS version."
fi

/usr/bin/resin-device-progress --percentage 10 --state "ResinOS: Preparing update..."

# Check that HostOS version was provided, and not only supervisor update was requested
if [ -z "$HOSTOS_VERSION" -a -z "$ONLY_SUPERVISOR" ]; then
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
API_ENDPOINT=$(jq -r .apiEndpoint $CONFIGJSON)

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
SUPERVISORCONF="/etc/supervisor.conf"
source "${SUPERVISORCONF}"
arch=`echo "$SUPERVISOR_IMAGE" | sed -n "s/.*\/\([a-zA-Z0-9]*\)-.*/\1/p"`
if [ -z "$arch" ]; then
    log ERROR "Can't detect arch from ${SUPERVISORCONF} ."
else
    log "Detected arch: $arch ."
fi

# We need to stop update-resin-supervisor.timer otherwise it might restart supervisor which
# will delete downloaded layers. Same for cron jobs.
log "Stopping timers and cronjobs"
systemctl stop update-resin-supervisor.timer > /dev/null 2>&1
/etc/init.d/crond stop > /dev/null 2>&1 # We might have cron jobs which restart supervisor

# Avoid supervisor cleaning up resinhup and stop containers
log "Stopping all containers..."
systemctl stop resin-supervisor > /dev/null 2>&1
$DOCKER stop $($DOCKER ps -a -q) > /dev/null 2>&1
log "Removing all containers..."
$DOCKER rm $($DOCKER ps -a -q) > /dev/null 2>&1

# Supervisor update
if [ "$SUPERVISOR_RELEASE_UPDATE" == "yes" ]; then
    getSupervisorVersionFromRelease
fi
if [ ! -z "$UPDATER_SUPERVISOR_TAG" ]; then
    pullSupervisor
else
    log "Supervisor update not requested through arguments ."
fi

# If we only wanted supervisor update, then this is the end of the resinhup process.
# Since the supervisor at this stage should be down, start it back up again
# and that will also clear the progress bar so do not have to do that explicitly.
if [ "$ONLY_SUPERVISOR" == "yes" ]; then
    updateSupervisorConf
    updateSupervisor
    /usr/bin/resin-device-progress --percentage 100 --state "ResinOS: update finished. Restarting supervisor..."
    log "Update of only the supervisor was requested."
    log "Starting processes back up."
    tryup
    exit 0
fi

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
$DOCKER rm -f resinhup &> /dev/null
$DOCKER rm -f resinos &> /dev/null

# RESINHUP_EXIT
#   0 - update succeeded
#   1 - update failed
#   2 - only intermediate step was done and will continue after reboot
#   3 - device already updated at a requested version or later
if [ $RESINHUP_EXIT -eq 0 ] || [ $RESINHUP_EXIT -eq 2 ] || [ $RESINHUP_EXIT -eq 3 ]; then
    RESINHUP_ENDTIME=$(date +%s)

    if [ $RESINHUP_EXIT -eq 0 ]; then
        /usr/bin/resin-device-progress --percentage 90 --state "ResinOS: Finalizing update..."
        # If this tag is set and we get to this point, then we had a supervisor update done
        if [ -n "$UPDATER_SUPERVISOR_TAG" ]; then
            updateSupervisorConf "yes"
            updateSupervisor
        fi
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
