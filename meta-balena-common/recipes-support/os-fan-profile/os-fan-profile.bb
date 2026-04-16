DESCRIPTION = "Runtime OS fan profile management"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://os-fan-profile \
    file://os-fan-profile.service \
    "

S_UNPACK = "${@d.getVar('UNPACKDIR') or d.getVar('WORKDIR')}"
S = "${S_UNPACK}"

RDEPENDS:${PN} += "balena-config-vars bash"

inherit allarch systemd balena-configurable

SYSTEMD_SERVICE:${PN} = " \
    os-fan-profile.service \
    "

do_patch[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

do_install() {
    install -d ${D}${bindir}/
    install -m 0755 ${S_UNPACK}/os-fan-profile ${D}${bindir}/

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system/
        install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants/
        install -m 0644 ${S_UNPACK}/os-fan-profile.service ${D}${systemd_unitdir}/system/

        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}
