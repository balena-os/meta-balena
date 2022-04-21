HOMEPAGE = "https://www.balena.io/"
SUMMARY = "Utility to mount container filesystems"
DESCRIPTION = "Utility to mount container filesystems"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit go

RDEPENDS:${PN} = "util-linux"

GO_IMPORT = "github.com/balena-os/mobynit"
SRC_URI = "git://${GO_IMPORT};branch=alexgg/moby"
SRCREV="610b2b81378e087908904d40c98259ae8712d8a0"

S = "${WORKDIR}/${BPN}/src/${GO_IMPORT}"

do_compile() {
    cd ${S}
    unset GO_LDFLAGS
    unset GOPATH GOROOT
    export GOCACHE="${B}/.cache"
    oe_runmake
}

do_install() {
	install -d ${D}/boot
        install -m 0755 ${S}/mobynit ${D}/boot/init
}

FILES:${PN} += " \
    /boot/init \
"

INHIBIT_PACKAGE_STRIP = "1"
INSANE_SKIP:${PN} += "already-stripped"
