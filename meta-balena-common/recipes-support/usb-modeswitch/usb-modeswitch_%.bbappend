FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# locally add jimtcl version 0.72 which is needed for building the statically linked version of the dispatcher
SRC_URI:append = " \
    git://repo.or.cz/r/jimtcl.git;protocol=http;destsuffix=${S}/jim;name=jimtcl;branch=master \
    file://use_local_libjim_static_library.patch \
"

SRCREV = "dfbde800afdabc83efc9ebe087b1aed6a90136d8"
