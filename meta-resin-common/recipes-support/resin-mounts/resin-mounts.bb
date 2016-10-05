SUMMARY = "Resin systemd mount services"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://mnt-boot.mount \
    file://mnt-conf.mount \
    file://mnt-data.mount \
    file://etc-docker.mount \
    file://etc-dropbear.mount \
    file://etc-systemd-system-resin.target.wants.mount \
    file://etc-hostname.mount \
    file://etc-supervisor.conf.mount \
    file://resin-bind.target \
    "

S = "${WORKDIR}"

inherit systemd allarch

PACKAGES = "${PN}"

SYSTEMD_SERVICE_${PN} = " \
    mnt-boot.mount \
    mnt-conf.mount \
    mnt-data.mount \
    etc-docker.mount \
    etc-dropbear.mount \
    etc-systemd-system-resin.target.wants.mount \
    etc-hostname.mount \
    etc-supervisor.conf.mount \
    "

FILES_${PN} += " \
    /mnt/data \
    /mnt/conf \
    /mnt/boot \
    ${systemd_unitdir} \
    ${sysconfdir} \
    "

do_install () {
    install -d ${D}/mnt/conf
    install -d ${D}/mnt/data
    install -d ${D}/mnt/boot
    install -d ${D}/etc/docker

    install -d ${D}${systemd_unitdir}/system

    # Install our custom resin bind target
    install -d ${D}${systemd_unitdir}/system/resin-bind.target.wants
    install -d ${D}${sysconfdir}/systemd/system/resin-bind.target.wants
    install -c -m 0644 ${WORKDIR}/resin-bind.target ${D}${systemd_unitdir}/system/


    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 \
            ${WORKDIR}/mnt-boot.mount \
            ${WORKDIR}/mnt-conf.mount \
            ${WORKDIR}/mnt-data.mount \
            ${WORKDIR}/etc-docker.mount \
            ${WORKDIR}/etc-dropbear.mount \
            ${WORKDIR}/etc-hostname.mount \
            ${WORKDIR}/etc-supervisor.conf.mount \
            ${WORKDIR}/etc-systemd-system-resin.target.wants.mount \
            ${D}${systemd_unitdir}/system
    fi
}
