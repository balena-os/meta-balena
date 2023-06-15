do_install:append() {
   tar -czf ${WORKDIR}/kernel_modules_headers.tar.gz -C "$kerneldir/../" .
}

do_deploy() {
    cp ${WORKDIR}/kernel_modules_headers.tar.gz ${DEPLOYDIR}/
}
inherit deploy
addtask do_deploy before do_package after do_install

# Quite a few devices have random precompiled elf binaries in their
# kernel src git trees. Remove various checks from this package to prevent
# QA errors
INSANE_SKIP:${PN} = "arch debug-files"

# Keep compatibility with device repositories that use the older headers
PROVIDES = "kernel-modules-headers"
