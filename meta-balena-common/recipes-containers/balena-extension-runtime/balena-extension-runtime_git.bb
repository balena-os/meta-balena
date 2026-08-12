HOMEPAGE = "https://www.balena.io/"
SUMMARY = "OCI runtime for hostapp extensions"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit go systemd

GO_IMPORT = "github.com/balena-os/balena-extension-runtime"
SRC_URI = "git://github.com/balena-os/balena-extension-runtime;branch=alexgg/manager-deactivate;protocol=https \
    file://hostapp-extensions-cleanup.service \
    "
SRCREV = "eda6d654aea3241c8b2ddc3c30f472e6ce5525bf"
PV = "1.2.1+git${SRCPV}"

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
    ln -sf balena-extension-runtime ${D}${bindir}/balena-extension-manager

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${UNPACKDIR}/hostapp-extensions-cleanup.service \
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
