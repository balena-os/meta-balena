SUMMARY = "Resin systemd mount services"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://mnt-boot.mount \
    file://mnt-state.mount \
    file://mnt-data.mount \
    file://etc-docker.mount \
    file://etc-dropbear.mount \
    file://etc-systemd-system-resin.target.wants.mount \
    file://etc-systemd-timesyncd.conf.mount \
    file://etc-hostname.mount \
    file://etc-resinx2dsupervisor.mount \
    file://etc-NetworkManager-systemx2dconnections.mount \
    file://var-lib-systemd.mount \
    file://var-log-journal.mount \
    file://home-root-.rnd.mount \
    file://home-root-.docker.mount \
    file://resin-bind.target \
    "

S = "${WORKDIR}"

inherit systemd allarch

PACKAGES = "${PN}"

SYSTEMD_SERVICE_${PN} = " \
    mnt-boot.mount \
    mnt-state.mount \
    mnt-data.mount \
    etc-docker.mount \
    etc-dropbear.mount \
    etc-systemd-system-resin.target.wants.mount \
    etc-systemd-timesyncd.conf.mount \
    etc-hostname.mount \
    var-lib-systemd.mount \
    var-log-journal.mount \
    home-root-.rnd.mount \
    home-root-.docker.mount \
    "

FILES_${PN} += " \
    /mnt/data \
    /mnt/state \
    /mnt/boot \
    ${systemd_unitdir} \
    ${sysconfdir} \
    "

do_install () {
    install -d ${D}/mnt/state
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
            ${WORKDIR}/mnt-state.mount \
            ${WORKDIR}/mnt-data.mount \
            ${WORKDIR}/etc-docker.mount \
            ${WORKDIR}/etc-dropbear.mount \
            ${WORKDIR}/etc-hostname.mount \
            ${WORKDIR}/etc-systemd-system-resin.target.wants.mount \
            ${WORKDIR}/etc-systemd-timesyncd.conf.mount \
            ${WORKDIR}/var-lib-systemd.mount \
            ${WORKDIR}/var-log-journal.mount \
            ${WORKDIR}/home-root-.rnd.mount \
            ${WORKDIR}/home-root-.docker.mount \
            ${D}${systemd_unitdir}/system

        # Yocto gets confused if we use strange file names - so we rename it here
        # https://bugzilla.yoctoproject.org/show_bug.cgi?id=8161
        install -c -m 0644 ${WORKDIR}/etc-NetworkManager-systemx2dconnections.mount ${D}${systemd_unitdir}/system/etc-NetworkManager-system\\x2dconnections.mount
        install -c -m 0644 ${WORKDIR}/etc-resinx2dsupervisor.mount ${D}${systemd_unitdir}/system/etc-resin\\x2dsupervisor.mount

        ln -sf ${systemd_unitdir}/system/etc-resin\\x2dsupervisor.mount ${D}${sysconfdir}/systemd/system/resin-bind.target.wants
        ln -sf ${systemd_unitdir}/system/etc-NetworkManager-system\\x2dconnections.mount ${D}${sysconfdir}/systemd/system/resin-bind.target.wants
    fi
}
