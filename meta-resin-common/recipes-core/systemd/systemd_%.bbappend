FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

SRC_URI_append = " \
    file://coredump.conf \
    file://multi-user.conf \
    file://remove_systemd-getty-generator.patch \
    file://resin.target \
    file://watchdog.conf \
    "

FILES_${PN} += " \
    /srv \
    /etc/localtime \
    /etc/mtab \
    ${sysconfdir}/systemd/journald.conf.d \
    "

do_install_append() {
    # we disable forwarding to syslog; in the future we will have rsyslog which can read the journal
    # independently of this forwarding
    sed -i -e 's/.*ForwardToSyslog.*/#ForwardToSyslog=yes/' ${D}${sysconfdir}/systemd/journald.conf
    sed -i -e 's/.*RuntimeMaxUse.*/RuntimeMaxUse=8M/' ${D}${sysconfdir}/systemd/journald.conf
    sed -i -e 's/.*SystemMaxUse.*/SystemMaxUse=8M/' ${D}${sysconfdir}/systemd/journald.conf
    sed -i -e 's/.*Storage.*/Storage=auto/' ${D}${sysconfdir}/systemd/journald.conf

    if ${@bb.utils.contains('DISTRO_FEATURES','development-image','false','true',d)}; then
        # Non-development image
        if $(readlink autovt@.service) == "getty@*.service"; then
            rm ${D}/lib/systemd/system/autovt@.service
        fi
        find ${D} -name "getty@*.service" -delete
    fi

    install -d -m 0755 ${D}/srv
    install -d -m 0755 ${D}/${sysconfdir}/systemd/journald.conf.d

    # enable watchdog
    install -d -m 0755 ${D}/${sysconfdir}/systemd/system.conf.d
    install -m 0644 ${WORKDIR}/watchdog.conf ${D}/${sysconfdir}/systemd/system.conf.d

    install -d -m 0755 ${D}/${sysconfdir}/systemd/coredump.conf.d
    install -m 0644 ${WORKDIR}/coredump.conf ${D}/${sysconfdir}/systemd/coredump.conf.d

    ln -s ${datadir}/zoneinfo ${D}${sysconfdir}/localtime
    ln -s ../proc/self/mounts ${D}${sysconfdir}/mtab

    # resolv.conf is a static file containing the dnsmasq IP and deployed by dnsmasq package
    rm -rf ${D}/${sysconfdir}/resolv.conf

    # Install our custom resin target
    install -d ${D}${systemd_unitdir}/system/resin.target.wants
    install -d ${D}${sysconfdir}/systemd/system/resin.target.wants
    install -c -m 0644 ${WORKDIR}/resin.target ${D}${systemd_unitdir}/system/

    # multi-user will trigger resin-target
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.d/
    install -c -m 0644 ${WORKDIR}/multi-user.conf ${D}${sysconfdir}/systemd/system/multi-user.target.d/

    # We take care of journald flush ourselves
    rm ${D}/lib/systemd/system/sysinit.target.wants/systemd-journal-flush.service
}

# add pool.ntp.org as default ntp server
PACKAGECONFIG[ntp] = "--with-ntp-servers=0.resinio.pool.ntp.org 1.resinio.pool.ntp.org 2.resinio.pool.ntp.org 3.resinio.pool.ntp.org,,,"

PACKAGECONFIG_append = " ntp"

# Network configuration is managed by NetworkManager
PACKAGECONFIG_remove = "resolved networkd"

# Add missing users/groups defined in /usr/lib/sysusers.d/*
# In this time we avoid creating these at first boot
USERADD_PARAM_${PN} += "; --system systemd-bus-proxy; --system -d / -M --shell /bin/nologin -u 65534 nobody;"
GROUPADD_PARAM_${PN} += "; -r wheel; -r nobody;"
