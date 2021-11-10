# We don't want grub modules in our sysroot
do_install:append:class-target() {
    rm -rf ${D}${prefix}
}

# Modules are built into the grub image for speed and simplicity, but DTs still
# expect the modules directory to exist in ${DEPLOYDIR}, so create it.
do_deploy:append:class-target() {
    install -d ${DEPLOYDIR}/grub/${GRUB_TARGET}-efi/
}

# build in additional required modules
GRUB_BUILDIN:append = " regexp probe gzio"
