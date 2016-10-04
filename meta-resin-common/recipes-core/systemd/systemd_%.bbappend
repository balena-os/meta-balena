FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

SRC_URI_append = "${@bb.utils.contains('DISTRO_FEATURES', 'development-image', '', ' file://remove_systemd-getty-generator.patch', d)}"

FILES_${PN} += " \
    /srv \
    /etc/localtime \
    /etc/mtab \
    "

do_install_append() {
    # we disable forwarding to syslog; in the future we will have rsyslog which can read the journal
    # independently of this forwarding
    sed -i -e 's/.*ForwardToSyslog.*/#ForwardToSyslog=yes/' ${D}${sysconfdir}/systemd/journald.conf
    sed -i -e 's/.*RuntimeMaxUse.*/RuntimeMaxUse=8M/' ${D}${sysconfdir}/systemd/journald.conf
    sed -i -e 's/.*Storage.*/Storage=volatile/' ${D}${sysconfdir}/systemd/journald.conf

    if ${@bb.utils.contains('DISTRO_FEATURES','development-image','false','true',d)}; then
        # Non-development image
        if $(readlink autovt@.service) == "getty@*.service"; then
            rm ${D}/lib/systemd/system/autovt@.service
        fi
        find ${D} -name "getty@*.service" -delete
    fi

    install -d -m 0755 /srv

    ln -s ${datadir}/zoneinfo ${D}${sysconfdir}/localtime
    ln -s /proc/self/mounts ${D}${sysconfdir}/mtab
}

# add pool.ntp.org as default ntp server
PACKAGECONFIG[ntp] = "--with-ntp-servers=pool.ntp.org time1.google.com time2.google.com time3.google.com time4.google.com,,,"

PACKAGECONFIG_append = " ntp"

# Network configuration is managed by connman
PACKAGECONFIG_remove = "resolved networkd"

# Add missing users/groups defined in /usr/lib/sysusers.d/*
# In this time we avoid creating these at first boot
USERADD_PARAM_${PN} += "; --system systemd-bus-proxy; --system -d / -M --shell /bin/nologin -u 65534 nobody;"
GROUPADD_PARAM_${PN} += "; -r wheel; -r nobody;"
