FILESEXTRAPATHS:append := ":${THISDIR}/${PN}"

inherit balena-firmware-list-tools
inherit balena-linux-firmware

SRC_URI:append = " \
    file://extra_WHENCE \
"

# Cleanup iwlwifi firmware files
IWLWIFI_PATH = "${D}${nonarch_base_libdir}/firmware"
IWLWIFI_REGEX = "^iwlwifi-([0-9a-zA-Z-]+)-([0-9]+).ucode$"
IWLWIFI_FW_TOCLEAN ?= " \
    7260 \
    7265 \
    7265D \
    8000C \
    8265 \
    9260-th-b0-jf-b0 \
"
IWLWIFI_FW_MIN_API[7260] = "17"
IWLWIFI_FW_MIN_API[7265] = "17"
IWLWIFI_FW_MIN_API[7265D] = "29"
IWLWIFI_FW_MIN_API[8000C] = "36"
IWLWIFI_FW_MIN_API[8265] = "36"
IWLWIFI_FW_MIN_API[9260-th-b0-jf-b0] = "46"

PACKAGES =+ "${PN}-rtl8188eu"

FILES:${PN}-rtl8188eu = " \
    ${nonarch_base_libdir}/firmware/rtlwifi/rtl8188eu*.bin* \
    "

PACKAGES =+ "${PN}-iwlwifi-qu-b0-hr-b0"

FILES:${PN}-iwlwifi-qu-b0-hr-b0 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-Qu-b0-hr-b0-* \
    "

PACKAGES =+ "${PN}-ibt-19-0-4"

FILES:${PN}-ibt-19-0-4  = " \
    ${nonarch_base_libdir}/firmware/intel/ibt-19-0-4.doc* \
    ${nonarch_base_libdir}/firmware/intel/ibt-19-0-4.sfi* \
    "

PACKAGES =+ "${PN}-ath10k-qca6174"

FILES:${PN}-ath10k-qca6174 = " \
    ${nonarch_base_libdir}/firmware/ath10k/QCA6174/* \
"

PACKAGES =+ "${PN}-rtl8723b-bt"

FILES:${PN}-rtl8723b-bt = " \
    ${nonarch_base_libdir}/firmware/rtl_bt/rtl8723b_fw.bin* \
"

PACKAGES =+ "${PN}-iwlwifi-3168"

FILES:${PN}-iwlwifi-3168 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-3168-* \
"

PACKAGES =+ "${PN}-ibt-18-16-1"

FILES:${PN}-ibt-18-16-1  = " \
    ${nonarch_base_libdir}/firmware/intel/ibt-18-16-1.sfi* \
    ${nonarch_base_libdir}/firmware/intel/ibt-18-16-1.ddc* \
"

PACKAGES =+ "${PN}-ibt-41-41"

FILES:${PN}-ibt-41-41  = " \
    ${nonarch_base_libdir}/firmware/intel/ibt-0041-0041.ddc* \
    ${nonarch_base_libdir}/firmware/intel/ibt-0041-0041.sfi* \
"

LICENSE:${PN}-ibt-41-41 = "Firmware-ibt_firmware"
RDEPENDS:${PN}-ibt-41-41 = "${PN}-ibt-license"

PACKAGES =+ "${PN}-ralink-nic"

FILES:${PN}-ralink-nic = " \
    ${nonarch_base_libdir}/firmware/rtl_nic/rtl8168g-2.fw* \
"

PACKAGES =+ "${PN}-iwlwifi-3160"

FILES:${PN}-iwlwifi-3160 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-3160-17.ucode* \
"
RDEPENDS:${PN}-iwlwifi-3160   = "${PN}-iwlwifi-license"
LICENSE:${PN}-iwlwifi-3160    = "Firmware-iwlwifi_firmware"

PACKAGES =+ "${PN}-iwlwifi-cc-a0"

FILES:${PN}-iwlwifi-cc-a0 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-cc-a0-*.ucode* \
"

PACKAGES =+ "${PN}-iwlwifi-ty-a0"

FILES:${PN}-iwlwifi-ty-a0  = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-ty-a0-*.ucode* \
    ${nonarch_base_libdir}/firmware/iwlwifi-ty-a0-*.pnvm* \
"

LICENSE:${PN}-iwlwifi-ty-a0 = "Firmware-iwlwifi_firmware"
RDEPENDS:${PN}-iwlwifi-ty-a0 = "${PN}-iwlwifi-license"

PACKAGES =+ "${PN}-iwlwifi-quz-a0-hr-b0"

FILES:${PN}-iwlwifi-quz-a0-hr-b0 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-QuZ-a0-hr-b0-*.ucode* \
"

PACKAGES =+ "${PN}-iwlwifi-quz-a0-jf-b0"
FILES:${PN}-iwlwifi-quz-a0-jf-b0 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-QuZ-a0-jf-b0-*.ucode* \
"

FILES:${PN}-moxa = "${nonarch_base_libdir}/firmware/moxa/moxa-*.fw*"
