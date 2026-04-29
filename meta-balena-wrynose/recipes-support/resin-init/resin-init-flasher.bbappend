RDEPENDS:${PN}:append = "${@oe.utils.conditional('SIGN_API','','',' lvm2',d)}"
