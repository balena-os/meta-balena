FILESEXTRAPATHS_append := "${THISDIR}/files:"
SRC_URI_append = " \
    file://only-resin-tests.patch \
    file://resin-ptest-runner \
    "

# Please patch
python __anonymous() {
    d.delVarFlag('do_patch', 'noexec')
}

RDEPENDS_${PN} += "bash"

do_install_append() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/resin-ptest-runner ${D}${bindir}
}
