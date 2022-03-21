#!/bin/sh

# Test for the presence of
# [PATCH] ovl: fix regression caused by overlapping layers detection
# https://github.com/amir73il/linux/commit/9995d3a5ee3851a6883b0627b703e64146291453
#
# we create an overlay mount using /lower, /upper0/u and /upper0/w
# we then try to create another overlay mount that references the previous
# upperdir `upper0/u` as it's lowerdir
#
# on a patched systemd this should work
# an unpatched systemd will fail with the dmesg line:
#
# > overlayfs: lowerdir is in-use as upperdir/workdir
# 
# This relates to the overlapping layers detection code no longer emitting 
# warnings and instead errors when index=off is set.
# This breaks docker code relying on this behavior, introducing regressions.
#
set -e
[ -n "$DEBUG" ] && set -x

# According to the above commit, the issue affected kernel versions 4.13 and
# newer. Therefore we need to run this test on kernels newer than that,
# otherwise it will fail.
MIN_KERNEL_VER="4.13"
KERNEL_VER=$(uname -r | sed 's/\./-/2' | cut -d- -f1)

if [ "$(printf '%s\n' "$MIN_KERNEL_VER" "$KERNEL_VER" | sort -V | head -n1)" = "$MIN_KERNEL_VER" ]; then
	echo "kernel version ${KERNEL_VER} suitable for test"
else
	# Exit now, otherwise the test will fail on kernels older than the 4.13
	echo "ok - test skipped, min kernel version requirement not met - DUT running ${KERNEL_VER}"
	exit 0
fi

root=${ROOT:-$PWD}
root="$root"/ovl

trap '{ echo "cleanup"; umount -R "$root"/{mnt0,mnt1} 2>/dev/null || true; rm -rf "$root"; }' EXIT

mkdir -p "$root"/upper0/u "$root"/upper0/w "$root"/lower
mkdir -p "$root"/upper1/u "$root"/upper1/w
mkdir -p "$root"/mnt0 "$root"/mnt1

mount -t overlay none "$root"/mnt0 \
    -o lowerdir="$root"/lower,upperdir="$root"/upper0/u,workdir="$root"/upper0/w

for _ in 1 2 3
do
	mount -t overlay none "$root"/mnt1 \
	    -o index=off,lowerdir="$root"/upper0/u,upperdir="$root"/lower,workdir="$root"/upper1/w || exit 1
	sleep 1
	umount "$root"/mnt1
	echo "retrying"
done

echo "ok"
exit 0
