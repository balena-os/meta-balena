DESCRIPTION = "Helpers for OS scripts"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS = "time-native"
RDEPENDS:${PN}-fs = "e2fsprogs-tune2fs mtools parted bash util-linux-fdisk btrfs-tools"
RDEPENDS:${PN}-fs:append = "${@bb.utils.contains('MACHINE_FEATURES','raid',' mdadm','',d)}"
RDEPENDS:${PN}-tpm2 = "libtss2-tcti-device tpm2-tools"
RDEPENDS:${PN}-config = "bash"
RDEPENDS:${PN}-api = "curl"

SRC_URI = " \
    file://os-helpers-fs \
    file://os-helpers-logging \
    file://os-helpers-time \
    file://os-helpers-tpm2 \
    file://os-helpers-config \
    file://os-helpers-api \
"
S = "${WORKDIR}"

inherit allarch

PACKAGES = "${PN}-fs ${PN}-logging ${PN}-time ${PN}-tpm2 ${PN}-config ${PN}-api"

do_install() {
    install -d ${D}${libexecdir}
    install -m 0775 \
        ${WORKDIR}/os-helpers-fs \
        ${WORKDIR}/os-helpers-logging \
        ${WORKDIR}/os-helpers-time \
        ${WORKDIR}/os-helpers-tpm2 \
        ${WORKDIR}/os-helpers-config \
        ${WORKDIR}/os-helpers-api \
        ${D}${libexecdir}
        sed -i "s,@@BALENA_CONF_UNIT_STORE@@,${BALENA_CONF_UNIT_STORE},g" ${D}${libexecdir}/os-helpers-config
}

FILES:${PN}-fs = "${libexecdir}/os-helpers-fs"
FILES:${PN}-logging = "${libexecdir}/os-helpers-logging"
FILES:${PN}-time = "${libexecdir}/os-helpers-time"
FILES:${PN}-tpm2 = "${libexecdir}/os-helpers-tpm2"
FILES:${PN}-config = "${libexecdir}/os-helpers-config"
FILES:${PN}-api = "${libexecdir}/os-helpers-api"

do_test_api() {
    if [ "${BB_NO_NETWORK}" = "1" ]; then
        bbnote "${PN}: Skipping test as bitbake is configured for no network"
        return 0
    fi
    endpoint="https://api.${BALENA_API_ENV}"
    export CURL_CA_BUNDLE="${STAGING_DIR_NATIVE}/etc/ssl/certs/ca-certificates.crt"
    . ${WORKDIR}/os-helpers-api
    # GET 200
    if ! api_get_request "${endpoint}/ping"; then
        bberror "${PN}: API request failed "
    fi
    # 404 Not found
    if api_get_request "${endpoint}/notfound"; then
        bberror "API request unexpectedly suceeded"
    fi
    # 401 Unauthorized
    if api_get_request "${endpoint}/v6/device"; then
        bberror "API request unexpectedly suceeded"
    fi
}
addtask test_api before do_package after do_install
do_test_api[network] = "1"
do_test[depends] += "curl-native:do_populate_sysroot os-helpers-native:do_populate_sysroot ca-certificates-native:do_populate_sysroot"

BBCLASSEXTEND = "native"
