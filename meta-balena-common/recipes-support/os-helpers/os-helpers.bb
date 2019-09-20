DESCRIPTION = "Helpers for OS scripts"
SECTION = "console/utils"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS = "time-native"

SRC_URI = " \
    file://os-helpers-fs \
    file://os-helpers-logging \
    file://test-cmdline-1 \
    file://test-cmdline-2 \
    file://test-cmdline-3 \
    file://test-cmdline-4 \
"
S = "${WORKDIR}"

inherit allarch recipe-tests

PACKAGES = "${PN}-fs ${PN}-logging"

do_runtests_append() {
    . ${D}${libexecdir}/os-helpers-fs

    runtest "wait4file ${D}/nonexistent 10" "1" ""
    runtest "wait4file ${D}${libexecdir}/os-helpers-fs 10" "0" ""
    runtest "get_fs_param resin-boot" "0" "uuid_boot"
    runtest "get_fs_param resin-rootA" "0" "uuid_roota"
    runtest "get_fs_param resin-rootB" "0" "uuid_rootb"
    runtest "get_fs_param resin-state" "0" "uuid_state"
    runtest "get_fs_param resin-data" "0" "uuid_data"
    runtest "get_fs_param nosuchlabel" "1" ""

    # cmdline1 has no arguments
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-1 get_cmdline_uuid resin-boot" "1" ""
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-1 get_cmdline_uuid resin-rootA" "1" ""
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-1 get_cmdline_uuid resin-rootB" "1" ""
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-1 get_cmdline_uuid resin-state" "1" ""
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-1 get_cmdline_uuid resin-data" "1" ""

    # cmdline2 has no interesting arguments
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-2 get_cmdline_uuid resin-boot" "1" ""
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-2 get_cmdline_uuid resin-rootA" "1" ""
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-2 get_cmdline_uuid resin-rootB" "1" ""
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-2 get_cmdline_uuid resin-state" "1" ""
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-2 get_cmdline_uuid resin-data" "1" ""

    # cmdline3 has all uuids but the one for the data partition
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-3 get_cmdline_uuid resin-boot" "0" "u1"
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-3 get_cmdline_uuid resin-rootA" "0" "u2"
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-3 get_cmdline_uuid resin-rootB" "0" "u3"
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-3 get_cmdline_uuid resin-state" "0" "u4"
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-3 get_cmdline_uuid resin-data" "1" ""

    # cmdline4 has all the uuids in place
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-4 get_cmdline_uuid resin-boot" "0" "u1"
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-4 get_cmdline_uuid resin-rootA" "0" "u2"
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-4 get_cmdline_uuid resin-rootB" "0" "u3"
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-4 get_cmdline_uuid resin-state" "0" "u4"
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-4 get_cmdline_uuid resin-data" "0" "u5"

    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-3 get_cmdline_uuid_label resin-data" "0" "resin-data"
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-3 get_cmdline_uuid_label resin-boot" "0" "u1"

    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-3 get_cmdline_uuid_label_path resin-data" "0" "/dev/disk/by-label/resin-data"
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-3 get_cmdline_uuid_label_path resin-boot" "0" "/dev/disk/by-uuid/u1"

    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-3 check_cmdline_uuids" "1" ""
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-4 check_cmdline_uuids" "0" ""

    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-4 check_cmdline_uuid u1" "0" ""
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-4 check_cmdline_uuid u2" "0" ""
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-4 check_cmdline_uuid non" "1" ""
    runtest "HELPER_CMDLINE=${WORKDIR}/test-cmdline-4 check_cmdline_uuid" "1" ""
}

do_install() {
    install -d ${D}${libexecdir}
    install -m 0775 \
        ${WORKDIR}/os-helpers-fs \
        ${WORKDIR}/os-helpers-logging \
        ${D}${libexecdir}
}

FILES_${PN}-fs = "${libexecdir}/os-helpers-fs"
FILES_${PN}-logging = "${libexecdir}/os-helpers-logging"
