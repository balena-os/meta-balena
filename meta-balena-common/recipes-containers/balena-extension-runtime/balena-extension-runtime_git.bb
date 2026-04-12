HOMEPAGE = "https://www.balena.io/"
SUMMARY = "OCI runtime for hostapp extensions"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit go systemd

GO_IMPORT = "github.com/balena-os/balena-extension-runtime"
SRC_URI = "git://github.com/balena-os/balena-extension-runtime;branch=master;protocol=https \
    file://hostapp-extensions-cleanup.service \
    "
SRCREV = "bca6ae6753c5958abaa08417f3dcf461fabeaba7"
PV = "1.0.0"

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
    install -m 0755 ${S}/balena-extension-manager ${D}${bindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/hostapp-extensions-cleanup.service \
            ${D}${systemd_unitdir}/system
    fi
}

SYSTEMD_SERVICE:${PN} = "hostapp-extensions-cleanup.service"

FILES:${PN} += " \
    ${systemd_unitdir}/system/hostapp-extensions-cleanup.service \
"

INHIBIT_PACKAGE_STRIP = "1"
INSANE_SKIP:${PN} += "already-stripped"
