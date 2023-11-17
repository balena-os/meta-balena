FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://console_null_workaround \
    "

do_install:append() {
    install -m 0755 ${WORKDIR}/console_null_workaround ${D}/init.d/000-console_null_workaround
}

SUMMARY:initramfs-module-console-null-workaround = "Workaround needed for when console=null is passed in kernel cmdline"
RDEPENDS:initramfs-module-console-null-workaround = "${PN}-base"
FILES:initramfs-module-console-null-workaround = "/init.d/000-console_null_workaround"
