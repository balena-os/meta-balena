do_install:prepend() {
        sed -i '/systemd-udev-settle/d' \
            ${WORKDIR}/rngd.service
}
