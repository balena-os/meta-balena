FILESEXTRAPATHS:prepend := "${THISDIR}/grub-efi:"

inherit sign-efi

SRC_URI += " \
    file://0001-Add-dummyterm-module.patch \
    "

# build in additional required modules
GRUB_BUILDIN:append = " gcry_sha256 gcry_sha512 gcry_rijndael gcry_rsa regexp probe gzio chain"
GRUB_BUILDIN:append = "${@oe.utils.conditional('SIGN_API','','',' dummyterm',d)}"

do_configure:append() {
    if [ "x${SIGN_API}" != "x" ] && [ "${OS_DEVELOPMENT}" != "1" ]; then
        SILENT_CONFIG=$(mktemp)
        echo "terminal_input dummyterm" >> "${SILENT_CONFIG}"
        echo "terminal_output dummyterm" >> "${SILENT_CONFIG}"
        cat ../cfg >> "${SILENT_CONFIG}"
        mv "${SILENT_CONFIG}" ../cfg
    fi
}

# We don't want grub modules in our sysroot
do_install:append:class-target() {
    rm -rf ${D}${prefix}
}

do_deploy:append:class-target() {
    # Modules are built into the grub image for speed and simplicity, but DTs still
    # expect the modules directory to exist in ${DEPLOYDIR}, so create it.
    install -d ${DEPLOYDIR}/grub/${GRUB_TARGET}-efi/

    if [ -f "${DEPLOY_DIR_IMAGE}/balena-keys/grub.gpg" ]; then
        install -m 644 ${B}/${GRUB_IMAGE_PREFIX}${GRUB_IMAGE}.secureboot ${DEPLOYDIR}
    fi
}

do_mkimage:append() {
    PUBKEY_FILE="${DEPLOY_DIR_IMAGE}/balena-keys/grub.gpg"
    if [ -f "${PUBKEY_FILE}" ]; then
        grub-mkimage -c ../cfg -p ${EFIDIR} -d ./grub-core/ \
               -O ${GRUB_TARGET}-efi -o ./${GRUB_IMAGE_PREFIX}${GRUB_IMAGE}.secureboot \
               ${GRUB_BUILDIN} --pubkey "${PUBKEY_FILE}" --disable-shim-lock
    fi
}

do_mkimage[depends] += " \
    balena-keys:do_deploy \
    "

SIGNING_ARTIFACTS = "${B}/${GRUB_IMAGE_PREFIX}${GRUB_IMAGE}.secureboot"
addtask sign_efi after do_mkimage before do_install
