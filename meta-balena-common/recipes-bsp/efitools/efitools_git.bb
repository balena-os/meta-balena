require efitools.inc

# The generated native binaries are used during native and target build
DEPENDS += "${BPN}-native gnu-efi openssl"

SRC_URI:append = " \
    file://LockDown-enable-the-enrollment-for-DBX.patch \
    file://LockDown-show-the-error-message-with-3-sec-timeout.patch \
    file://Makefile-do-not-build-signed-efi-image.patch \
    file://Build-DBX-by-default.patch \
    file://LockDown-disable-the-entrance-into-BIOS-setup-to-re-.patch \
    file://Fix-help2man-error.patch \
"

COMPATIBLE_HOST = "(i.86|x86_64|arm|aarch64).*-linux"

inherit deploy

EXTRA_OEMAKE:append = " \
    INCDIR_PREFIX='${STAGING_DIR_TARGET}' \
    CRTPATH_PREFIX='${STAGING_DIR_TARGET}' \
    SIGN_EFI_SIG_LIST='${STAGING_BINDIR_NATIVE}/sign-efi-sig-list' \
    CERT_TO_EFI_SIG_LIST='${STAGING_BINDIR_NATIVE}/cert-to-efi-sig-list' \
    CERT_TO_EFI_HASH_LIST='${STAGING_BINDIR_NATIVE}/cert-to-efi-hash-list' \
    HASH_TO_EFI_SIG_LIST='${STAGING_BINDIR_NATIVE}/hash-to-efi-sig-list' \
    HELP2MAN_PROG_PREFIX='${STAGING_BINDIR_NATIVE}' \
"

do_install:append() {
    install -d ${D}${EFI_BOOT_PATH}
    install -m 0755 ${D}${datadir}/efitools/efi/LockDown.efi ${D}${EFI_BOOT_PATH}
}

do_deploy() {
    install -d ${DEPLOYDIR}

    install -m 0600 ${D}${EFI_BOOT_PATH}/LockDown.efi "${DEPLOYDIR}"
    if [ -e ${D}${EFI_BOOT_PATH}/LockDown.efi.sig ] ; then
        install -m 0600 ${D}${EFI_BOOT_PATH}/LockDown.efi.sig "${DEPLOYDIR}"
    fi
}
addtask deploy after do_install before do_build

PACKAGES =+ "${PN}-utils"
FILES:${PN}-utils = "/usr/bin/efi-updatevar /usr/bin/efi-readvar /usr/bin/sig-list-to-certs /usr/bin/hash-to-efi-sig-list"

PACKAGES =+ "${PN}-lockdown"
FILES:${PN}-lockdown = "/boot/efi/EFI/BOOT/LockDown.efi"
