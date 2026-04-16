FILESEXTRAPATHS:prepend := "${THISDIR}/lvm2:"

SRC_URI += " \
    file://11-dm.rules \
"

S_UNPACK = "${@d.getVar('UNPACKDIR') or d.getVar('WORKDIR')}"

do_install:append() {
    install -m 444 -D "${S_UNPACK}/11-dm.rules" "${D}${nonarch_base_libdir}/udev/rules.d/"
}

FILES:${PN}:append = " ${nonarch_base_libdir}/udev/rules.d/11-dm.rules "
