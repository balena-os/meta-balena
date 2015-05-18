FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " file://tty-replacement"

do_install_append() {
    # do some getty changes if this is a production (not a staging) build
    if ${@bb.utils.contains('DISTRO_FEATURES','resin-staging','false','true',d)}; then
        # comment out getty respawn on serial console
        sed -i '/${SERIAL_CONSOLE}/s/^/# /g' ${D}${sysconfdir}/inittab

        # use /bin/tty-replacement to just print resin welcome screen
        sed -i 's|getty 38400|getty -n -l /bin/tty-replacement 38400|g' ${D}${sysconfdir}/inittab
        install -d ${D}${base_bindir}
        install -m 0755 ${WORKDIR}/tty-replacement ${D}${base_bindir}/tty-replacement
    fi
}

FILES_${PN} += "${base_bindir}/*"
