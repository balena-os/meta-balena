#
# Beaglebone has some specific requirements for dtc in order to compile the
# overlays
#

FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"

SRCREV = "f6dbc6ca9618391e4f30c415a0a09b7af35f7647"

SRC_URI_append = " \
    file://0001-fdtdump-Add-live-tree-dump-capability.patch \
    file://0002-dtc-Symbol-and-local-fixup-generation-support.patch \
    file://0003-dtc-Plugin-object-device-tree-support.patch \
    file://0004-dtc-Document-the-dynamic-plugin-internals.patch \
    "
