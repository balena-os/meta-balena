DESCRIPTION = "Balena Configuration Recipe"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://balena-config-vars \
    file://balena-config-defaults \
    file://config-json.path \
    file://config-json.service \
    file://os-networkmanager \
    file://os-networkmanager.service \
    file://os-udevrules \
    file://os-udevrules.service \
    file://os-sshkeys \
    file://os-sshkeys.service \
    "
S = "${WORKDIR}"

inherit allarch systemd

FILES:${PN} = "${sbindir}"

SYSTEMD_UNIT_NAMES = "os-sshkeys os-udevrules os-networkmanager"
inherit balena-configurable

DEPENDS = "bash-native jq-native coreutils-native"
RDEPENDS:${PN} = "bash udev coreutils fatrw"
PACKAGES =+ "${PN}-config"
RDEPENDS:${PN}-config = "jq"
RDEPENDS:${PN}-config:append = "${@oe.utils.conditional('SIGN_API','','',' os-helpers-sb',d)}"
RDEPENDS:${PN} += " ${PN}-config"

do_patch[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

SYSTEMD_SERVICE:${PN} = " \
    config-json.path \
    config-json.service \
    os-networkmanager.service \
    os-udevrules.service \
    os-sshkeys.service \
    "

do_install() {
    root_bindmount_name=$(echo "${ROOT_HOME}" | sed 's|/|-|g')
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/balena-config-vars ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/balena-config-defaults ${D}${sbindir}/
    sed -i -e 's:@@BALENA_NONENC_BOOT_MOUNT@@:${BALENA_NONENC_BOOT_MOUNT}:g' ${D}${sbindir}/balena-config-defaults
    sed -i -e 's:@@BALENA_NONENC_BOOT_LABEL@@:${BALENA_NONENC_BOOT_LABEL}:g' ${D}${sbindir}/balena-config-defaults
    sed -i -e 's:@@BALENA_BOOT_MOUNT@@:${BALENA_BOOT_MOUNT}:g' ${D}${sbindir}/balena-config-defaults
    sed -i -e 's:@@BALENA_BOOT_LABEL@@:${BALENA_BOOT_LABEL}:g' ${D}${sbindir}/balena-config-defaults
    install -m 0755 ${WORKDIR}/os-networkmanager ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/os-udevrules ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/os-sshkeys ${D}${sbindir}/
    sed -i -e "s,@ROOT_HOME@,${ROOT_HOME},g" ${D}${sbindir}/os-sshkeys

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/config-json.path ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/config-json.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/os-networkmanager.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/os-udevrules.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/os-sshkeys.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            -e "s,@ROOT_HOME@,${root_bindmount_name},g" \
            ${D}${systemd_unitdir}/system/*.service
    fi
}

FILES:${PN}-config = "${sbindir}/balena-config-vars ${sbindir}/balena-config-defaults"
