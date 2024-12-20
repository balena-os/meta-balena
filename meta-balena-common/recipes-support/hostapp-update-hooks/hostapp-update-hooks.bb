DESCRIPTION = "Resin hostapp hooks"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://hostapp-update-hooks"
S = "${WORKDIR}"

inherit allarch

HOSTAPP_HOOKS = " \
    1-bootfiles \
    60-data-breadcrumb \
    70-sshd_migrate_keys \
    75-supervisor-db/75-forward_supervisor-db \
    75-supervisor-db/75-fwd_commit_supervisor-db \
    76-supervisor-db/76-forward_supervisor-db \
    76-supervisor-db/76-fwd_commit_supervisor-db \
    80-rollback \
    "

SECUREBOOT_HOOKS = " \
    0-signed-update \
    95-secureboot/1-fwd_commit_apply-dbx \
    95-secureboot/2-fwd_commit_update-policy \
    "
SECUREBOOT_HOOK_DIRS = " \
    95-secureboot \
    "
HOSTAPP_HOOKS:append = "${@bb.utils.contains('MACHINE_FEATURES', 'efi', '${SECUREBOOT_HOOKS}', '', d)}"

HOSTAPP_HOOKS_DIRS = "75-supervisor-db 76-supervisor-db"
HOSTAPP_HOOKS_DIRS:append = "${@bb.utils.contains('MACHINE_FEATURES', 'efi', '${SECUREBOOT_HOOK_DIRS}', '', d)}"

GRUB_INSTALL_DIR = "${@bb.utils.contains('MACHINE_FEATURES','efi','/EFI/BOOT','/grub',d)}"

BALENA_BOOT_FINGERPRINT = "${BALENA_FINGERPRINT_FILENAME}.${BALENA_FINGERPRINT_EXT}"
BALENA_BOOTFILES_BLACKLIST="\
	/config.json \
	/config.txt \
	/splash/balena-logo.png \
	/extra_uEnv.txt \
	/${GRUB_INSTALL_DIR}/grub_extraenv \
	/configfs.json \
	/hw_intfc.conf \
	/bootenv \
	"

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
    "
RDEPENDS:${PN}:append = "${@oe.utils.conditional('SIGN_API','','',' os-helpers-sb',d)}"

RDEPENDS:${PN}:append = "${@bb.utils.contains('MACHINE_FEATURES', 'efi', ' efivar efitools-utils tcgtool', '',d)}"

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
	sed -i -e 's:@BALENA_BOOTFILES_BLACKLIST@:${BALENA_BOOTFILES_BLACKLIST}:g;' \
		${D}${sysconfdir}/hostapp-update-hooks.d/1-bootfiles
}
