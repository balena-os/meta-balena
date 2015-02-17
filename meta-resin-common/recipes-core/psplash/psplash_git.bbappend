FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SPLASH_IMAGES += "${@bb.utils.contains('DISTRO_FEATURES', 'resin', 'file://resin_logo.png;outsuffix=resin', '', d)}"
