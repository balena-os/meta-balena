SUMMARY = "Resin systemd mount services"

include resin-mounts.inc

SRC_URI += " \
	file://resin-boot.service \
	file://resin-data.service \
	file://resin-state.service \
	file://mnt-sysroot-active.service \
	file://mnt-sysroot-inactive.automount \
	file://mnt-sysroot-inactive.mount \
	file://resin-partition-mounter \
	"

SYSTEMD_SERVICE_${PN} += " \
	resin-boot.service \
	resin-data.service \
	resin-state.service \
	mnt-sysroot-active.service \
	mnt-sysroot-inactive.automount \
	mnt-sysroot-inactive.mount \
	"

FILES_${PN} += " \
	/mnt/boot \
	/mnt/data \
	/mnt/state \
	/mnt/sysroot/active \
	/mnt/sysroot/inactive \
	"

BINDMOUNTS += " \
	/etc/docker \
	/etc/resin-supervisor \
	/home/root/.docker \
	/var/log/journal \
	/var/lib/systemd \
	/var/lib/chrony \
	"

do_install_prepend () {
	# These are mountpoints for various mount services/units
	install -d ${D}/etc/docker
	ln -sf docker ${D}/etc/balena
	ln -sf docker ${D}/etc/balena-engine
	install -d ${D}/mnt/boot
	install -d ${D}/mnt/data
	install -d ${D}/mnt/state
	install -d ${D}/mnt/sysroot/active
	install -d ${D}/mnt/sysroot/inactive

	install -d ${D}${bindir}
	install -m 755 ${WORKDIR}/resin-partition-mounter ${D}${bindir}

	install -d ${D}${systemd_unitdir}/system
	for service in ${SYSTEMD_SERVICE_resin-mounts}; do
		install -m 0644 $service ${D}${systemd_unitdir}/system/
	done
}
