DESCRIPTION = "Native Go bindings for D-Bus"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=09042bd5c6c96a2b9e45ddf1bc517eed"

SRC_URI = "git://github.com/godbus/dbus;protocol=https;destsuffix=${PN}-${PV}/src/${GO_IMPORT}"
SRCREV = "5f6efc7ef2759c81b7ba876593971bfce311eab3"

inherit resin-go
GO_IMPORT = "github.com/godbus/dbus"
