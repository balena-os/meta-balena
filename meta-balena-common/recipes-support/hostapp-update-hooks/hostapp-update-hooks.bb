DESCRIPTION = "Resin hostapp hooks"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://hostapp-update-hooks"
S = "${WORKDIR}"

inherit allarch

HOSTAPP_HOOKS = "0-bootfiles"
RESIN_BOOT_FINGERPRINT = "${RESIN_FINGERPRINT_FILENAME}.${RESIN_FINGERPRINT_EXT}"

python __anonymous() {
	# Generate SRC_URI based on HOSTAPP_HOOKS
	hooks=d.getVar("HOSTAPP_HOOKS", True)
	srcuri=d.getVar("SRC_URI", True)
	new_srcuri=srcuri
	for h in hooks.split():
		new_srcuri = new_srcuri + " file://" + h
	d.setVar("SRC_URI", new_srcuri)
}

FILES_${PN} += " \
	${sysconfdir}/hostapp-update-hooks.d \
	"

RDEPENDS_${PN} = " \
	util-linux \
	balena \
	"

do_install() {
	mkdir -p ${D}${sysconfdir}/hostapp-update-hooks.d/
	for h in ${HOSTAPP_HOOKS}; do
		install -m 0755 $h ${D}${sysconfdir}/hostapp-update-hooks.d
	done
	mkdir -p ${D}${bindir}
	install -m 0755 hostapp-update-hooks ${D}${bindir}

	sed -i -e 's:@RESIN_BOOT_FINGERPRINT@:${RESIN_BOOT_FINGERPRINT}:g;' \
	 	${D}${sysconfdir}/hostapp-update-hooks.d/0-bootfiles
}
