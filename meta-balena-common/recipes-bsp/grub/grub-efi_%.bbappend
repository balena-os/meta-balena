# We don't want grub modules in our sysroot, remove the entire prefix after do_deploy
# This removes them for x86-64
do_deploy_append_class-target_x86-64() {
    cp -r ${D}${libdir}/grub/ ${DEPLOYDIR}/
    rm -rf ${D}${prefix}
}

# also remove the entry from FILES
FILES_${PN}_remove_class-target_x86-64 = "${libdir}/grub/${GRUB_TARGET}-efi"
