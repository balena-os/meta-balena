SUMMARY = "Resin device unique key generator"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://resin-unique-key \
    file://resin-device-uuid.service \
    file://resin-device-api-key.service \
    "
S = "${WORKDIR}"

inherit allarch systemd

RDEPENDS_${PN} = " \
    bash \
    jq \
    resin-vars \
    openssl \
    "

SYSTEMD_SERVICE_${PN} = "resin-device-uuid.service resin-device-api-key.service"

FILES_${PN} += "/home/root/.rnd"

do_install() {
    # Create an initial file where openssl will save its state
    # We will bind mount here a location in resin-state partition to make it rw
    mkdir -p ${D}/home/root/
    touch ${D}/home/root/.rnd
    chmod 0600 ${D}/home/root/.rnd

    install -d ${D}${bindir}
    install -m 0775 ${WORKDIR}/resin-unique-key ${D}${bindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/resin-device-uuid.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/resin-device-api-key.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}
