# The secure boot initramfs only needs dmsetup and the device-mapper udev
# rules, which are in libdevmapper. Package the 11-dm.rules that
# meta-balena-common adds, which keeps the udev database of the unlocked
# partitions for the root filesystem, with them.
FILES:${PN}:remove = "${nonarch_base_libdir}/udev/rules.d/11-dm.rules"
FILES:libdevmapper:append = " ${nonarch_base_libdir}/udev/rules.d/11-dm.rules"
