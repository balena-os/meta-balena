# We use sgdisk to check and repair the alternate GPT in case it
# gets corrupted. We perform this from the initramfs,
# and pack this tool only to keep the initramfs size to a minimum
do_install() {
    install -d ${D}${sbindir}
    install -m 0755 sgdisk ${D}${sbindir}
}
