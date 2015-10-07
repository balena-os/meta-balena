FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

do_install_append() {
    # do some getty changes if this is a production (not a staging) build
    if ${@bb.utils.contains('DISTRO_FEATURES','resin-staging','false','true',d)}; then
        # comment out getty respawn on serial console
        sed -i '/${SERIAL_CONSOLE}/s/^/# /g' ${D}${sysconfdir}/inittab
    fi
}
