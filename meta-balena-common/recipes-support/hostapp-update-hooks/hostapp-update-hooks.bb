DESCRIPTION = "Resin hostapp hooks"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://hostapp-update-hooks"
S = "${WORKDIR}"

inherit allarch

HOSTAPP_HOOKS = " \
    0-bootfiles \
    70-sshd_migrate_keys \
    80-rollback \
    "
HOSTAPP_HOOKS_DIRS = ""

RESIN_BOOT_FINGERPRINT = "${RESIN_FINGERPRINT_FILENAME}.${RESIN_FINGERPRINT_EXT}"

python __anonymous() {
    # Generate SRC_URI based on HOSTAPP_HOOKS
    hooks=d.getVar("HOSTAPP_HOOKS", True)
    hooks = hooks + " " + d.getVar("HOSTAPP_HOOKS_DIRS", True)
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
    balena \
    dropbear \
    openssh-keygen \
    util-linux \
    "

do_install() {
	mkdir -p ${D}${sysconfdir}/hostapp-update-hooks.d/
	for hdir in ${HOSTAPP_HOOKS_DIRS}; do
		mkdir -p ${D}${sysconfdir}/hostapp-update-hooks.d/$hdir
	done
	for h in ${HOSTAPP_HOOKS}; do
		install -m 0755 $h ${D}${sysconfdir}/hostapp-update-hooks.d/"$h"
	done
	mkdir -p ${D}${bindir}
	install -m 0755 hostapp-update-hooks ${D}${bindir}/hostapp-update-hooks-v2
	ln -s -r ${D}${bindir}/hostapp-update-hooks-v2 ${D}${bindir}/hostapp-update-hooks

	sed -i -e 's:@RESIN_BOOT_FINGERPRINT@:${RESIN_BOOT_FINGERPRINT}:g;' \
	 	${D}${sysconfdir}/hostapp-update-hooks.d/0-bootfiles
}
