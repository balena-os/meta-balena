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
	/mnt/boot \
	/mnt/data \
	/mnt/${BALENA_NONENC_BOOT_LABEL#balena-} \
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

do_install:prepend () {
	# These are mountpoints for various mount services/units
	install -d ${D}/etc/docker
	ln -sf docker ${D}/etc/balena
	ln -sf docker ${D}/etc/balena-engine
	install -d ${D}/mnt/boot
	install -d ${D}/mnt/data
	if ${@oe.utils.conditional('SIGN_API', '', 'false', 'true', d)}; then
		install -d ${D}/mnt/${BALENA_NONENC_BOOT_LABEL#balena-}
	fi
	install -d ${D}/mnt/state
	install -d ${D}/mnt/sysroot/active
	install -d ${D}/mnt/sysroot/inactive

	install -d ${D}${bindir}
	install -m 755 ${WORKDIR}/resin-partition-mounter ${D}${bindir}
	sed -i -e "s/%%BALENA_NONENC_BOOT_LABEL%%/${BALENA_NONENC_BOOT_LABEL}/g" ${D}${bindir}/resin-partition-mounter
	sed -i -e "s/%%BALENA_NONENC_BOOT_MOUNT%%/$(echo ${BALENA_NONENC_BOOT_LABEL} | cut -d - -f2)/g" ${D}${bindir}/resin-partition-mounter

	install -d ${D}${systemd_unitdir}/system
	for service in ${SYSTEMD_SERVICE:resin-mounts}; do
		install -m 0644 $service ${D}${systemd_unitdir}/system/
	done
	install -m 0644 ${WORKDIR}/etc-fake-hwclock.mount ${D}${systemd_unitdir}/system/etc-fake\\x2dhwclock.mount
}
