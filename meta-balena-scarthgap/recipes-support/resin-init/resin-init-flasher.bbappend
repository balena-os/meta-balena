S = "${WORKDIR}"

RDEPENDS:${PN}:append = "${@oe.utils.conditional('SIGN_API','','',' lvm2-udevrules',d)}"
