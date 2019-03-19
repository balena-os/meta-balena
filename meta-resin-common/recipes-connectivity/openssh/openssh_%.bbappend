FILESEXTRAPATHS_prepend := "${THISDIR}/balena-files:"

SRC_URI_append = " \
    file://ssh_keys_merger \
    file://ssh.service \
    file://sshd_migrate_keys \
"

SYSTEMD_SERVICE_${PN}-sshd += "sshdgenkeys.service"

FILES_${PN}-sshd += " \
    ${libexecdir}/${BPN}/sshd_migrate_keys \
    ${sysconfdir}/avahi/services/ssh.service \
    ${sysconfdir}/systemd/system/sshdgenkeys.service.d/sshgenkeys.conf \
    ${sbindir}/ssh_keys_merger \
"

# The `ssh_keys_merger` script needs dropbear tools
RDEPENDS_${PN}-sshd += "dropbear"
RCONFLICTS_${PN} = ""
RCONFLICTS_${PN}-sshd = ""

do_install_append () {
    # Advertise SSH service using an avahi service file                                                                                                                                                                                                                                                                                                                   
    mkdir -p ${D}/etc/avahi/services/                                                                                                                                                                                                                                                                                                                                                    
    install -m 0644 ${WORKDIR}/ssh.service ${D}/etc/avahi/services

    # SSH keys merger tool for custom SSH keys
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/ssh_keys_merger ${D}${sbindir}

    # Create config files for read-only rootfs with custom paths for host keys
    install -d ${D}${sysconfdir}/ssh
    install -m 644 ${D}${sysconfdir}/ssh/sshd_config ${D}${sysconfdir}/ssh/sshd_config_readonly
    sed -i '/HostKey/d' ${D}${sysconfdir}/ssh/sshd_config_readonly
    echo "HostKey /etc/ssh/hostkeys/ssh_host_rsa_key" >> ${D}${sysconfdir}/ssh/sshd_config_readonly
    echo "HostKey /etc/ssh/hostkeys/ssh_host_dsa_key" >> ${D}${sysconfdir}/ssh/sshd_config_readonly
    echo "HostKey /etc/ssh/hostkeys/ssh_host_ecdsa_key" >> ${D}${sysconfdir}/ssh/sshd_config_readonly
    echo "HostKey /etc/ssh/hostkeys/ssh_host_ed25519_key" >> ${D}${sysconfdir}/ssh/sshd_config_readonly

    install -D -m 0755 ${WORKDIR}/sshd_migrate_keys ${D}${libexecdir}/${BPN}/sshd_migrate_keys
}
