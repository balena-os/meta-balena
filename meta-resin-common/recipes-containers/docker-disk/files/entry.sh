#!/bin/bash

set -o errexit
set -o nounset

DOCKER_TIMEOUT=20 # Wait 20 seconds for docker to start

# Default values
PARTITION_SIZE=${PARTITION_SIZE:=1024}

# Create sparse file to hold ext4 resin-data partition
dd if=/dev/zero of=/export/resin-data.img bs=1M count=0 seek=$PARTITION_SIZE
# now partition the newly created file to ext4
mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 -i 8192 -F /export/resin-data.img

# Setup the loop device with the disk image
mkdir /resin-data
mount -o loop /export/resin-data.img /resin-data

# Create the directory structures we use for Resin
mkdir -p /resin-data/docker
mkdir -p /resin-data/resin-data

# Start docker with the created image
echo "Starting docker daemon with $DOCKER_STORAGE storage driver."
docker daemon -g /resin-data/docker -s $DOCKER_STORAGE &
echo "Waiting for docker to become ready.."
STARTTIME=$(date +%s)
ENDTIME=$(date +%s)
while [ ! -S /var/run/docker.sock ]
do
    if [ $(($ENDTIME - $STARTTIME)) -le $DOCKER_TIMEOUT ]; then
        sleep 1
        ENDTIME=$(date +%s)
    else
        echo "Timeout while waiting for docker to come up."
        exit 1
    fi
done
echo "Docker started."

if [ -n "${TARGET_REPOSITORY}" ] && [ -n "${TARGET_TAG}" ]; then
    echo "Pulling ${TARGET_REPOSITORY}:${TARGET_TAG}..."
    docker pull $TARGET_REPOSITORY:$TARGET_TAG
fi

echo "Stopping docker..."
kill -TERM $(cat /var/run/docker.pid) && wait $(cat /var/run/docker.pid) && umount /resin-data

echo "Docker export successful."
