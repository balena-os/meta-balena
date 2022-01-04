FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += " \
    file://11-dm.rules \
"

do_install:append() {
    install -m 444 -D "${WORKDIR}/11-dm.rules" "${D}${nonarch_base_libdir}/udev/rules.d/"
}
