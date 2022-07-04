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
    file://os-config-json \
    file://os-config-json.service \
    file://unit-conf.json \
    file://test-input.json \
    file://test-conf.json \
    file://test-output1.json \
    file://test-output2.json \
    file://test-output3.json \
    file://test-output4.json \
    file://test-output5.json \
    file://test-output6.json \
    file://test-output7.json \
    "
S = "${WORKDIR}"

inherit allarch systemd

FILES:${PN} = "${sbindir} ${sysconfdir}/systemd/unit-conf.json"

SYSTEMD_UNIT_NAMES = "os-sshkeys os-udevrules os-networkmanager"
inherit balena-configurable

DEPENDS = "bash-native jq-native coreutils-native"
RDEPENDS:${PN} = "bash jq udev coreutils os-helpers-devmode"

do_patch[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

SYSTEMD_SERVICE:${PN} = " \
    config-json.path \
    config-json.service \
    os-networkmanager.service \
    os-udevrules.service \
    os-sshkeys.service \
    os-config-json.service \
    "

do_test() {
    JQ="${STAGING_BINDIR_NATIVE}/jq"
    # Test parsing into configuration units
    JQ="${JQ}" \
    CONF_TMPDIR=${WORKDIR}/tmp \
    CONFIG_PATH=${WORKDIR}/test-input.json \
    UNIT_CONF_PATH=${WORKDIR}/test-conf.json \
    /bin/sh "${WORKDIR}/os-config-json"
    for i in 1 2 3 4 5; do
        if [ -f "${WORKDIR}/tmp/unit$i.json" ]; then
            cksum1=$(md5sum "${WORKDIR}/tmp/unit$i.json" | cut -d " " -f1)
            cksum2=$(md5sum "${WORKDIR}/test-output$i.json" | cut -d " " -f1)
            if [ "${cksum1}" != "${cksum2}" ]; then
                bbfatal "os-config-json: Unexpected output"
            fi
        else
            bbfatal "os-config-json: No output"
        fi
    done

    # Test modification of unit configuration
    tmpfile=$(mktemp)
    "${JQ}" '.key_integer=10' "${WORKDIR}/test-input.json" > "${WORKDIR}/${tmpfile}"
    JQ="${JQ}" \
    CONF_TMPDIR=${WORKDIR}/tmp \
    CONFIG_PATH=${WORKDIR}/${tmpfile} \
    UNIT_CONF_PATH=${WORKDIR}/test-conf.json \
    /bin/sh "${WORKDIR}/os-config-json"
    cksum1=$(md5sum "${WORKDIR}/tmp/unit5.json" | cut -d " " -f1)
    cksum2=$(md5sum "${WORKDIR}/test-output7.json" | cut -d " " -f1)
    if [ "${cksum1}" != "${cksum2}" ]; then
        bbfatal "os-config-json: Unexpected output"
    fi

    # Test removal of value from configuration unit
    "${JQ}" 'del(.key_object.one)' "${WORKDIR}/test-input.json" > "${WORKDIR}/${tmpfile}"
    JQ="${JQ}" \
    CONF_TMPDIR=${WORKDIR}/tmp \
    CONFIG_PATH=${WORKDIR}/${tmpfile} \
    UNIT_CONF_PATH=${WORKDIR}/test-conf.json \
    /bin/sh "${WORKDIR}/os-config-json"
    cksum1=$(md5sum "${WORKDIR}/tmp/unit1.json" | cut -d " " -f1)
    cksum2=$(md5sum "${WORKDIR}/test-output6.json" | cut -d " " -f1)
    if [ "${cksum1}" != "${cksum2}" ]; then
        bbfatal "os-config-json: Unexpected output"
    fi

    # Test removal of all values from configuration unit
    "${JQ}" 'del(.key_nested.key_nested_child2_nested.key_child2_nested."0") | del(.key_object.one)' "${WORKDIR}/test-input.json" > "${WORKDIR}/${tmpfile}"
    JQ="${JQ}" \
    CONF_TMPDIR=${WORKDIR}/tmp \
    CONFIG_PATH=${WORKDIR}/${tmpfile} \
    UNIT_CONF_PATH=${WORKDIR}/test-conf.json \
    /bin/sh "${WORKDIR}/os-config-json"
    if [ -f "${WORKDIR}/tmp/unit1.json" ]; then
        bbfatal "os-config-json: Unexpected output"
    fi
    rm -f "${tmpfile}"
}
addtask test before do_package after do_install
do_test[depends] += "jq-native:do_populate_sysroot"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/balena-config-vars ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/balena-config-defaults ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/os-networkmanager ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/os-udevrules ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/os-sshkeys ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/os-config-json ${D}${sbindir}/

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/config-json.path ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/config-json.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/os-networkmanager.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/os-udevrules.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/os-sshkeys.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/os-config-json.service ${D}${systemd_unitdir}/system
        install -d ${D}${sysconfdir}/systemd
        install -c -m 0644 ${WORKDIR}/unit-conf.json ${D}/${sysconfdir}/systemd
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}
