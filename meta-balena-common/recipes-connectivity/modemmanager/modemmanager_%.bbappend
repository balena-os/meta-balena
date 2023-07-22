FILESEXTRAPATHS:append := ":${THISDIR}/balena-files"
SYSTEMD_AUTO_ENABLE = "enable"

SRC_URI:append = " \
    file://77-mm-huawei-configuration.rules \
    file://mm-huawei-configuration-switch.sh \
    file://77-mm-u-blox-modeswitch.rules \
    file://u-blox-switch@.service \
    file://u-blox-switch.sh \
    file://ModemManager.conf.systemd \
    file://0001-increase-qmi-port-open-timeout.patch \
"

PACKAGECONFIG:remove = "polkit"

do_install:append() {
    install -d ${D}${base_libdir}/udev/rules.d/
    install -m 0644 ${WORKDIR}/77-mm-huawei-configuration.rules ${D}${base_libdir}/udev/rules.d/
    install -m 0755 ${WORKDIR}/mm-huawei-configuration-switch.sh ${D}${base_libdir}/udev/
    install -m 0644 ${WORKDIR}/77-mm-u-blox-modeswitch.rules ${D}${base_libdir}/udev/rules.d
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/u-blox-switch.sh ${D}${bindir}
    install -d ${D}${systemd_unitdir}/system/ModemManager.service.d
    install -m 0644 ${WORKDIR}/ModemManager.conf.systemd ${D}${systemd_unitdir}/system/ModemManager.service.d/ModemManager.conf
    install -m 0644 ${WORKDIR}/u-blox-switch@.service ${D}${systemd_unitdir}/system
}

FILES:${PN} += " \
    ${base_libdir}/udev/rules.d/77-mm-huawei-configuration.rules \
    ${base_libdir}/udev/mm-huawei-configuration-switch.sh \
    ${base_libdir}/udev/rules.d/77-mm-u-blox-modeswitch.rules \
    ${systemd_unitdir}/system/u-blox-switch@.service \
    ${bindir}/u-blox-switch.sh \
    ${systemd_unitdir}/system/ModemManager.service.d/ModemManager.conf \
    "
