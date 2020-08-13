DESCRIPTION = "Bash Automated Test System"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    git://github.com/sstephenson/bats.git;nobranch=1;name=core \
    git://github.com/ztombol/bats-support.git;nobranch=1;destsuffix=bats-support;name=support \
    git://github.com/ztombol/bats-assert.git;nobranch=1;destsuffix=bats-assert;name=assert \
"
SRCREV_core = "03608115df2071fff4eaaff1605768c275e5f81f"
SRCREV_support = "004e707638eedd62e0481e8cdc9223ad471f12ee"
SRCREV_assert = "9f88b4207da750093baabc4e3f41bf68f0dd3630"

S = "${WORKDIR}/git"

RDEPENDS_${PN} = "bash"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

do_install() {
    install -d ${D}${libdir}
    rm -rf ${WORKDIR}/bats-support/.git ${WORKDIR}/bats-support/.travis.yml
    rm -rf ${WORKDIR}/bats-assert/.git ${WORKDIR}/bats-assert/.travis.yml
    rm -rf ${WORKDIR}/bats-support/test
    rm -rf ${WORKDIR}/bats-assert/test
    cp -r ${WORKDIR}/bats-support ${D}${libdir}
    cp -r ${WORKDIR}/bats-assert ${D}${libdir}
    install -d ${D}${bindir}
    install -m 0755 ${S}/bin/* ${D}${bindir}
    install -d ${D}${libexecdir}
    install ${S}/libexec/* ${D}${libexecdir}
}

FILES_${PN} = "${bindir} ${libexecdir} ${libdir}"

BBCLASSEXTEND = "native"
