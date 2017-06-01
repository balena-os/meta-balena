#!/bin/bash

set -m

function mount_dev()
{
	mkdir -p /tmp
	mount -t devtmpfs none /tmp
	mkdir -p /tmp/shm
	mount --move /dev/shm /tmp/shm
	mkdir -p /tmp/mqueue
	mount --move /dev/mqueue /tmp/mqueue
	mkdir -p /tmp/pts
	mount --move /dev/pts /tmp/pts
	touch /tmp/console
	mount --move /dev/console /tmp/console
	umount /dev || true
	mount --move /tmp /dev

	# Since the devpts is mounted with -o newinstance by Docker, we need to make
	# /dev/ptmx point to its ptmx.
	# ref: https://www.kernel.org/doc/Documentation/filesystems/devpts.txt
	ln -sf /dev/pts/ptmx /dev/ptmx
	mount -t debugfs nodev /sys/kernel/debug

}

function init_systemd()
{
	env > /etc/docker.env

	# Mask the services that cannot be run inside a docker container
	systemctl mask \
		dev-hugepages.mount \
		sys-fs-fuse-connections.mount \
		sys-kernel-config.mount \
		display-manager.service \
		getty@.service \
		systemd-logind.service \
		systemd-remount-fs.service \
		getty.target \
		graphical.target \
		systemd-ask-password-plymouth.service \
		plymouth-start.service \
		plymouth-reboot.service \
		plymouth-halt.service \
		plymouth-poweroff.service \
		plymouth-quit.service

	# Remove data/state/boot mounts as they are not mounted in the docker container.
	# Also remove the mount points as dependencies of any services.
	cd /lib/systemd/system && \
		find . -type f -exec  sed -i 's|mnt-state.mount ||g' {} \;  && \
		find . -type f -exec  sed -i 's|mnt-data.mount ||g' {} \;  && \
		find . -type f -exec  sed -i 's|mnt-boot.mount ||g' {} \;  && \
		find . -type f -exec  sed -i 's|mnt-state.mount||g' {} \;  && \
		find . -type f -exec  sed -i 's|mnt-data.mount||g' {} \;  && \
		find . -type f -exec  sed -i 's|mnt-boot.mount||g' {} \;  && \
		rm /lib/systemd/system/mnt-data.mount && \
		rm /lib/systemd/system/mnt-state.mount && \
		rm /lib/systemd/system/mnt-boot.mount

	# This is required to allow the container to run when the dockerd is started with
	# user namespace remapping ( --userns-remap )
	addgroup -S dockremap && \
		adduser -S -G dockremap dockremap && \
		echo 'dockremap:165536:65536' >> /etc/subuid && \
		echo 'dockremap:165536:65536' >> /etc/subgid

	exec /sbin/init quiet systemd.show_status=0
}

mount_dev

init_systemd
