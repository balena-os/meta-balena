do_install_append() {
   tar -czf ${WORKDIR}/kernel_source.tar.gz -C "$kerneldir/../" .
}

do_deploy() {
    cp ${WORKDIR}/kernel_source.tar.gz ${DEPLOYDIR}/
    rm ${WORKDIR}/kernel_source.tar.gz
}
inherit deploy
addtask do_deploy before do_package after do_install

# Quite a few devices have random precompiled elf binaries in their
# kernel src git trees. Remove various checks from this package to prevent
# QA errors
INSANE_SKIP_${PN} = "arch debug-files"

# kernel-modules-headers recipe does some work on the kernel tree.
# We'd like to make sure that we dont tarball at the same time as that
# recipe is working on the tree
DEPENDS += "kernel-modules-headers"
