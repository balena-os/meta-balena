SUMMARY = "Resin flasher systemd mount services"

include resin-mounts.inc

SRC_URI += " \
	file://mnt-boot.mount \
	file://mnt-boottmp.mount \
	file://resin-boot.service \
	file://temp-conf.service \
	"

SYSTEMD_SERVICE_${PN} += " \
	mnt-boot.mount \
	mnt-boottmp.mount \
	resin-boot.service \
	temp-conf.service \
	"

FILES_${PN} += " \
	/mnt/boot \
	/mnt/boottmp \
	"

BINDMOUNTS += " \
	/etc/dropbear \
	/etc/hostname \
	/etc/NetworkManager/system-connections \
	/home/root/.rnd \
	"

do_install_prepend () {
	# These are mountpoints for various mount services/units
	install -d ${D}/mnt/boot
	install -d ${D}/mnt/boottmp

	install -d ${D}${sysconfdir}/systemd/system/
	for service in ${SYSTEMD_SERVICE_resin-mounts-flasher}; do
		# Use sysconfdir so it won't conflict with resin-mounts units
		# This was fixed in later yocto versions were sysroot is per recipe
		install -m 0644 $service ${D}${sysconfdir}/systemd/system/
	done
}
