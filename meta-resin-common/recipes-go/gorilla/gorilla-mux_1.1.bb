DESCRIPTION = "A powerful URL router and dispatcher for golang."
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=c50f6bd9c1e15ed0bad3bea18e3c1b7f"

DEPENDS = "gorilla-context"

SRC_URI = "git://github.com/gorilla/mux;protocol=https;destsuffix=${PN}-${PV}/src/${GO_IMPORT}"
SRCREV = "0eeaf8392f5b04950925b8a69fe70f110fa7cbfc"

inherit resin-go
GO_IMPORT = "github.com/gorilla/mux"
