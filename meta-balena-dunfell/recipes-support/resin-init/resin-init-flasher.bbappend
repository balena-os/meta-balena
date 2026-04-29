S = "${WORKDIR}"

RDEPENDS:${PN} += "${@oe.utils.conditional('SIGN_API','','',' lvm2-udevrules',d)}"
