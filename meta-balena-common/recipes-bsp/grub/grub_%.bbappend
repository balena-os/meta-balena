inherit deploy

DEPENDS_append_class-target = " grub-conf"

# we don't want grub modules in our sysroot
# this removes them for aarch64
FILES_${PN}-common_remove = "${libdir}/${BPN}"

do_deploy_class-target_aarch64() {
    install -d ${DEPLOYDIR}/grub/arm64-efi
    cp -r ${D}/${libdir}/grub/arm64-efi/*.mod ${DEPLOYDIR}/grub/arm64-efi/
}

do_deploy() {
    :
}

BBCLASSEXTEND = "native"

addtask do_deploy before do_package after do_install
