SUMMARY = "libqmi is a library for talking to WWAN devices by QMI protocol"
DESCRIPTION = "libqmi is a glib-based library for talking to WWAN modems and devices which speak the Qualcomm MSM Interface (QMI) protocol"
HOMEPAGE = "http://www.freedesktop.org/wiki/Software/libqmi"
LICENSE = "GPLv2 & LGPLv2.1"
LIC_FILES_CHKSUM = " \
    file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
    file://COPYING.LIB;md5=4fbd65380cdd255951079008b364516c \
"

DEPENDS = "glib-2.0 libgudev libmbim glib-2.0-native"

inherit autotools pkgconfig bash-completion

SRC_URI = "http://www.freedesktop.org/software/${BPN}/${BPN}-${PV}.tar.xz \
           file://0001-Detect-clang.patch \
           "
SRC_URI[md5sum] = "b47f76261328780f5f770d750d0ca3d4"
SRC_URI[sha256sum] = "c2121243b5da8bcffc8f6f5ca0d7217498f94fffd115883763282c68f255fde7"
