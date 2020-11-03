FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://console_null_workaround \
    "

do_install_append() {
    install -m 0755 ${WORKDIR}/console_null_workaround ${D}/init.d/000-console_null_workaround
}

PACKAGES_append = " \
    initramfs-module-console-null-workaround \
    "

SUMMARY_initramfs-module-console-null-workaround = "Workaround needed for when console=null is passed in kernel cmdline"
RDEPENDS_initramfs-module-console-null-workaround = "${PN}-base"
FILES_initramfs-module-console-null-workaround = "/init.d/000-console_null_workaround"
