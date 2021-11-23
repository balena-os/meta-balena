FILESEXTRAPATHS:prepend := "${THISDIR}/grub-efi:"

inherit sign-efi

SRC_URI += " \
    file://pass-secure-boot.patch \
    file://0001-Add-dummyterm-module.patch \
    "

# build in additional required modules
GRUB_BUILDIN:append = " gcry_sha256 gcry_sha512 gcry_rijndael gcry_rsa regexp probe gzio"
GRUB_BUILDIN:append = "${@oe.utils.conditional('SIGN_API','','',' dummyterm',d)}"

do_configure:append() {
    if [ "x${SIGN_API}" != "x" ]; then
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

# Modules are built into the grub image for speed and simplicity, but DTs still
# expect the modules directory to exist in ${DEPLOYDIR}, so create it.
do_deploy:append:class-target() {
    install -d ${DEPLOYDIR}/grub/${GRUB_TARGET}-efi/
}

do_mkimage() {
    cd ${B}

    if [ -f "${DEPLOY_DIR_IMAGE}/balena-keys/grub.gpg" ]; then
        GRUB_PUBKEY_ARG="--pubkey ${DEPLOY_DIR_IMAGE}/balena-keys/grub.gpg"
    fi

    # Search for the grub.cfg on the local boot media by using the
    # built in cfg file provided via this recipe
    grub-mkimage -c ../cfg -p ${EFIDIR} -d ./grub-core/ \
           -O ${GRUB_TARGET}-efi -o ./${GRUB_IMAGE_PREFIX}${GRUB_IMAGE} \
           ${GRUB_BUILDIN} ${GRUB_PUBKEY_ARG}
}

do_mkimage[depends] += " \
    balena-keys:do_deploy \
    "

SIGNING_ARTIFACTS = "${B}/${GRUB_IMAGE_PREFIX}${GRUB_IMAGE}"
addtask sign_efi after do_mkimage before do_install
