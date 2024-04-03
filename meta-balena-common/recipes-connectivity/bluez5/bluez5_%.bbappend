FILESEXTRAPATHS:append := ":${THISDIR}/files"

SRC_URI += " \
    file://10-local-bt-hci-up.rules \
    file://bluetooth.conf.systemd \
    file://main.conf \
    "

do_install:append() {
    install -D -m 0755 ${WORKDIR}/10-local-bt-hci-up.rules ${D}/${nonarch_base_libdir}/udev/rules.d/10-local-bt-hci-up.rules

    install -d ${D}${sysconfdir}/systemd/system/bluetooth.service.d
    install -m 0644 ${WORKDIR}/bluetooth.conf.systemd ${D}${sysconfdir}/systemd/system/bluetooth.service.d/bluetooth.conf
    sed -i "s,@pkglibexecdir@,${libexecdir},g" ${D}${sysconfdir}/systemd/system/bluetooth.service.d/bluetooth.conf

    install -d ${D}/var/lib/bluetooth
    install -d ${D}${sysconfdir}/bluetooth
    install -m 0644 ${WORKDIR}/main.conf ${D}${sysconfdir}/bluetooth/main.conf
}

PACKAGECONFIG:append = " sixaxis"

# package some test binaries and other misc util binaries in a separate package which we won't include in the rootfs
PACKAGES =+ "${PN}-test-bins"
FILES:${PN}-test-bins = "\
    ${bindir}/*test \
    ${bindir}/btmon \
    ${bindir}/l2ping \
    ${bindir}/mpris-proxy \
"
