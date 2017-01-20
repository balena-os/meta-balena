#!/bin/bash

RESINHUP_ARGS=""
UUIDS=""
SSH_HOST=""
USER_APP=""
NOCOLORS=no
FAILED=0

NUM=0
QUEUE=""
MAX_THREADS=5

# Help function
function help {
    cat << EOF
Wrapper to run host OS updates on fleet of devices over ssh.
$0 <OPTION>

Options:
  -h, --help
        Display this help and exit.

  -f, --force
        Run the resinhup tool withut fingerprints check and validation.

  --staging
        Do this update for devices in staging.
        By default resinhup assumes the devices are in production.

  -u <UUID>, --uuid <UUID>
        Update this UUID. Multiple -u can be provided to updated mutiple devices.

  -s <SSH_HOST>, --ssh-host <SSH_HOST>
        SSH host to be used in ssh connections and other places. Please have them called
        resin/resinstaging because this flag is used in API URL too.

  -a <USER_APP>, --app <USER_APP>
        Update all the devices in this app. The argument needs to be in the format
        user:appname in order to make sure we update the application of a specific user.

  -m <MAX_THREADS>, --max-threads <MAX_THREADS>
        Maximum number of threads to be used when updating devices in parallel. Useful to
        not network bash network if devices are in the same one. If value is 0, all
        updates will start in parallel.

  --remote <REMOTE>
        Run run-resinhup.sh with --remote . See run-resinhup.sh help for more details.

  --hostos-version <HOSTOS_VERSION>
        Run run-resinhup.sh with --version .  See run-resinhup.sh help for more details.
        This is a mandatory argument.

  --supervisor-registry <SUPERVISOR REGISTRY>
        Run run-resinhup.sh with ----supervisor-registry . See run-resinhup.sh help for
        more details.

  --supervisor-tag <SUPERVISOR TAG>
        Run run-resinhup.sh with this --supervisor-tag argument. See run-resinhup.sh
        help for more details.

  --only-supervisor
        Update only the supervisor.

  --no-reboot
        Run run-resinhup.sh with --no-reboot . See run-resinhup.sh help for more details.

  --resinhup-tag
        Run run-resinhup.sh with --tag . See run-resinhup.sh help for more details.

  --max-retries
        Run run-resinhup.sh with --max-retries . See run-resinhup.sh help for more details.

  --no-colors
        Avoid terminal colors. Activated by default.

  --cache
        Run run-resinhup.sh with --cache . See run-resinhup.sh help for more details.

  --allow-downgrades
        Run run-resinhup.sh with --allow-downgrades . See run-resinhup.sh help for more details.
EOF
}

# Log function helper
function log {
    local COL
    local COLEND='\e[0m'
    local loglevel=LOG

    case $1 in
        ERROR)
            COL='\e[31m'
            loglevel=ERR
            shift
            ;;
        WARN)
            COL='\e[33m'
            loglevel=WRN
            shift
            ;;
        SUCCESS)
            COL='\e[32m'
            loglevel=LOG
            shift
            ;;
        *)
            COL=$COLEND
            loglevel=LOG
            ;;
    esac

    if [ "$NOCOLORS" == "yes" ]; then
        COLEND=''
        COL=''
    fi

    ENDTIME=$(date +%s)
    printf "${COL}[%09d%s%s${COLEND}\n" "$(($ENDTIME - $STARTTIME))" "][$loglevel]" "$1"
    if [ "$loglevel" == "ERR" ]; then
        exit 1
    fi
}

cleanstop() {
    log WARN "Force close requested. Waiting for already started updates... Please wait!"
    while [ -n "$QUEUE" ]; do
        checkqueue
        sleep 0.5
    done
    wait
    log ERROR "Forced stop."
    exit 1
}
trap 'cleanstop' SIGINT SIGTERM

function addtoqueue {
    NUM=$(($NUM+1))
    QUEUE="$QUEUE $1"
}

function regeneratequeue {
    OLDREQUEUE=$QUEUE
    QUEUE=""
    NUM=0
    for entry in $OLDREQUEUE; do
        PID=$(echo $entry | cut -d: -f1)
        if [ -d /proc/$PID  ] ; then
            QUEUE="$QUEUE $entry"
            NUM=$(($NUM+1))
        fi
    done
}

function checkqueue {
    OLDCHQUEUE=$QUEUE
    for entry in $OLDCHQUEUE; do
        local _PID=$(echo $entry | cut -d: -f1)
        if [ ! -d /proc/$_PID ] ; then
            wait $_PID
            local _exitcode=$?
            local _UUID=$(echo $entry | cut -d: -f2)
            if [ "$_exitcode" != "0" ]; then
                log WARN "Updating $_UUID failed."
                FAILED=1
            else
                log SUCCESS "Updating $_UUID succeeded."
            fi
            regeneratequeue
            break
        fi
    done
}

#
# MAIN
#

# Get the absolute script location
pushd `dirname $0` > /dev/null 2>&1
SCRIPTPATH=`pwd`
popd > /dev/null 2>&1

