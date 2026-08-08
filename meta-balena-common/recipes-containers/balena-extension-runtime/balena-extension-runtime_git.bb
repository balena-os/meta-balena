HOMEPAGE = "https://www.balena.io/"
SUMMARY = "OCI runtime for hostapp extensions"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit go systemd

GO_IMPORT = "github.com/balena-os/balena-extension-runtime"
SRC_URI = "git://github.com/balena-os/balena-extension-runtime;nobranch=1;protocol=https \
    file://hostapp-extensions-cleanup.service \
    "
# v1.2.1
SRCREV = "b9f37ff2ca2bdc60760f824fe1b8d9cec514eff0"
PV = "1.2.1"

S = "${WORKDIR}/${BPN}/src/${GO_IMPORT}"

GOPROXY ??= "https://proxy.golang.org,direct"

EXTRA_OEMAKE += "VERSION=${PV}"

do_compile[network] = "1"
do_compile() {
    cd ${S}
    unset GO_LDFLAGS
    unset GOPATH GOROOT
    export GOCACHE="${B}/.cache"
    export GOPROXY="${GOPROXY}"
    oe_runmake
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/balena-extension-runtime ${D}${bindir}
    # Same binary, dispatched on argv[0] - upstream's Makefile links the two
    # names rather than building twice. Installing a second copy would waste
    # 4.6MiB of hostapp space.
    ln -sf balena-extension-runtime ${D}${bindir}/balena-extension-manager

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/hostapp-extensions-cleanup.service \
            ${D}${systemd_unitdir}/system
    fi
}

SYSTEMD_SERVICE:${PN} = "hostapp-extensions-cleanup.service"

RDEPENDS:${PN} += "os-helpers-extensions"

FILES:${PN} += " \
    ${systemd_unitdir}/system/hostapp-extensions-cleanup.service \
"

INHIBIT_PACKAGE_STRIP = "1"
INSANE_SKIP:${PN} += "already-stripped"
