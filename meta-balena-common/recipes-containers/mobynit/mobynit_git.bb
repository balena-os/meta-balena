HOMEPAGE = "https://www.balena.io/"
SUMMARY = "Utility to mount container filesystems"
DESCRIPTION = "Utility to mount container filesystems"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit go

RDEPENDS:${PN} = "util-linux"

GO_IMPORT = "github.com/balena-os/mobynit"
SRC_URI = "git://${GO_IMPORT};nobranch=1;protocol=https"
# v1.0.0
SRCREV="68b5fba96640392b591d27d243b891f657d7d02b"

S = "${WORKDIR}/${BPN}/src/${GO_IMPORT}"

# Use a resilient GOPROXY chain so the build does not fail when proxy.golang.org
# TLS-stalls or is otherwise unreachable from the build host. goproxy.io is a
# well-known mirror; "direct" lets the Go toolchain fall back to fetching the
# module straight from its VCS origin.
GOPROXY ??= "https://proxy.golang.org,https://goproxy.io,direct"

do_compile[network] = "1"
do_compile() {
    cd ${S}
    unset GO_LDFLAGS
    unset GOPATH GOROOT
    export GOCACHE="${B}/.cache"
    export GOPROXY="${GOPROXY}"
    # Retry once on transient network failures (TLS stalls against module
    # proxies have been observed from some build hosts).
    oe_runmake || oe_runmake
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
