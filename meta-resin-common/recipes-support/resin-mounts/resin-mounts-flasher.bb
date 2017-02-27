SUMMARY = "Resin flasher systemd mount services"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://mnt-boot.mount \
    file://mnt-bootorig-config.json.mount \
    file://temp-conf.service \
    file://mnt-bootorig.mount \
    file://etc-NetworkManager-systemx2dconnections.mount \
    file://etc-hostname.mount \
    file://home-root-.rnd.mount \
    file://etc-dropbear.mount \
    file://01-resin-binds-tmp.conf \
    "

S = "${WORKDIR}"

inherit systemd allarch

PACKAGES = "${PN}"

SYSTEMD_SERVICE_${PN} = " \
    mnt-boot.mount \
    mnt-bootorig-config.json.mount \
    temp-conf.service \
    mnt-bootorig.mount \
    etc-hostname.mount \
    home-root-.rnd.mount \
    etc-dropbear.mount \
    "

FILES_${PN} += " \
    /mnt/state \
    /mnt/boot \
    /mnt/bootorig \
    ${sysconfdir}/tmpfiles.d/ \
    "

do_install () {
    install -d ${D}/mnt/state
    install -d ${D}/mnt/boot
    install -d ${D}/mnt/bootorig
    install -d ${D}${sysconfdir}/tmpfiles.d

    # We need temporary location for our bind moounts
    install -m 0644 ${WORKDIR}/01-resin-binds-tmp.conf ${D}${sysconfdir}/tmpfiles.d/

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system
        install -c -m 0644 \
            ${WORKDIR}/mnt-boot.mount \
            ${WORKDIR}/mnt-bootorig-config.json.mount \
            ${WORKDIR}/temp-conf.service \
            ${WORKDIR}/mnt-bootorig.mount \
            ${WORKDIR}/etc-hostname.mount \
            ${WORKDIR}/home-root-.rnd.mount \
            ${WORKDIR}/etc-dropbear.mount \
            ${D}${sysconfdir}/systemd/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${sysconfdir}/systemd/system/*

        # Yocto gets confused if we use strange file names - so we rename it here
        # https://bugzilla.yoctoproject.org/show_bug.cgi?id=8161
        install -c -m 0644 ${WORKDIR}/etc-NetworkManager-systemx2dconnections.mount ${D}${sysconfdir}/systemd/system/etc-NetworkManager-system\\x2dconnections.mount
    fi
}
