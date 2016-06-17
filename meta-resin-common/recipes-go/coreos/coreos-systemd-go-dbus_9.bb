DESCRIPTION = "Go bindings to systemd D-Bus"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT_ROOT}/LICENSE;md5=19cbd64715b51267a47bf3750cc6a8a5"

DEPENDS = "godbus-dbus"

SRC_URI = "git://github.com/coreos/go-systemd;protocol=https;destsuffix=${PN}-${PV}/src/${GO_IMPORT_ROOT}"
SRCREV = "6dc8b843c670f2027cc26b164935635840a40526"

inherit resin-go
GO_IMPORT_ROOT = "github.com/coreos/go-systemd"
GO_IMPORT = "github.com/coreos/go-systemd/dbus"

# We don't ship all the src
INSANE_SKIP_${PN} += "installed-vs-shipped"
