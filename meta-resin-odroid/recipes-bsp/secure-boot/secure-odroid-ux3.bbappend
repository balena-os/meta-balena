FILESEXTRAPATHS_prepend_odroid-ux3 := "${THISDIR}/${PN}:"

SRC_URI_append_odroid-ux3 = " \
    file://rw-rootfs.patch;patchdir=${WORKDIR} \
    "

python __anonymous() {
    # Some boards need some patching
    if d.getVar("MACHINE", True) == "odroid-ux3":
        d.delVarFlag('do_patch', 'noexec')
}
