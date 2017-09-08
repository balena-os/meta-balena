DESCRIPTION = "Supplemental Go packages for low-level interactions with the \
operating system"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=5d4950ecb7b26d2c5e4e7b4e0dd74707"

inherit resin-go
GO_IMPORT = "golang.org/x/sys"

SRC_URI = "git://github.com/golang/sys;protocol=https;destsuffix=${PN}-${PV}/src/${GO_IMPORT}/"
SRCREV = "35ef4487ce0a1ea5d4b616ffe71e34febe723695"
