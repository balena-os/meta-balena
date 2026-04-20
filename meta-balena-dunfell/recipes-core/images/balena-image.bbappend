IMAGE_INSTALL_append = "${@oe.utils.conditional('SIGN_API','','',' lvm2-udevrules',d)}"
