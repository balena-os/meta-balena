#!/bin/bash

#--- This script is now setup to fail if any environment variable is missing.

set -o errexit
set -o nounset

export PARTITION_SIZE=${PARTITION_SIZE:=1000}
export TARGET_REPOSITORY=${TARGET_REPOSITORY:=resin/i386-supervisor}
export TARGET_TAG=${TARGET_TAG:=master}

## Add code to check /export directories presence
#-- Create a blank disk image.
dd if=/dev/zero of=/export/data_disk.img bs=1M count=$PARTITION_SIZE
mkfs.btrfs /export/data_disk.img

# Setup the loop device with the disk image
mkdir /data_disk
mount -o loop /export/data_disk.img /data_disk

# Create the directory structures we use for Resin
mkdir -p /data_disk/rce
mkdir -p /data_disk/resin-data

# Start docker with the created image.
docker -d -g /data_disk/rce -s btrfs &
echo "Waiting for docker to become ready.."
while [ ! -S /var/run/docker.sock ]
do
	sleep 1
done

docker pull $TARGET_REPOSITORY:$TARGET_TAG
docker tag $TARGET_REPOSITORY:$TARGET_TAG $TARGET_REPOSITORY:latest

kill -TERM $(cat /var/run/docker.pid) && wait $(cat /var/run/docker.pid) && umount /data_disk

echo "Docker export successful."
