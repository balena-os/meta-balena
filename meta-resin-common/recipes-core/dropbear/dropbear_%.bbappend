FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://atomic-hostkey.patch \
    file://dropbear.socket \
    file://failsafe-sshkey.pub \
    file://ssh.service \
    "

FILES_${PN} += "/home"

SYSTEMD_SERVICE_${PN} += "dropbearkey.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install_append() {
    if ! ${@bb.utils.contains('DISTRO_FEATURES','development-image','true','false',d)}; then
        # Disable root password logins
        install -d ${D}${sysconfdir}/default
        echo 'DROPBEAR_EXTRA_ARGS="-g"' >> ${D}/etc/default/dropbear
    fi

    mkdir -p ${D}/home/root/.ssh
    mkdir -p ${D}${localstatedir}/lib/dropbear/ # This will enable the authorized_keys to be updated even when the device has read_only root.
    install -m 0400 ${WORKDIR}/failsafe-sshkey.pub ${D}/${localstatedir}/lib/dropbear/authorized_keys
    ln -sf ${localstatedir}/lib/dropbear/authorized_keys ${D}/home/root/.ssh/authorized_keys

    install -d ${D}${sysconfdir}/default
    echo 'DROPBEAR_PORT="22222"' >> ${D}/etc/default/dropbear # Change default dropbear port to 22222

    # Advertise SSH service using an avahi service file
    mkdir -p ${D}/etc/avahi/services
    install -m 0644 ${WORKDIR}/ssh.service ${D}/etc/avahi/services
}
do_install[vardeps] += "DISTRO_FEATURES"
