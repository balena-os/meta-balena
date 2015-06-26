# Ugly hack to get rid of warnings like:
#
# WARNING: log_check: There is a warn message in the logfile
# WARNING: log_check: Matched keyword: [WARNING:]
# WARNING: log_check: WARNING: The license listed Firmware-atheros_firmware was not in the licenses collected for linux-firmware
#
# Proper fix is already in poky master. Get rid of this ugliness when we update
# poky.
#
LICENSE_${PN}-ath9k = ""
LICENSE_${PN}-ralink = ""
LICENSE_${PN}-rtl8192cu = ""

PACKAGES =+ "${PN}-bcm43143"

FILES_${PN}-bcm43143 = " \
    /lib/firmware/brcm/brcmfmac43143*.bin \
    "
