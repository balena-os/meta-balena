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

# Create user
echo "[INFO] Creating and setting $USER_ID:$USER_GID."
groupadd -g "$USER_GID" docker-disk-group || true
useradd -u "$USER_ID" -g "$USER_GID" -p "" docker-disk-user || true

mkdir -p $DATA_VOLUME/docker
mkdir -p $DATA_VOLUME/resin-data

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

if [ -n "${PRIVATE_REGISTRY}" ] && [ -n "${PRIVATE_REGISTRY_USER}" ] && [ -n "${PRIVATE_REGISTRY_PASSWORD}" ]; then
	echo "login ${PRIVATE_REGISTRY}..."
	docker login -u "${PRIVATE_REGISTRY_USER}" -p "${PRIVATE_REGISTRY_PASSWORD}" "${PRIVATE_REGISTRY}"
fi

# Pull in the images
echo "Pulling ${TARGET_REPOSITORY}:${TARGET_TAG}..."
docker pull "${TARGET_REPOSITORY}:${TARGET_TAG}"
# Pull in arch specific hello-world image and tag it balena-healthcheck-image
echo "Pulling ${HELLO_REPOSITORY}:latest..."
docker pull --platform "${HOSTAPP_PLATFORM}" "${HELLO_REPOSITORY}"
docker tag "${HELLO_REPOSITORY}" balena-healthcheck-image
docker rmi "${HELLO_REPOSITORY}"
docker save balena-healthcheck-image > ${BUILD}/balena-healthcheck-image.tar
# Pull in host extension images
BALENA_HOSTAPP_EXTENSIONS_FEATURE="io.balena.features.host-extension"
for image_name in ${HOSTEXT_IMAGES}; do
	if docker pull --platform "${HOSTAPP_PLATFORM}" "${image_name}"; then
		docker create --label "${BALENA_HOSTAPP_EXTENSIONS_FEATURE}" "${image_name}"
	else
		echo "Not able to pull ${HOSTAPP_PLATFORM}/${image_name}"
	fi
done

echo "Stopping docker..."
kill -TERM "$(cat /var/run/docker.pid)"
# don't let wait() error out and crash the build if the docker daemon has already been stopped
wait "$(cat /var/run/docker.pid)" || true

# Export the final data filesystem
dd if=/dev/zero of=${BUILD}/resin-data.img bs=1M count=0 seek="${PARTITION_SIZE}"
mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 -i 8192 -d ${DATA_VOLUME} -F ${BUILD}/resin-data.img
