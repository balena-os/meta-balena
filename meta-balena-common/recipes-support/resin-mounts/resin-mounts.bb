SUMMARY = "Resin systemd mount services"

include resin-mounts.inc

RDEPENDS:${PN} += "os-helpers-fs"

SRC_URI += " \
	file://balena-efi.service \
	file://resin-boot.service \
	file://mnt-data.automount \
	file://mnt-data.mount \
	file://mnt-state.automount \
	file://mnt-state.mount \
	file://mnt-sysroot-active.automount \
	file://mnt-sysroot-active.mount \
	file://mnt-sysroot-inactive.automount \
	file://mnt-sysroot-inactive.mount \
	file://resin-partition-mounter \
	file://etc-fake-hwclock.mount \
	"

SYSTEMD_SERVICE:${PN} += " \
	balena-efi.service \
	resin-boot.service \
	mnt-data.mount \
	mnt-state.mount \
	mnt-sysroot-active.mount \
	mnt-sysroot-inactive.automount \
	mnt-sysroot-inactive.mount \
	"

FILES:${PN} += " \
	/mnt/boot \
	/mnt/data \
	/mnt/efi \
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
	install -d ${D}/mnt/efi
	install -d ${D}/mnt/state
	install -d ${D}/mnt/sysroot/active
	install -d ${D}/mnt/sysroot/inactive

	install -d ${D}${bindir}
	install -m 755 ${WORKDIR}/resin-partition-mounter ${D}${bindir}

	install -d ${D}${systemd_unitdir}/system
	for service in ${SYSTEMD_SERVICE:resin-mounts}; do
		install -m 0644 $service ${D}${systemd_unitdir}/system/
	done
	install -m 0644 ${WORKDIR}/etc-fake-hwclock.mount ${D}${systemd_unitdir}/system/etc-fake\\x2dhwclock.mount
}
