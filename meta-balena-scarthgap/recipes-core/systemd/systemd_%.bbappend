RDEPENDS_${PN}:append = "${@oe.utils.conditional('SIGN_API','','',' lvm2-udevrules',d)}"
