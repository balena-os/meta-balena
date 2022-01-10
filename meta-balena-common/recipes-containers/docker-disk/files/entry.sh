#!/bin/sh

set -o errexit
set -o nounset

DOCKER_TIMEOUT=20 # Wait 20 seconds for docker to start
DATA_VOLUME=/resin-data
BUILD=/build
PARTITION_SIZE=${PARTITION_SIZE:-1024}
DOCKER_HOST=unix:///var/run/docker.sock

finish() {
	# Make all files owned by the build system
	chown -R "$USER_ID:$USER_GID" "${BUILD}"
}
trap finish EXIT

. /balena-apps.inc

# Create user
echo "[INFO] Creating and setting $USER_ID:$USER_GID."
groupadd -g "$USER_GID" docker-disk-group || true
useradd -u "$USER_ID" -g "$USER_GID" -p "" docker-disk-user || true

mkdir -p $DATA_VOLUME/docker
mkdir -p $DATA_VOLUME/resin-data

touch $DATA_VOLUME/remove_me_to_reset

# Start docker
echo "Starting docker daemon with $BALENA_STORAGE storage driver."
dockerd -H "$DOCKER_HOST" --data-root="$DATA_VOLUME/docker" -s "$BALENA_STORAGE" -b none --experimental &
echo "Waiting for docker to become ready.."
STARTTIME="$(date +%s)"
ENDTIME="$STARTTIME"
while [ ! -S /var/run/docker.sock ]
do
    if [ $((ENDTIME - STARTTIME)) -le $DOCKER_TIMEOUT ]; then
        sleep 1 && ENDTIME=$((ENDTIME + 1))
    else
        echo "Timeout while waiting for docker to come up."
        exit 1
    fi
done
echo "Docker started."

# Pull in arch specific hello-world image and tag it balena-healthcheck-image
echo "Pulling ${HELLO_REPOSITORY}:latest..."
docker pull --platform "${HOSTAPP_PLATFORM}" "${HELLO_REPOSITORY}"
docker tag "${HELLO_REPOSITORY}" balena-healthcheck-image
docker rmi "${HELLO_REPOSITORY}"
docker save balena-healthcheck-image > ${BUILD}/balena-healthcheck-image.tar

# Pull in the supervisor image as a separate app until it converges in the hostOS
if [ -n "${SUPERVISOR_FLEET}" ] && [ -n "${SUPERVISOR_VERSION}" ]; then
	_supervisor_image=$(balena_api_fetch_image_from_app "${SUPERVISOR_FLEET}" "${SUPERVISOR_VERSION#v}" "${BALENA_API_ENV}" "${BALENA_API_TOKEN}")
	echo "Pulling ${SUPERVISOR_FLEET}:${SUPERVISOR_VERSION}"
	if docker pull "${_supervisor_image}"; then
		docker tag "${_supervisor_image}" "${_supervisor_image%@*}"
		docker tag "${_supervisor_image}" "balena_supervisor":"${SUPERVISOR_VERSION}"
	else
		echo "Not able to pull ${_supervisor_image}"
		exit 1
	fi
fi

echo "Stopping docker..."
kill -TERM "$(cat /var/run/docker.pid)"
# don't let wait() error out and crash the build if the docker daemon has already been stopped
wait "$(cat /var/run/docker.pid)" || true

# Export the final data filesystem
dd if=/dev/zero of=${BUILD}/resin-data.img bs=1M count=0 seek="${PARTITION_SIZE}"

# Usage type default, block size 4k defined in recipe. See https://github.com/tytso/e2fsprogs/issues/50
mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 -T default -b ${FS_BLOCK_SIZE}  -i 8192 -d ${DATA_VOLUME} -F ${BUILD}/resin-data.img
