inherit deploy

DEPENDS_append_class-target = " grub-conf"

do_deploy_class-target() {
    cp -r ${D}${libdir}/grub/ ${DEPLOYDIR}/
}

do_deploy() {
    :
}

BBCLASSEXTEND = "native"

addtask do_deploy before do_package after do_install
