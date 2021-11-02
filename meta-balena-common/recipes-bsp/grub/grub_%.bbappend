inherit deploy

DEPENDS:append:class-target = " grub-conf"

# we don't want grub modules in our sysroot
# this removes them for aarch64
FILES:${PN}-common:remove = "${libdir}/${BPN}"

# remove utilities, such as grub-install, grub-mkrescue, etc.
FILES:${PN}-common:remove = "${sbindir}"
FILES:${PN}-common:remove = "${bindir}"

# Modules are built into the grub image for speed and simplicity, but DTs still
# expect the modules directory to exist in ${DEPLOYDIR}, so create it.
do_deploy:class-target:aarch64() {
    install -d ${DEPLOYDIR}/grub/arm64-efi
}

do_deploy() {
    :
}

BBCLASSEXTEND = "native"

addtask do_deploy before do_package after do_install
