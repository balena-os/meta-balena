do_install:append() {
   tar -czf ${WORKDIR}/kernel_source.tar.gz -C "$kerneldir/../" .
}

do_deploy() {
    cp ${WORKDIR}/kernel_source.tar.gz ${DEPLOYDIR}/
}
inherit deploy
addtask do_deploy before do_package after do_install

# Quite a few devices have random precompiled elf binaries in their
# kernel src git trees. Remove various checks from this package to prevent
# QA errors
INSANE_SKIP:${PN} = "arch debug-files"

# kernel-modules-headers recipe does some work on the kernel tree.
# We'd like to make sure that we dont tarball at the same time as that
# recipe is working on the tree
DEPENDS += "${@bb.utils.contains('KERNEL_HEADERS_PACKAGES', 'kernel-modules-headers', 'kernel-modules-headers', '', d)}"
