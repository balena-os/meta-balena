#!/bin/bash

set -o errexit
set -o nounset

DOCKER_TIMEOUT=20 # Wait 20 seconds for docker to start

# Default values
PARTITION_SIZE=${PARTITION_SIZE:=1024}

# Create sparse file to hold ext4 resin-data partition
dd if=/dev/zero of=/export/data_disk.img bs=1M count=0 seek=$PARTITION_SIZE
# now partition the newly created file to ext4
mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 -F /export/data_disk.img

# Setup the loop device with the disk image
mkdir /data_disk
mount -o loop /export/data_disk.img /data_disk

# Create the directory structures we use for Resin
mkdir -p /data_disk/docker
mkdir -p /data_disk/resin-data

# Start docker with the created image.
docker daemon -g /data_disk/docker -s aufs &
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

if [ -n "${TARGET_REPOSITORY}" ] && [ -n "${TARGET_TAG}" ]; then
    docker pull $TARGET_REPOSITORY:$TARGET_TAG
    docker tag $TARGET_REPOSITORY:$TARGET_TAG $TARGET_REPOSITORY:latest
fi

kill -TERM $(cat /var/run/docker.pid) && wait $(cat /var/run/docker.pid) && umount /data_disk

echo "Docker export successful."

# Export 2

# Create the directory structures we use for Resin
mkdir -p /export2/data_disk/docker
mkdir -p /export2/data_disk/resin-data

# Start docker with the created image.
docker daemon -g /export2/data_disk/docker -s aufs &
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

if [ -n "${TARGET_REPOSITORY}" ] && [ -n "${TARGET_TAG}" ]; then
    docker pull $TARGET_REPOSITORY:$TARGET_TAG
    docker tag $TARGET_REPOSITORY:$TARGET_TAG $TARGET_REPOSITORY:latest
fi

kill -TERM $(cat /var/run/docker.pid) && wait $(cat /var/run/docker.pid) 

adduser owner && addgroup owner
chown owner:owner /export2/data_disk/ -R
echo "Docker export 2 successful."
