FILESEXTRAPATHS:prepend := "${THISDIR}/24.004.60:"

SRC_URI:append = " file://0001-fix_undefined_reference_when_no_udev.patch"

PACKAGECONFIG:append = " systemd"

EXTRA_OEMESON += " -Dlogo='/mnt/boot/splash/balena-logo.png'"
