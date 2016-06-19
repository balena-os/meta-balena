DESCRIPTION = "Resin Provisioner"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS = "coreos-systemd-go-dbus gorilla-mux"

SRC_URI = "git://github.com/resin-os/resin-provisioner;protocol=https;tag=v${PV};destsuffix=${PN}-${PV}/src/${GO_IMPORT}"

inherit resin-go
GO_IMPORT = "github.com/resin-os/resin-provisioner"

inherit binary-compress
FILES_COMPRESS = "${bindir}/provisioner-simple-client"

do_install_append() {
    # We currently don't use the server binary
    rm -rf ${D}${bindir}/provisioner-server
}

# There is a bash script in the sources
RDEPENDS_${PN}-staticdev = "bash"
