DESCRIPTION = "A golang registry for global request variables."
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=c50f6bd9c1e15ed0bad3bea18e3c1b7f"

SRC_URI = "git://github.com/gorilla/context;protocol=https;destsuffix=${PN}-${PV}/src/${GO_IMPORT}"
SRCREV = "1ea25387ff6f684839d82767c1733ff4d4d15d0a"

inherit resin-go
GO_IMPORT = "github.com/gorilla/context"
