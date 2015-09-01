inherit ptest

RDEPENDS_${PN}-ptest += "bash resin-tests"

# Resin specific install path
PTEST_PATH = "${libdir}/resin/${PN}/ptest"

# Install all resin packages tests
# Each test's filename in SRC_URI must be prepended with the string: "resin-test-"
do_install_ptest() {
    install ${WORKDIR}/resin-test-* ${D}${PTEST_PATH}
}
