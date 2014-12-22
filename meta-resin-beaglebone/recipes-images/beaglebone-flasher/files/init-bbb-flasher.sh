#!/bin/bash

echo 1 > /sys/class/leds/beaglebone:green:heartbeat/brightness
 
# Card config
export SDCARD=/dev/mmcblk1
# Boot partition size [in KiB]
export BOOT_SPACE=20480 # 20 MB
# Rootfs Size [in KiB]
export ROOTFS_SIZE=102400 # 100 MB
# Swap Size [ in KiB]
export SWAP_SIZE=262144 # 256 MB

# First partition begin at sector 2
export IMAGE_ROOTFS_ALIGNMENT=1

# Align partitions
export BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE} + ${IMAGE_ROOTFS_ALIGNMENT} - 1)
export BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE_ALIGNED} - ${BOOT_SPACE_ALIGNED} % ${IMAGE_ROOTFS_ALIGNMENT})

# Create Partition table
parted -s ${SDCARD} mklabel msdos

# Create boot partition and mark it as bootable
parted -s ${SDCARD} unit KiB mkpart primary fat16 ${IMAGE_ROOTFS_ALIGNMENT} $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT})
parted -s ${SDCARD} set 1 boot on
        
# Create rootfs partition
parted -s ${SDCARD} unit KiB mkpart primary ext4 $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT}) $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ ${ROOTFS_SIZE})

# Create swap partition
parted -s ${SDCARD} unit KiB mkpart primary linux-swap $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ ${ROOTFS_SIZE}) $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ ${ROOTFS_SIZE} \+ ${SWAP_SIZE})

# Create docker data partition with the rest of the space.
parted -s ${SDCARD} unit KiB mkpart primary btrfs $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ ${ROOTFS_SIZE} \+ ${SWAP_SIZE}) 100%

parted ${SDCARD} print

partprobe

mkfs.vfat -F 16 /dev/mmcblk1p1 
mkfs.ext4 /dev/mmcblk1p2 
mkswap /dev/mmcblk1p3

echo 1 > /sys/class/leds/beaglebone:green:mmc0/brightness

mkdir -p /tmp/new_root
mkdir -p /tmp/new_boot
mkdir -p /tmp/boot

mount /dev/mmcblk0p1 /tmp/boot # This is not mounted at /boot by default.
mount /dev/mmcblk1p2 /tmp/new_root
mount /dev/mmcblk1p1 /tmp/new_boot

cp /tmp/boot/MLO /tmp/new_boot/ # This needs to go first into the partition.
cp /tmp/boot/u-boot-emmc.img /tmp/new_boot/u-boot.img # Copy the emmc specific u-boot to emmc
rsync -a --numeric-ids --exclude='/tmp/*' --exclude='/dev/*' --exclude='/proc/*' --exclude='/sys/*' --exclude='/var/volatile/*' --exclude='/run/*' / /tmp/new_root/ # rsync the rest of the files.

export ROOTUUID=`blkid -s PARTUUID -o value /dev/mmcblk1p1`
export SWAPUUID=`blkid -s PARTUUID -o value /dev/mmcblk1p2`
export BTRFSUUID=`blkid -s PARTUUID -o value /dev/mmcblk1p3`

echo "setenv mmcroot PARTUUID=${ROOTUUID} rw; run mmcboot;" >> /tmp/new_boot/uEnv.txt

echo 1 > /sys/class/leds/beaglebone:green:usr2/brightness

sync && sync && umount /dev/mmcblk1p1 && umount /dev/mmcblk1p2

echo 1 > /sys/class/leds/beaglebone:green:usr3/brightness

echo "Rebooting"

reboot -f
