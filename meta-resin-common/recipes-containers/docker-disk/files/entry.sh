#!/bin/sh

set -o errexit
set -o nounset

finish() {
    # Make all files owned by the build system
    chown -R "$USER_ID:$USER_GID" "$DATA_VOLUME"
}

trap finish EXIT

DOCKER_TIMEOUT=20 # Wait 20 seconds for docker to start
DATA_VOLUME=/resin-data

# Create user
echo "[INFO] Creating and setting $USER_ID:$USER_GID."
groupadd -g "$USER_GID" docker-disk-group
useradd -u "$USER_ID" -g "$USER_GID" -p "" docker-disk-user

# Create the directory structures we use for Resin
mkdir -p $DATA_VOLUME/docker
mkdir -p $DATA_VOLUME/resin-data

# Start docker with the created image
echo "Starting docker daemon with $BALENA_STORAGE storage driver."
docker daemon -g $DATA_VOLUME/docker -s "$BALENA_STORAGE" &
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

if [ -n "${TARGET_REPOSITORY}" ] && [ -n "${TARGET_TAG}" ]; then
    echo "Pulling ${TARGET_REPOSITORY}:${TARGET_TAG}..."
	docker pull "${TARGET_REPOSITORY}:${TARGET_TAG}"
fi

echo "Stopping docker..."
kill -TERM "$(cat /var/run/docker.pid)"
# don't let wait() error out and crash the build if the docker daemon has already been stopped
wait "$(cat /var/run/docker.pid)" || true
