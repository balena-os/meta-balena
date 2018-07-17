FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://dropbear.socket \
    file://ssh.service \
    file://dropbearkey.conf \
    "

# In dropbear versions 2016.73 and 2016.74 the code indentation has been fixed thus making our current patch (use_atomic_key_generation_in_all_cases.patch) not work anymore
# we work around this by detecting the dropbear version and applying the right patch for it
# Also, starting with dropbear version 2017.75 this patch is included so no need to apply it for the 2017.75 version or newer ones
python() {
    packageVersion = d.getVar('PV', True)
    srcURI = d.getVar('SRC_URI', True)
    if packageVersion >= '2016.73' and packageVersion <= '2016.74':
        d.setVar('SRC_URI', srcURI + ' ' + 'file://use_atomic_key_generation_in_all_cases_reworked.patch')
    elif packageVersion < '2016.73':
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

    install -d ${D}${sysconfdir}/default
    echo 'DROPBEAR_PORT="22222"' >> ${D}/etc/default/dropbear # Change default dropbear port to 22222

    # Advertise SSH service using an avahi service file
    mkdir -p ${D}/etc/avahi/services/
    install -m 0644 ${WORKDIR}/ssh.service ${D}/etc/avahi/services

    install -d ${D}${sysconfdir}/systemd/system/dropbearkey.service.d
    install -c -m 0644 ${WORKDIR}/dropbearkey.conf ${D}${sysconfdir}/systemd/system/dropbearkey.service.d
}
