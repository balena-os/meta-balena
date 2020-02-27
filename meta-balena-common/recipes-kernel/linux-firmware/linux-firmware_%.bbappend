PACKAGES =+ "${PN}-rtl8188eu"

FILES_${PN}-rtl8188eu = " \
    /lib/firmware/rtlwifi/rtl8188eu*.bin \
    "

PACKAGES =+ "${PN}-iwlwifi-9260"

FILES_${PN}-iwlwifi-9260 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-9260-* \
    "

PACKAGES =+ "${PN}-iwlwifi-qu-b0-hr-b0"

FILES_${PN}-iwlwifi-qu-b0-hr-b0 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-Qu-b0-hr-b0-* \
    "

PACKAGES =+ "${PN}-ibt-19-0-4"

FILES_${PN}-ibt-19-0-4  = " \
    ${nonarch_base_libdir}/firmware/intel/ibt-19-0-4.doc \
    ${nonarch_base_libdir}/firmware/intel/ibt-19-0-4.sfi \
    "
