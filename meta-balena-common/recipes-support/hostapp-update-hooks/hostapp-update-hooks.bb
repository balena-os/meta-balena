DESCRIPTION = "Resin hostapp hooks"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://hostapp-update-hooks"
S = "${WORKDIR}"

inherit allarch

HOSTAPP_HOOKS = " \
    0-signed-update \
    1-bootfiles \
    60-data-breadcrumb \
    70-sshd_migrate_keys \
    75-supervisor-db/75-forward_supervisor-db \
    75-supervisor-db/75-fwd_commit_supervisor-db \
    76-supervisor-db/76-forward_supervisor-db \
    76-supervisor-db/76-fwd_commit_supervisor-db \
    80-rollback \
    "
HOSTAPP_HOOKS_DIRS = "75-supervisor-db 76-supervisor-db"

BALENA_BOOT_FINGERPRINT = "${BALENA_FINGERPRINT_FILENAME}.${BALENA_FINGERPRINT_EXT}"

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

FILES:${PN} += " \
	${sysconfdir}/hostapp-update-hooks.d \
	"

RDEPENDS:${PN} = " \
    balena \
    dropbear \
    openssh-keygen \
    util-linux \
    efivar \
    efitools-utils \
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

	sed -i -e 's:@BALENA_BOOT_FINGERPRINT@:${BALENA_BOOT_FINGERPRINT}:g;' \
	 	${D}${sysconfdir}/hostapp-update-hooks.d/1-bootfiles
}
