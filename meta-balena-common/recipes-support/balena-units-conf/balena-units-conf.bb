DESCRIPTION = "Balena unit configuration files"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
DEPENDS = "bash-native jq-native os-helpers-native coreutils-native"
RDEPENDS:${PN} = "bash jq coreutils os-helpers-config"

SRC_URI = " \
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
    file://os-config-json \
    file://generate_configuration_unit \
"

S = "${WORKDIR}"

inherit allarch

do_patch[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

FILES:${PN} = " \
    ${sbindir} \
    ${sysconfdir}/systemd \
    "

do_test() {
    JQ="${STAGING_BINDIR_NATIVE}/jq"
    # Test parsing into configuration units
    JQ="${JQ}" \
    CONF_DIR=${WORKDIR}/tmp \
    CONFIG_PATH=${WORKDIR}/test-input.json \
    CACHED_CONFIG_PATH=${WORKDIR}/tmp/test-cache.json \
    UNITS_DIR=${WORKDIR}/tmp\
    STAGING_DIR=${STAGING_DIR_NATIVE} \
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
    CONF_DIR=${WORKDIR}/tmp \
    CONFIG_PATH=${WORKDIR}/${tmpfile} \
    CACHED_CONFIG_PATH=${WORKDIR}/tmp/test-cache.json \
    UNITS_DIR=${WORKDIR}/tmp\
    STAGING_DIR=${STAGING_DIR_NATIVE} \
    /bin/sh "${WORKDIR}/os-config-json"
    cksum1=$(md5sum "${WORKDIR}/tmp/unit5.json" | cut -d " " -f1)
    cksum2=$(md5sum "${WORKDIR}/test-output7.json" | cut -d " " -f1)
    if [ "${cksum1}" != "${cksum2}" ]; then
        bbfatal "os-config-json: Unexpected output"
    fi

    # Test removal of value from configuration unit
    "${JQ}" 'del(.key_object.one)' "${WORKDIR}/test-input.json" > "${WORKDIR}/${tmpfile}"
    JQ="${JQ}" \
    CONF_DIR=${WORKDIR}/tmp \
    CONFIG_PATH=${WORKDIR}/${tmpfile} \
    CACHED_CONFIG_PATH=${WORKDIR}/tmp/test-cache.json \
    UNITS_DIR=${WORKDIR}/tmp\
    STAGING_DIR=${STAGING_DIR_NATIVE} \
    /bin/sh "${WORKDIR}/os-config-json"
    cksum1=$(md5sum "${WORKDIR}/tmp/unit1.json" | cut -d " " -f1)
    cksum2=$(md5sum "${WORKDIR}/test-output6.json" | cut -d " " -f1)
    if [ "${cksum1}" != "${cksum2}" ]; then
        bbfatal "os-config-json: Unexpected output"
    fi

    # Test removal of all values from configuration unit
    "${JQ}" 'del(.key_nested.key_nested_child2_nested.key_child2_nested."0") | del(.key_object.one)' "${WORKDIR}/test-input.json" > "${WORKDIR}/${tmpfile}"
    JQ="${JQ}" \
    CONF_DIR=${WORKDIR}/tmp \
    CONFIG_PATH=${WORKDIR}/${tmpfile} \
    CACHED_CONFIG_PATH=${WORKDIR}/tmp/test-cache.json \
    UNITS_DIR=${WORKDIR}/tmp\
    STAGING_DIR=${STAGING_DIR_NATIVE} \
    /bin/sh "${WORKDIR}/os-config-json"
    if [ -f "${WORKDIR}/tmp/unit1.json" ]; then
        bbfatal "os-config-json: Unexpected output"
    fi
    rm -f "${tmpfile}"
}
addtask test before do_package after do_install
do_test[depends] += "jq-native:do_populate_sysroot os-helpers-native:do_populate_sysroot"

parse_conf_to_units() {
    units_file="${1}"
    units_path="${2}"
    jq -r '.properties.units.properties | keys[]' "${units_file}" > ${units_path}/units.conf
    for unit in $(cat "${units_path}/units.conf"); do
        jq -r ".properties.units.properties | .[\"${unit}\"].configuration" "${units_file}" > ${units_path}/${unit}-conf.conf
    done
}

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/os-config-json ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/generate_configuration_unit ${D}${sbindir}/
    install -d ${D}${sysconfdir}/systemd
    install -d ${WORKDIR}/tmp
    install -c -m 0644 ${WORKDIR}/unit-conf.json ${STAGING_DIR_TARGET}
    parse_conf_to_units "${WORKDIR}/unit-conf.json" "${D}/${sysconfdir}/systemd"
    parse_conf_to_units "${WORKDIR}/test-conf.json" "${WORKDIR}/tmp"
}
