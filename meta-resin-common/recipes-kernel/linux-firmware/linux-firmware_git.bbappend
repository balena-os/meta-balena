PACKAGES =+ "${PN}-bcm43143 ${PN}-ibt ${PN}-iwlwifi-7265D ${PN}-rtl8188eu"

FILES_${PN}-bcm43143 = " \
    /lib/firmware/brcm/brcmfmac43143*.bin \
    "

FILES_${PN}-ibt = " \
    /lib/firmware/intel/ibt-hw-37.8.bseq \
    /lib/firmware/intel/ibt-hw-37.8.10-fw-1.10.3.11.e.bseq \
    "

FILES_${PN}-iwlwifi-7265D = " \
    /lib/firmware/iwlwifi-7265D-13.ucode \
    /lib/firmware/iwlwifi-7265D-12.ucode \
    /lib/firmware/iwlwifi-7265D-11.ucode \
    "

FILES_${PN}-rtl8188eu = " \
    /lib/firmware/rtlwifi/rtl8188eu*.bin \
    "
