FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

inherit deploy

SRC_URI:append = " \
    file://balena-logo.png \
    file://plymouth-disable-containerized.conf \
    file://plymouth-stop-balena-os.conf \
    file://plymouth-start-balena-os.conf \
    "

# remove patch that adds the retain splash option, as it's not needed
# and prevents user apps from writing to tty consoles even after stopping plymouth
SRC_URI:remove = "file://0001-plymouth-Add-the-retain-splash-option.patch"

# install our theme, and remove some extra files to save a significant
# amount of space
do_install:append() {
    rm -r ${D}${sysconfdir}/plymouth # we use /usr/share/plymouth, not /etc/plymouth

    # remove all libs except script.so (used by the resin theme) and the
    # renderers/ directory
    rm ${D}${nonarch_libdir}/plymouth/details.*
    rm ${D}${nonarch_libdir}/plymouth/fade-throbber.*
    rm ${D}${nonarch_libdir}/plymouth/space-flares.*
    rm ${D}${nonarch_libdir}/plymouth/text.*
    rm ${D}${nonarch_libdir}/plymouth/throbgress.* || true
    rm ${D}${nonarch_libdir}/plymouth/tribar.*
    rm ${D}${nonarch_libdir}/plymouth/two-step.*

    # Themes are installed separately
    rm -r ${D}${datadir}/plymouth/themes || true
    rm ${D}/${datadir}/plymouth/plymouthd.defaults

    # Don't stop splash at boot
    rm ${D}${systemd_unitdir}/system/multi-user.target.wants/plymouth-quit.service
    rm ${D}${systemd_unitdir}/system/multi-user.target.wants/plymouth-quit-wait.service

    # disable units when containerized
    for unit in plymouth-quit-wait.service \
                plymouth-quit.service \
                plymouth-read-write.service \
                plymouth-switch-root.service \
                systemd-ask-password-plymouth.path; do
        install -d -m 0755 ${D}${libdir}/systemd/system/${unit}.d
        install -m 0644 ${WORKDIR}/plymouth-disable-containerized.conf \
            ${D}${libdir}/systemd/system/${unit}.d
    done

    # install drop-in configs
    for unit in plymouth-halt.service \
                plymouth-kexec.service \
                plymouth-poweroff.service \
                plymouth-reboot.service; do
        install -d -m 0755 ${D}${libdir}/systemd/system/${unit}.d
        install -m 0644 ${WORKDIR}/plymouth-stop-balena-os.conf \
            ${D}${libdir}/systemd/system/${unit}.d
    done

    install -d -m 0755 ${D}${libdir}/systemd/system/plymouth-start.service.d
    install -m 0644 ${WORKDIR}/plymouth-start-balena-os.conf \
        ${D}${libdir}/systemd/system/plymouth-start.service.d
}

# package our drop-in configs
FILES:${PN} += " \
    ${libdir}/systemd/system/*.d \
    "

do_deploy() {
    install ${WORKDIR}/balena-logo.png ${DEPLOYDIR}/balena-logo.png
}

# by setting a logo we avoid installing the default one
LOGO = "/mnt/boot/splash/balena-logo.png"

PACKAGES:remove = "${PN}-initrd"
PACKAGECONFIG = ""
RDEPENDS:${PN} = "bash"

addtask deploy before do_package after do_install

# TODO
# systemd-ask-password-plymouth.service has a bug and ends up as an invalid
# service. For now mask it as we don't use it anyway.
pkg_postinst:${PN}:append () {
	if [ -n "$D" ]; then
		OPTS="--root=$D"
	fi
	systemctl $OPTS mask systemd-ask-password-plymouth.service
	systemctl $OPTS mask systemd-ask-password-plymouth.path
}
