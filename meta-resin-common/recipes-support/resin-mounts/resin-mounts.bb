SUMMARY = "Resin systemd mount services"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://resin-boot.service \
    file://resin-data.service \
    file://resin-state.service \
    file://mnt-sysroot-active.mount \
    file://mnt-sysroot-inactive.mount \
    file://resin-partition-mounter \
    file://bind-path.service.in \
    "

S = "${WORKDIR}"

inherit systemd allarch

PACKAGES = "${PN}"

SYSTEMD_SERVICE_${PN} = " \
    resin-boot.service \
    resin-data.service \
    resin-state.service \
    mnt-sysroot-active.mount \
    mnt-sysroot-inactive.mount \
    ${@bindmounts_systemd_services(d)} \
    "

FILES_${PN} += " \
    /mnt/boot \
    /mnt/data \
    /mnt/state \
    /mnt/sysroot/active \
    /mnt/sysroot/inactive \
    ${sysconfdir} \
    ${systemd_unitdir} \
    "

RDEPENDS_${PN} += "util-linux bindmount"

BINDMOUNTS ?= " \
    /etc/docker \
    /etc/dropbear \
    /etc/hostname \
    /etc/resin-supervisor \
    /etc/systemd/system/resin.target.wants \
    /etc/systemd/timesyncd.conf \
    /etc/NetworkManager/system-connections \
    /home/root/.docker \
    /home/root/.rnd \
    /var/log/journal \
    /var/lib/systemd \
"

def bindmounts_systemd_services(d):
    services = []
    for bindmount in d.getVar("BINDMOUNTS", True).split():
        services.append("bind-%s.service" % bindmount[1:].replace("/", "-"))
    return " ".join(services)

do_compile () {
    for bindmount in ${BINDMOUNTS}; do
        servicefile="bind-${bindmount#/}"
        servicefile="$(echo "$servicefile" | tr / -).service"
        sed -e "s#@target@#$bindmount#g" bind-path.service.in > $servicefile

        # Service specific changes
        if [ "$bindmount" = "/var/lib/systemd" ]; then
            # Systemd services need to write to /var/lib/systemd so make sure
            # that is mounted.
            sed -i -e "/^Before=/s/\$/ systemd-random-seed.service systemd-rfkill.service systemd-timesyncd/" \
                   -e "/^WantedBy=/s/\$/ systemd-random-seed.service systemd-rfkill.service systemd-timesyncd/" \
                   $servicefile
        elif [ "$bindmount" = "/var/log/journal" ]; then
            # This bind mount is only invoked manually in persistent logs
            # service. No need to run it with default target.
            sed -i -e "/^WantedBy=/ d" $servicefile
        fi
    done
}
do_compile[dirs] = "${WORKDIR}"

do_install () {
    # These are mountpoints for various mount services/units
    install -d ${D}/etc/docker
    ln -sf docker ${D}/etc/balena
    install -d ${D}/mnt/boot
    install -d ${D}/mnt/data
    install -d ${D}/mnt/state
    install -d ${D}/mnt/sysroot/active
    install -d ${D}/mnt/sysroot/inactive
    touch ${D}/${sysconfdir}/hostname

    install -d ${D}${bindir}
    install -m 755 ${WORKDIR}/resin-partition-mounter ${D}${bindir}

    install -d ${D}${systemd_unitdir}/system
    for service in ${SYSTEMD_SERVICE_resin-mounts}; do
        install -m 0644 $service ${D}${systemd_unitdir}/system/
    done
}
