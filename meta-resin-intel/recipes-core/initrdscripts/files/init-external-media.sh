#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin

udev_daemon() {
	OPTIONS="/sbin/udev/udevd /sbin/udevd /lib/udev/udevd /lib/systemd/systemd-udevd"

	for o in $OPTIONS; do
		if [ -x "$o" ]; then
			echo $o
			return 0
		fi
	done

	return 1
}

_UDEV_DAEMON=`udev_daemon`

early_setup() {
    mkdir -p /proc
    mkdir -p /sys
    mount -t proc proc /proc
    mount -t sysfs sysfs /sys
    mount -t devtmpfs none /dev

    mkdir -p /run
    mkdir -p /var/run

    $_UDEV_DAEMON --daemon
    udevadm trigger
    udevadm settle
}

read_args() {
    [ -z "$CMDLINE" ] && CMDLINE=`cat /proc/cmdline`
    for arg in $CMDLINE; do
        optarg=`expr "x$arg" : 'x[^=]*=\(.*\)'`
        case $arg in
            LABEL=*)
                label=$optarg ;;
        esac
    done
}

boot_external_rootfs() {
    mkdir /.flasher_root
    mount /dev/disk/by-label/flash-root /.flasher_root
    # Watches the udev event queue, and exits if all current events are handled
    killall "${_UDEV_DAEMON##*/}" 2>/dev/null

    exec switch_root /.flasher_root /sbin/init ||
        fatal "Couldn't switch_root, dropping to shell"
}

fatal() {
    echo $1 >$CONSOLE
    echo >$CONSOLE
    exec sh
}

early_setup

[ -z "$CONSOLE" ] && CONSOLE="/dev/console"

read_args

echo "Waiting for udev to populate /dev/disk/by-label/ from USB media"

while true
do
    if ls -A /dev/disk/by-label/flash-root >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

# unmount the USB partitions from /run/media/ (to be checked in the future if we will disable this automounting behaviour)
umount /run/media/* 2>/dev/null

case $label in
    boot)
	boot_external_rootfs
	;;
    *)
	# Not sure what boot label is provided.  Try to boot to avoid locking up.
	boot_external_rootfs
	;;
esac
