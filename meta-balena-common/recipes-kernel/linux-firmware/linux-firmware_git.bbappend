PACKAGES =+ "${PN}-bcm43143 ${PN}-rtl8188eu"

FILES_${PN}-bcm43143 = " \
    /lib/firmware/brcm/brcmfmac43143*.bin \
    "

FILES_${PN}-rtl8188eu = " \
    /lib/firmware/rtlwifi/rtl8188eu*.bin \
    "
