FILESEXTRAPATHS:append := ":${THISDIR}/${PN}"

SRC_URI:append = " \
    file://coredump.conf \
    file://reboot.target.conf \
    file://poweroff.target.conf \
    file://journald-balena-os.conf \
    file://vacuum.conf \
    file://watchdog.conf \
    file://os.conf \
    file://65-resin-update-state.rules \
    file://10-zram.rules \
    file://zram-swap-init \
    file://dev-zram0.swap \
    file://resin_update_state_probe \
    file://balena-os-sysctl.conf \
    file://getty-target-development-features.conf \
    file://getty-service-development-features.conf \
    file://disable-user-ns.conf \
    file://condition-virtualization-not-docker.conf \
    "

PACKAGECONFIG:remove = "nss-resolve"

python() {
    import re

    pv = d.getVar('PV', True)
    srcuri = d.getVar('SRC_URI', True)

    # Versions before 236 are affected by CVE-2017-15908
    # https://nvd.nist.gov/vuln/detail/CVE-2017-15908
    # Backport the relevant patch on the affected versions
    m = re.search('([0-9]*)\+*(.*)',pv)
    systemd_version = int(m.group(1))
    if systemd_version <= 229:
        d.setVar('SRC_URI', srcuri + ' file://0001-resolved-fix-loop-on-packets-with-pseudo-dns-types-229.patch')
    elif systemd_version < 236:
        d.setVar('SRC_URI', srcuri + ' file://0001-resolved-fix-loop-on-packets-with-pseudo-dns-types.patch')
}

FILES:${PN} += " \
    /srv \
    /etc/localtime \
    /etc/mtab \
    ${sysconfdir}/systemd/journald.conf.d \
    "

