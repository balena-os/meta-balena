FILESEXTRAPATHS_prepend := "${THISDIR}/balena-files:"
SRC_URI += "file://localoptions.h"

do_configure_prepend() {
    # Apply custom configuration
    cp "${WORKDIR}/localoptions.h" "${B}"
}
