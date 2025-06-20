#!/bin/bash

. /usr/libexec/os-helpers-logging
. /usr/libexec/os-helpers-fs

teardown() {
    info "Cleaning up..."
    rm -f "${TEST_FILE}"
    if mountpoint -q "${TMPDIR}"; then
        umount "${TMPDIR}"
    fi
    if [ -b "${ZRAM_DEV}" ]; then
        zramctl --reset "${ZRAM_DEV}"
    fi
    rm -rf "${TMPDIR}"
}

if [ "$(id -u)" -ne 0 ]; then
    fail "This script must be run as root."
fi

# Ensure cleanup on exit
trap teardown EXIT

TEST_FILE=$(mktemp)
TEST_CONTENT_SIZE="$(( 1 * 1024 * 1024 * 1024 ))" # 1GiB
info "Creating test file: ${TEST_FILE} of size ${TEST_CONTENT_SIZE}"
if ! dd if=/dev/urandom of="${TEST_FILE}" bs="${TEST_CONTENT_SIZE}" count=1 status=none; then
    fail "Failed to create test file. Exiting."
fi

info "Setting up zram device and mounting it"

# Do not fail as zram could be built-in
modprobe zram || true

# Configure zram0 (assuming it's available) with size 100MiB more than the test file size for meta-data
if ! ZRAM_DEV=$(zramctl --find --size "$(( TEST_CONTENT_SIZE + (100 * 1024 * 1024)))" --algo zstd); then
    info "Available zram devices: " "$(zramctl)"
    zramctl --reset "/dev/zram0" || true
    if ZRAM_DEV=$(zramctl --find --size "$(( TEST_CONTENT_SIZE + (100 * 1024 * 1024)))" --algo zstd); then
        info "Initialized $ZRAM_DEV."
    fi
    fail "Failed to set up zram device."
fi

# Make a filesystem on the zram device
if ! mkfs.ext4 -F "${ZRAM_DEV}" > /dev/null 2>&1; then
    fail "Failed to create filesystem on zram device."
fi

TMPDIR=$(mktemp -d)
mkdir -p "${TMPDIR}"
if ! mount "${ZRAM_DEV}" "${TMPDIR}"; then
    fail "Failed to mount zram device."
fi

if ! ESTIMATED_SIZE=$(estimate_size_in_zram "${TEST_FILE}" "${TMPDIR}"); then
    fail "estimate_size_in_zram failed."
fi

cp "${TEST_FILE}" "${TMPDIR}/" && sync

ZRAM_SYSFS_SIZE=$(cat "/sys/block/$(basename "${ZRAM_DEV}")/mm_stat" | awk '{print $2}')

info "Original file size: $(du -b "${TEST_FILE}" | awk '{print $1}') bytes"
info "Estimated size (estimate_size_in_zram): ${ESTIMATED_SIZE} bytes"
info "Actual zram sysfs compressed size: ${ZRAM_SYSFS_SIZE} bytes"

# We will use a 5% margin for the estimated size comparison.
# For `bc` to handle floating point arithmetic:
LOWER_BOUND=$(echo "scale=0; ${ZRAM_SYSFS_SIZE} * 0.95 / 1" | bc)
UPPER_BOUND=$(echo "scale=0; ${ZRAM_SYSFS_SIZE} * 1.05 / 1" | bc)

info "Lower bound: ${LOWER_BOUND} bytes, Upper bound: ${UPPER_BOUND} bytes"
if (( ESTIMATED_SIZE >= LOWER_BOUND )) && (( ESTIMATED_SIZE <= UPPER_BOUND )); then
    info "Estimate_size_in_zram: PASS (Estimated size is within 5% of actual sysfs size)."
else
    error "Estimate_size_in_zram: FAIL (Estimated size ${ESTIMATED_SIZE} is not within 5% of actual sysfs size ${ZRAM_SYSFS_SIZE})."
    exit 1
fi
