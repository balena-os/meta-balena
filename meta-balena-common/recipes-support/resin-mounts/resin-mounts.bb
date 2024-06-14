SUMMARY = "Resin systemd mount services"

include resin-mounts.inc

RDEPENDS:${PN} += "os-helpers-fs"

SRC_URI += " \
	file://balena-efi.service \
	file://resin-boot.service \
	file://resin-data.service \
	file://resin-state.service \
	file://mnt-sysroot-active.service \
	file://mnt-sysroot-inactive.automount \
	file://mnt-sysroot-inactive.mount \
	file://resin-partition-mounter \
	file://etc-fake-hwclock.mount \
	"

SYSTEMD_SERVICE:${PN} += " \
	resin-boot.service \
	resin-data.service \
	resin-state.service \
	mnt-sysroot-active.service \
	mnt-sysroot-inactive.automount \
	mnt-sysroot-inactive.mount \
	"

SYSTEMD_SERVICE:${PN} += "${@oe.utils.conditional('SIGN_API','','','${BALENA_NONENC_BOOT_LABEL}.service',d)}"

FILES:${PN} += " \
	${BALENA_BOOT_MOUNT} \
	${@oe.utils.conditional('SIGN_API','','','${BALENA_NONENC_BOOT_MOUNT}',d)} \
	/mnt/data \
	/mnt/state \
	/mnt/sysroot/active \
	/mnt/sysroot/inactive \
	"

BINDMOUNTS += " \
	/etc/docker \
	/etc/balena-supervisor \
	/home/root/.docker \
	/var/log/journal \
	/var/lib/systemd \
	/var/lib/chrony \
	"

ROOTFS_TYPE = "${@oe.utils.conditional('SIGN_API','','auto','crypto_LUKS',d)}"
do_install:prepend () {
	# These are mountpoints for various mount services/units
	install -d ${D}/etc/docker
	ln -sf docker ${D}/etc/balena
	ln -sf docker ${D}/etc/balena-engine
	install -d ${D}${BALENA_BOOT_MOUNT}
	install -d ${D}/mnt/data
	if [ "x${SIGN_API}" != "x" ]; then
		install -d "${D}${BALENA_NONENC_BOOT_MOUNT}"
	fi
	install -d ${D}/mnt/state
	install -d ${D}/mnt/sysroot/active
	install -d ${D}/mnt/sysroot/inactive

	install -d ${D}${bindir}
	install -m 755 ${WORKDIR}/resin-partition-mounter ${D}${bindir}
	sed -i 's,@@ROOTFS_TYPE@@,${ROOTFS_TYPE},' "${D}${bindir}/resin-partition-mounter"
	install -d ${D}${systemd_unitdir}/system
	for service in ${SYSTEMD_SERVICE:resin-mounts}; do
		install -m 0644 $service ${D}${systemd_unitdir}/system/
	done
	install -m 0644 ${WORKDIR}/etc-fake-hwclock.mount ${D}${systemd_unitdir}/system/etc-fake\\x2dhwclock.mount
}
