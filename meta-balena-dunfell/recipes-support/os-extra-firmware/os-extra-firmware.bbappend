FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://os-extra-firmware-override.conf"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}/os-extra-firmware.service.d
    install -m 0644 ${WORKDIR}/os-extra-firmware-override.conf ${D}${systemd_system_unitdir}/os-extra-firmware.service.d/

    sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_system_unitdir}/os-extra-firmware.service.d/*
}

FILES:${PN} += "${systemd_system_unitdir}/os-extra-firmware.service.d/os-extra-firmware-override.conf"
