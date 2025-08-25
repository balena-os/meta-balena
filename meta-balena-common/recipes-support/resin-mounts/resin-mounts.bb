SUMMARY = "Resin systemd mount services"

include resin-mounts.inc

RDEPENDS:${PN} += "os-helpers-fs"

SRC_URI += " \
	file://balena-nonencboot.service \
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
	${ROOT_HOME}/.docker \
	/var/log/journal \
	/var/lib/systemd \
	/var/lib/chrony \
	"

do_install:prepend () {
	# These are mountpoints for various mount services/units
	install -d ${D}/etc/docker
	ln -sf docker ${D}/etc/balena
	ln -sf docker ${D}/etc/balena-engine
	install -d ${D}${BALENA_BOOT_MOUNT}
	install -d ${D}/mnt/data
	install -d ${D}/mnt/state
	install -d ${D}/mnt/sysroot/active
	install -d ${D}/mnt/sysroot/inactive

	install -d ${D}${bindir}
	install -m 755 ${WORKDIR}/resin-partition-mounter ${D}${bindir}

	install -d ${D}${systemd_unitdir}/system
	if [ "x${SIGN_API}" != "x" ]; then
		install -d "${D}${BALENA_NONENC_BOOT_MOUNT}"
		install -m 0644 balena-nonencboot.service ${D}${systemd_unitdir}/system/${BALENA_NONENC_BOOT_LABEL}.service
		sed -i -e "s/@@BALENA_NONENC_BOOT_LABEL@@/${BALENA_NONENC_BOOT_LABEL}/g" "${D}${systemd_unitdir}/system/${BALENA_NONENC_BOOT_LABEL}.service"
		if ${@bb.utils.contains('MACHINE_FEATURES','efi','true','false',d)}; then
			sed -i '/^\[Unit\]/a ConditionPathIsSymbolicLink=/mnt/boot/EFI' "${D}${systemd_unitdir}/system/${BALENA_NONENC_BOOT_LABEL}.service"
		else
			sed -i "/^\[Unit\]/a ConditionPathExists=/dev/disk/by-state/${BALENA_NONENC_BOOT_LABEL}" "${D}${systemd_unitdir}/system/${BALENA_NONENC_BOOT_LABEL}.service"
		fi
	fi
	for service in ${SYSTEMD_SERVICE:resin-mounts}; do
		if [ -f $service ]; then
			install -m 0644 $service ${D}${systemd_unitdir}/system/
		fi
	done
	install -m 0644 ${WORKDIR}/etc-fake-hwclock.mount ${D}${systemd_unitdir}/system/etc-fake\\x2dhwclock.mount
}
