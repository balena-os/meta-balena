FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://dropbear.socket \
    file://failsafe-sshkey.pub \
    file://ssh.service \
    file://dropbearkey.conf \
    "

# starting with dropbear version 2016.73, code indentation has been fixed thus making our current patch (use_atomic_key_generation_in_all_cases.patch) not work anymore
# we work around this by detecting the dropbear version and applying the right patch for it
python() {
    packageVersion = d.getVar('PV', True)
    srcURI = d.getVar('SRC_URI', True)
    if packageVersion >= '2016.73':
        d.setVar('SRC_URI', srcURI + ' ' + 'file://use_atomic_key_generation_in_all_cases_reworked.patch')
    else:
        d.setVar('SRC_URI', srcURI + ' ' + 'file://use_atomic_key_generation_in_all_cases.patch')
}

FILES_${PN} += "/home"

SYSTEMD_SERVICE_${PN} += "dropbearkey.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install_append() {
    if ! ${@bb.utils.contains('DISTRO_FEATURES','development-image','true','false',d)}; then
        # Disable password logins
        install -d ${D}${sysconfdir}/default
        echo 'DROPBEAR_EXTRA_ARGS="-s"' >> ${D}/etc/default/dropbear
    fi

    if [ "${RESIN_CONNECTABLE_ENABLE_SERVICES}" = "1" ]; then
        mkdir -p ${D}/home/root/.ssh/
        mkdir -p ${D}${localstatedir}/lib/dropbear/ # This will enable the authorized_keys to be updated even when the device has read_only root.
        install -m 0400 ${WORKDIR}/failsafe-sshkey.pub ${D}/${localstatedir}/lib/dropbear/authorized_keys
        ln -sf ${localstatedir}/lib/dropbear/authorized_keys ${D}/home/root/.ssh/authorized_keys
    fi

    install -d ${D}${sysconfdir}/default
    echo 'DROPBEAR_PORT="22222"' >> ${D}/etc/default/dropbear # Change default dropbear port to 22222

    # Advertise SSH service using an avahi service file
    mkdir -p ${D}/etc/avahi/services/
    install -m 0644 ${WORKDIR}/ssh.service ${D}/etc/avahi/services

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system/dropbearkey.service.d
        install -c -m 0644 ${WORKDIR}/dropbearkey.conf ${D}${sysconfdir}/systemd/system/dropbearkey.service.d
    fi

}
do_install[vardeps] += "DISTRO_FEATURES RESIN_CONNECTABLE_ENABLE_SERVICES"
