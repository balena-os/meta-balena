FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

inherit deploy

SRC_URI_append = " \
    file://resin-logo.png \
    "

# install our theme, and remove some extra files to save a significant
# amount of space
do_install_append() {
    rm -r ${D}${sysconfdir}/plymouth # we use /usr/share/plymouth, not /etc/plymouth

    # remove all libs except script.so (used by the resin theme) and the
    # renderers/ directory
    rm ${D}${nonarch_libdir}/plymouth/details.*
    rm ${D}${nonarch_libdir}/plymouth/fade-throbber.*
    rm ${D}${nonarch_libdir}/plymouth/space-flares.*
    rm ${D}${nonarch_libdir}/plymouth/text.*
    rm ${D}${nonarch_libdir}/plymouth/throbgress.*
    rm ${D}${nonarch_libdir}/plymouth/tribar.*
    rm ${D}${nonarch_libdir}/plymouth/two-step.*

    # Themes are installed separately
    rm -r ${D}${datadir}/plymouth/themes
    rm ${D}/${datadir}/plymouth/plymouthd.defaults

    # Don't stop splash at boot
    rm ${D}${systemd_unitdir}/system/multi-user.target.wants/plymouth-quit.service
    rm ${D}${systemd_unitdir}/system/multi-user.target.wants/plymouth-quit-wait.service
}

do_deploy() {
    install ${WORKDIR}/resin-logo.png ${DEPLOYDIR}/resin-logo.png
}

# by setting a logo we avoid installing the default one
LOGO = "/mnt/boot/splash/resin-logo.png"

PACKAGES_remove = "${PN}-initrd"
PACKAGECONFIG_remove = "initrd"
RDEPENDS_${PN} = "bash"

addtask deploy before do_package after do_install

# TODO
# systemd-ask-password-plymouth.service has a bug and ends up as an invalid
# service. For now mask it as we don't use it anyway.
pkg_postinst_${PN}_append () {
	if [ -n "$D" ]; then
		OPTS="--root=$D"
	fi
	systemctl $OPTS mask systemd-ask-password-plymouth.service
	systemctl $OPTS mask systemd-ask-password-plymouth.path
}
