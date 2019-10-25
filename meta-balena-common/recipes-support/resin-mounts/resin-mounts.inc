LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI += "file://bind-path.service.in"

S = "${WORKDIR}"

inherit systemd allarch

SYSTEMD_SERVICE_${PN} += "${@bindmounts_systemd_services(d)}"

FILES_${PN} += " \
	${sysconfdir} \
	${systemd_unitdir} \
	/home/root/.ssh \
	"

BINDMOUNTS += " \
	${sysconfdir}/ssh/hostkeys \
	/etc/hostname \
	/etc/openvpn \
	/etc/NetworkManager/conf.d \
	/etc/NetworkManager/system-connections \
	/etc/udev/rules.d \
	/home/root/.rnd \
	/var/lib/bluetooth \
	/var/lib/NetworkManager \
	/home/root/.ssh \
	"

PACKAGES = "${PN}"

RDEPENDS_${PN} += "util-linux bindmount"

def bindmounts_systemd_services(d):
    services = []
    for bindmount in d.getVar("BINDMOUNTS", True).split():
        services.append("bind-%s.service" % bindmount[1:].replace("/", "-"))
    return " ".join(services)

do_compile () {
	for bindmount in ${BINDMOUNTS}; do
		servicefile="bind$(echo "$bindmount" | tr / -).service"
		sed -e "s#@target@#$bindmount#g" bind-path.service.in > "$servicefile"

		# Service specific changes
		if [ "$bindmount" = "/var/lib/systemd" ]; then
			# Systemd services need to write to /var/lib/systemd so make sure
			# that is mounted.
			sed -i -e "/^Before=/s/\$/ systemd-random-seed.service systemd-rfkill.service/" \
			-e "/^WantedBy=/s/\$/ systemd-random-seed.service systemd-rfkill.service/" \
			"$servicefile"
		elif [ "$bindmount" = "/var/log/journal" ]; then
			# This bind mount is only invoked manually in persistent logs
			# service. No need to run it with default target.
			sed -i -e "/^WantedBy=/ d" "$servicefile"
			# Mount persistent logs on data partition
			sed -i -e 's/resin-state.service resin-state-reset.service/resin-data.service/g' "$servicefile"
			sed -i -e 's#/mnt/state#/mnt/data#g' "$servicefile"
		elif [ "$bindmount" = "/etc/NetworkManager/conf.d" ]; then
			# This bind mount needs to be running before the NetworkManager service starts for os-networkmanager
			sed -i -e "/^Before=/s/\$/ NetworkManager.service/" "$servicefile"
		elif [ "$bindmount" = "/etc/udev/rules.d" ]; then
			# This bind mount needs to be running before the udev service starts for os-udevrules
			sed -i -e "/^Before=/s/\$/ systemd-udevd.service/" "$servicefile"
		fi
	done
}
do_compile[dirs] = "${WORKDIR}"

do_install () {
	install -d "${D}${sysconfdir}"
	touch "${D}/${sysconfdir}/hostname"
	install -d "${D}${sysconfdir}/openvpn"
	install -d "${D}/home/root/.ssh"
	install -d "${D}/${sysconfdir}/ssh/hostkeys"
}