# Tools we need on device
UPDATE_TOOLS="\
$SCRIPTPATH/../../meta-resin-common/recipes-support/resinhup/resinhup/run-resinhup.sh \
$SCRIPTPATH/../../meta-resin-common/recipes-containers/docker-disk/docker-resin-supervisor-disk/update-resin-supervisor \
$SCRIPTPATH/../../meta-resin-common/recipes-support/resin-device-progress/resin-device-progress/resin-device-progress \
"

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
            RESINHUP_ARGS="$RESINHUP_ARGS --force"
            ;;
        --staging)
            RESINHUP_ARGS="$RESINHUP_ARGS --staging"
            ;;
        -u|--uuid)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            UUIDS="$UUIDS $2"
            shift
            ;;
        -s|--sshhost)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            SSH_HOST=$2
            shift
            ;;
        -a|--app)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            USER_APP=$2
            shift
            ;;
        -m|--max-threads)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            MAX_THREADS=$2
            shift
            ;;
        --remote)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            REMOTE=$2
            RESINHUP_ARGS="$RESINHUP_ARGS --remote $REMOTE"
            shift
            ;;
        --hostos-version)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            HOSTOS_VERSION=$2
            RESINHUP_ARGS="$RESINHUP_ARGS --hostos-version $HOSTOS_VERSION"
            shift
            ;;
        --supervisor-registry)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            SUPERVISOR_REGISTRY=$2
            RESINHUP_ARGS="$RESINHUP_ARGS --supervisor-registry $SUPERVISOR_REGISTRY"
            shift
            ;;
        --supervisor-tag)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            SUPERVISOR_TAG=$2
            RESINHUP_ARGS="$RESINHUP_ARGS --supervisor-tag $SUPERVISOR_TAG"
            shift
            ;;
        --resinhup-tag)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            RESINHUP_TAG=$2
            RESINHUP_ARGS="$RESINHUP_ARGS --tag $RESINHUP_TAG"
            shift
            ;;
        --only-supervisor)
            RESINHUP_ARGS="$RESINHUP_ARGS --only-supervisor"
            ;;
        --no-reboot)
            RESINHUP_ARGS="$RESINHUP_ARGS --no-reboot"
            ;;
        --max-retries)
            if [ -z "$2" ]; then
                log ERROR "\"$1\" argument needs a value."
            fi
            MAXRETRIES=$2
            RESINHUP_ARGS="$RESINHUP_ARGS --max-retries $MAXRETRIES"
            shift
            ;;
        --no-colors)
            NOCOLORS=yes
            ;;
        --cache)
            RESINHUP_ARGS="$RESINHUP_ARGS --cache"
            ;;
        --allow-downgrades)
            RESINHUP_ARGS="$RESINHUP_ARGS --allow-downgrades"
            ;;
        *)
            log ERROR "Unrecognized option $1."
            ;;
    esac
    shift
done

# Add the uuids from the appuuids file to UUID
if [ -n "$USER_APP" ]; then
    RESIN_USER=$(echo "$USER_APP" | cut -d: -f1)
    RESIN_APP=$(echo "$USER_APP" | cut -d: -f2)
    if [ -z "$RESIN_USER" ] || [ -z "$RESIN_APP" ]; then
        log ERROR "Wrong app argument provided: $USER_APP. Check help."
    fi
    if [ -f $SSH_HOST.jwt ]; then
        JWT=$(cat $SSH_HOST.jwt)
        NEW_UUIDS=$(curl -s -H "Authorization: Bearer $JWT" "https://api.$SSH_HOST.io/ewa/device?\$expand=application,user&\$filter=application/app_name%20eq%20'$RESIN_APP'%20and%20application/user/username%20eq%20'$RESIN_USER'" | jq -r '.d[].uuid')
        if [ $? -ne 0 ] || [ -z "$NEW_UUIDS" ]; then
            log ERROR "Failed to query for app $RESIN_APP of user $RESIN_USER on $SSH_HOST"
        fi
        UUIDS="$UUIDS $NEW_UUIDS"
    else
        log ERROR "$SSH_HOST.jwt must contain your Auth Token"
    fi
fi

# Check argument(s)
if [ -z "$UUIDS" ] || [ -z "$SSH_HOST" ]; then
    log ERROR "No UUID and/or SSH_HOST specified."
fi

CURRENT_UPDATE=0
NR_UPDATES=$(echo "$UUIDS" | wc -w)

# 0 threads means Parallelise everything
if [ $MAX_THREADS -eq 0 ]; then
    MAX_THREADS=$NR_UPDATES
fi

# Update each UUID
for uuid in $UUIDS; do
    CURRENT_UPDATE=$(($CURRENT_UPDATE+1))

    log "[$CURRENT_UPDATE/$NR_UPDATES] Updating $uuid on $SSH_HOST."

    # Check SSH/VPN connection
    ssh $SSH_HOST -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o Hostname=$uuid.vpn exit > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        log WARN "[$CURRENT_UPDATE/$NR_UPDATES] Can't connect to device. Skipping..."
        continue
    fi

    # Transfer the scripts
    # TODO transfer files only if device doesn't provide run-resinhup.sh
    scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o Hostname=$uuid.vpn $UPDATE_TOOLS $SSH_HOST:/usr/bin > $uuid.resinhup.log 2>&1
    if [ $? -ne 0 ]; then
        log WARN "[$CURRENT_UPDATE/$NR_UPDATES] Could not scp needed tools to device. Skipping..."
        continue
    fi

    # Connect to device
    ssh $SSH_HOST -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o Hostname=$uuid.vpn /usr/bin/run-resinhup.sh $RESINHUP_ARGS >> $uuid.resinhup.log 2>&1 &

    # Manage queue of threads
    PID=$!
    addtoqueue $PID:$uuid
    while [ $NUM -ge $MAX_THREADS ]; do
        checkqueue
        sleep 0.5
    done
done

# Wait for all threads
log "Waiting for all threads to finish..."
while [ -n "$QUEUE" ]; do
    checkqueue
    sleep 0.5
done
wait

if [ $FAILED -eq 1 ]; then
    log ERROR "At least one device failed to update."
fi

# Success
exit 0
