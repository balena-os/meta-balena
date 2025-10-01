#!/bin/sh

setup_devtmpfs() {
    newdev=/tmp/dev
    mkdir -p "$newdev"
    mount -t devtmpfs none "$newdev"
    mount --move /dev/console "$newdev/console"
    mount --move /dev/mqueue "$newdev/mqueue"
    mount --move /dev/pts "$newdev/pts"
    mount --move /dev/shm "$newdev/shm"
    umount /dev
    mount --move "$newdev" /dev
    ln -sf /dev/pts/ptmx /dev/ptmx
}

# Run setup before anything else
setup_devtmpfs

# Execute the main command
exec "$@"
