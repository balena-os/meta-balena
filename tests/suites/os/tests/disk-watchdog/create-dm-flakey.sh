#!/usr/bin/env bash
# Create a dm-flakey device on top of a loop-backed image and mount it.
# Usage:
#   create-dm-flakey.sh <mount_point> <image_path> <dm_name>
#   create-dm-flakey.sh cleanup <mount_point> <image_path> <dm_name>
# Exit codes:
#   1: usage
#   2: image creation failed
#   3: loop setup failed
#   4: mkfs failed
#   5: dmsetup failed
#   6: mount failed
#   7: could not determine device size

set -u

die() { echo "ERROR: $2" >&2; cleanup; exit "$1"; }

cleanup() {
    # Best-effort cleanup
    set +e
    if [[ -n ${MOUNT_POINT:-} ]] && mountpoint -q "$MOUNT_POINT"; then
        umount "$MOUNT_POINT" >/dev/null 2>&1
    fi
    if [[ -n ${DM_NAME:-} ]] && dmsetup info "$DM_NAME" >/dev/null 2>&1; then
        dmsetup remove "$DM_NAME" >/dev/null 2>&1
    fi
    # Determine loop device by variable or by image path
    if [[ -z ${LOOP_DEV:-} ]] && [[ -n ${IMG_PATH:-} ]]; then
        LOOP_DEV=$(losetup -d "$IMG_PATH" | awk -F: 'NR==1{print $1}')
    fi
    if [[ -n ${LOOP_DEV:-} ]] && losetup -a | grep -q "^$LOOP_DEV:"; then
        losetup -d "$LOOP_DEV" >/dev/null 2>&1
    fi
    # Remove backing image if provided
    if [[ -n ${IMG_PATH:-} && -f "$IMG_PATH" ]]; then
        rm -f "$IMG_PATH"
    fi
    set -e
}

if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <mount_point> <image_path> <dm_name> | $0 cleanup <mount_point> <image_path> <dm_name>" >&2
    exit 1
fi

if [[ "$1" == "cleanup" ]]; then
    MOUNT_POINT=$2
    IMG_PATH=$3
    DM_NAME=$4
    cleanup
    exit 0
fi

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <mount_point> <image_path> <dm_name>" >&2
    exit 1
fi

MOUNT_POINT=$1
IMG_PATH=$2
DM_NAME=$3

mkdir -p "$MOUNT_POINT" || die 6 "Failed to create mount point $MOUNT_POINT"

# Create image if missing (100 MiB)
if [[ ! -e "$IMG_PATH" ]]; then
    if ! dd if=/dev/zero of="$IMG_PATH" bs=1M count=10 status=none; then
        die 2 "Failed to create image at $IMG_PATH"
    fi
fi

# Setup loop device
LOOP_DEV=$(losetup -f) || die 3 "Failed to get free loop device"
if ! losetup -P "$LOOP_DEV" "$IMG_PATH"; then
    die 3 "Failed to attach $IMG_PATH to $LOOP_DEV"
fi

# Create filesystem on the loop device
if ! mkfs.ext4 -F "$LOOP_DEV" >/dev/null; then
    die 4 "mkfs.ext4 failed on $LOOP_DEV"
fi

if ! mount "$LOOP_DEV" "$MOUNT_POINT"; then
    die 6 "Failed to mount $LOOP_DEV on $MOUNT_POINT"
fi
dd if=/dev/urandom of="$MOUNT_POINT/test.bin" bs=1M count=5 status=none || die 7 "Failed to create test.bin on $MOUNT_POINT"
if ! umount "$MOUNT_POINT"; then
    die 6 "Failed to unmount $MOUNT_POINT"
fi

# Determine size in 512B sectors
SECTORS=$(blockdev --getsz "$LOOP_DEV" 2>/dev/null) || true
[[ -n "$SECTORS" && "$SECTORS" =~ ^[0-9]+$ ]] || die 7 "Could not determine size for $LOOP_DEV"

# Create dm-flakey mapping: 1s up / 1s down
TABLE="0 $SECTORS flakey $LOOP_DEV 0 1 2"
if ! echo "$TABLE" | dmsetup create "$DM_NAME"; then
    die 5 "dmsetup create failed for $DM_NAME"
fi

# Mount the flakey device
if ! mount "/dev/mapper/$DM_NAME" "$MOUNT_POINT"; then
    die 6 "Failed to mount /dev/mapper/$DM_NAME on $MOUNT_POINT"
fi

# Leave devices mounted/active; caller is responsible for teardown.
exit 0