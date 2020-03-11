# Due to a bug in oe-core, the 8000c was removed completely. Make sure this is
# available in pyro by redefining it here. Rocko and master are unaffected.
# Ref.: http://lists.openembedded.org/pipermail/openembedded-core/2018-February/147508.html
python __anonymous() {
	packages = d.getVar("PACKAGES", True)
	if not packages:
		return
	for p in packages.split():
		if p == "linux-firmware-iwlwifi-8000c":
			return
	d.setVar("PACKAGES", "linux-firmware-iwlwifi-8000c " + packages)
}
FILES_${PN}-iwlwifi-8000c = "${nonarch_base_libdir}/firmware/iwlwifi-8000C-*.ucode"

PACKAGES =+ "${PN}-bcm43143"

FILES_${PN}-bcm43143 = " \
    /lib/firmware/brcm/brcmfmac43143*.bin \
    "
