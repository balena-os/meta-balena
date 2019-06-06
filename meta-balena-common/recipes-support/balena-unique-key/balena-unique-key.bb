SUMMARY = "Balena device unique key generator"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://balena-unique-key \
    file://balena-device-uuid.service \
    "
S = "${WORKDIR}"

inherit allarch systemd

# Since yocto thud openssl binary is provided by openssl-bin but use weak
# assignment so older yocto versions can overwrite this to the old openssl
# package
OPENSSL_PKG ?= "openssl-bin"

RDEPENDS_${PN} = " \
    bash \
    jq \
    resin-vars \
    ${OPENSSL_PKG} \
    "

SYSTEMD_SERVICE_${PN} = "balena-device-uuid.service"

FILES_${PN} += "/home/root/.rnd"

do_install() {
    # Create an initial file where openssl will save its state
    # We will bind mount here a location in resin-state partition to make it rw
    mkdir -p ${D}/home/root/
    touch ${D}/home/root/.rnd
    chmod 0600 ${D}/home/root/.rnd

    install -d ${D}${bindir}
    install -m 0775 ${WORKDIR}/balena-unique-key ${D}${bindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/balena-device-uuid.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}
