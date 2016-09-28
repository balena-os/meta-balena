do_install_append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','development-image','false','true',d)}; then
        if [ ! -z "${SERIAL_CONSOLES}" ] ; then
            tmp="${SERIAL_CONSOLES}"
            for entry in $tmp ; do
                    baudrate=`echo $entry | sed 's/\;.*//'`
                    ttydev=`echo $entry | sed -e 's/^[0-9]*\;//' -e 's/\;.*//'`
                    if [ "$baudrate" = "$default_baudrate" ] ; then
                            # disable the service
                            rm -rf ${D}${sysconfdir}/systemd/system/getty.target.wants/serial-getty@$ttydev.service
                    else
                            # disable the service
                            rm -rf ${D}${sysconfdir}/systemd/system/getty.target.wants/serial-getty$baudrate@$ttydev.service
                    fi
            done
        fi
    fi
}
