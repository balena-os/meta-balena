do_install_append() {
    # we disable forwarding to syslog; in the future we will have rsyslog which can read the journal
    # independently of this forwarding
    sed -i -e 's/.*ForwardToSyslog.*/#ForwardToSyslog=yes/' ${D}${sysconfdir}/systemd/journald.conf
    sed -i -e 's/.*RuntimeMaxUse.*/RuntimeMaxUse=8M/' ${D}${sysconfdir}/systemd/journald.conf
    sed -i -e 's/.*Storage.*/Storage=volatile/' ${D}${sysconfdir}/systemd/journald.conf

    # Staging Resin build
    if ${@bb.utils.contains('DISTRO_FEATURES','resin-staging','true','false',d)}; then
        echo "Staging environment"
    else
       if $(readlink autovt@.service) == "getty@*.service"; then
           rm ${D}/lib/systemd/system/autovt@.service
       fi
       find ${D} -name "getty@*.service" -delete
    fi

}

# Network configuration is managed by connman
PACKAGECONFIG_remove = "resolved networkd"
