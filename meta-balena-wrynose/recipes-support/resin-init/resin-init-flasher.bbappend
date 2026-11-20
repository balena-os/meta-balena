RDEPENDS:${PN}:append = "${@oe.utils.conditional('SIGN_API','','',' libdevmapper',d)}"