do_install:append() {
    # avoid file conflict with timeinit package
    rm -f ${D}${systemd_unitdir}/system/time-set.target

    install -d -m 0755 ${D}/${sysconfdir}/systemd/journald.conf.d
    install -m 06444 ${WORKDIR}/journald-balena-os.conf ${D}/${sysconfdir}/systemd/journald.conf.d

    # install drop-in configs to disable these services when running containerized
    install -d -m 0755 ${D}/${sysconfdir}/systemd/system/getty@.service.d
    install -m 0644 ${WORKDIR}/condition-virtualization-not-docker.conf \
        ${D}/${sysconfdir}/systemd/system/getty@.service.d
    install -d -m 0755 ${D}/${sysconfdir}/systemd/system/serial-getty@.service.d
    install -m 0644 ${WORKDIR}/condition-virtualization-not-docker.conf \
        ${D}/${sysconfdir}/systemd/system/serial-getty@.service.d
    install -d -m 0755 ${D}/${sysconfdir}/systemd/system/systemd-logind.service.d
    install -m 0644 ${WORKDIR}/condition-virtualization-not-docker.conf \
        ${D}/${sysconfdir}/systemd/system/systemd-logind.service.d

    # mask systemd-getty-generator
    install -d -m 0755 ${D}/${sysconfdir}/systemd/system-generators
    ln -sf /dev/null ${D}/${sysconfdir}/systemd/system-generators/systemd-getty-generator

    install -d -m 0755 ${D}/srv

    # shorten reboot/poweroff timeouts
    install -d -m 0755 ${D}/${sysconfdir}/systemd/system/reboot.target.d
    install -m 0644 ${WORKDIR}/reboot.target.conf ${D}/${sysconfdir}/systemd/system/reboot.target.d/
    install -d -m 0755 ${D}/${sysconfdir}/systemd/system/poweroff.target.d
    install -m 0644 ${WORKDIR}/poweroff.target.conf ${D}/${sysconfdir}/systemd/system/poweroff.target.d/

    # enable watchdog
    install -d -m 0755 ${D}/${sysconfdir}/systemd/system.conf.d
    install -m 0644 ${WORKDIR}/watchdog.conf ${D}/${sysconfdir}/systemd/system.conf.d

    # Add os specific conf
    install -d -m 0755 ${D}/${sysconfdir}/systemd/system.conf.d
    install -m 0644 ${WORKDIR}/os.conf ${D}/${sysconfdir}/systemd/system.conf.d

    install -d -m 0755 ${D}/${sysconfdir}/systemd/coredump.conf.d
    install -m 0644 ${WORKDIR}/coredump.conf ${D}/${sysconfdir}/systemd/coredump.conf.d

    ln -s ${datadir}/zoneinfo ${D}${sysconfdir}/localtime
    ln -s ../proc/self/mounts ${D}${sysconfdir}/mtab

    # We take care of journald flush ourselves
    rm ${D}/lib/systemd/system/sysinit.target.wants/systemd-journal-flush.service

    # Vacuum the journal to catch a corner case bug where the log bloats above limit
    install -d -m 0755 ${D}/${sysconfdir}/systemd/system/systemd-journald.service.d/
    install -m 0644 ${WORKDIR}/vacuum.conf ${D}/${sysconfdir}/systemd/system/systemd-journald.service.d/vacuum.conf

    install -m 0755 ${WORKDIR}/resin_update_state_probe ${D}/lib/udev/resin_update_state_probe
    install -m 0755 ${WORKDIR}/zram-swap-init ${D}/lib/udev/zram-swap-init

    # Move udev rules into /lib as /etc/udev/rules.d is bind mounted for custom rules
    mv ${D}/etc/udev/rules.d/*.rules ${D}/lib/udev/rules.d/

    install -d -m 0755 ${D}/usr/lib/sysctl.d/
    install -m 0644 ${WORKDIR}/balena-os-sysctl.conf ${D}/usr/lib/sysctl.d/

    if ${@bb.utils.contains('DISTRO_FEATURES', 'disable-user-ns', 'true', 'false', d)}; then
        install -m 0644 ${WORKDIR}/disable-user-ns.conf ${D}/usr/lib/sysctl.d/
    fi

    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/dev-zram0.swap ${D}${systemd_unitdir}/system/dev-zram0.swap

    # Do not start getty on production mode
    install -d -m 0755 ${D}${sysconfdir}/systemd/system/getty.target.d
    install -m 0644 ${WORKDIR}/getty-target-development-features.conf ${D}${sysconfdir}/systemd/system/getty.target.d/development-features.conf
    install -d -m 0755 ${D}${sysconfdir}/systemd/system/getty@.service.d
    install -m 0644 ${WORKDIR}/getty-service-development-features.conf ${D}${sysconfdir}/systemd/system/getty@.service.d/development-features.conf

    # We don't have audit configs enabled in the kernel, so we can remove the audit sockets
    rm ${D}/lib/systemd/system/sockets.target.wants/systemd-journald-audit.socket || true
    rm ${D}/lib/systemd/system/systemd-journald-audit.socket || true

    # Disable systemd-gpt-generator as it's currently a noop that just throws errors
    ln -s /dev/null ${D}${sysconfdir}/systemd/system-generators/systemd-gpt-auto-generator
}

PACKAGES =+ "${PN}-zram-swap"
SUMMARY:${PN}-zram-swap = "Enable compressed memory swap"
DESCRIPTION:${PN}-zram-swap = "Enable a already created ZRAM swap memory device."
SYSTEMD_PACKAGES += "${PN}-zram-swap"
FILES:${PN}-zram-swap = "\
    ${systemd_unitdir}/system/dev-zram0.swap \
"
SYSTEMD_SERVICE:${PN}-zram-swap += "dev-zram0.swap"

FILES:udev += "\
    ${rootlibexecdir}/udev/rules.d/touchscreen.rules \
    ${rootlibexecdir}/udev/rules.d/10-zram.rules \
    ${rootlibexecdir}/udev/rules.d/65-resin-update-state.rules \
    ${rootlibexecdir}/udev/resin_update_state_probe \
    ${rootlibexecdir}/udev/zram-swap-init           \
"

RDEPENDS:${PN}:append = " os-helpers-fs balena-ntp-config util-linux periodic-vacuum-logs"
RDEPENDS_${PN}:append = "${@oe.utils.conditional('SIGN_API','','',' lvm2-udevrules',d)}"

# Network configuration is managed by NetworkManager. ntp is managed by chronyd
PACKAGECONFIG:remove = "resolved networkd timesyncd"

PACKAGECONFIG:remove = "polkit"

# Add missing users/groups defined in /usr/lib/sysusers.d/*
# In this time we avoid creating these at first boot
USERADD_PARAM:${PN} += "; --system systemd-bus-proxy; --system -d / -M --shell /bin/nologin -u 65534 nobody;"
GROUPADD_PARAM:${PN} += "; -r wheel; -r nobody;"

# Clean up udev hardware database source files
pkg_postinst:udev-hwdb:append () {
    # These files have already been used to generate /etc/udev/hwdb.bin which is the only file used at runtime
    rm $D/lib/udev/hwdb.d/*
}
