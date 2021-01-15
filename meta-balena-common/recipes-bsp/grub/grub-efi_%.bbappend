RDEPENDS_${PN}_class-target_x86-64 += "grub-efi-ia32"

do_deploy_append_class-target_x86-64() {
    cp -r ${D}${libdir}/grub/ ${DEPLOYDIR}/
}
