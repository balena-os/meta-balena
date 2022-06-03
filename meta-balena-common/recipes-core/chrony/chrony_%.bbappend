FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://chrony.conf \
    file://chronyd.conf.systemd \
    file://chrony-helper \
    file://chrony-sync-check.service \
    file://chrony-sync-check.timer \
    file://chronyd-sync-check.sh \
    "
FILES:${PN} += "\
    ${libexecdir}/chrony-helper \
    ${libexecdir}/chronyd-sync-check"

RDEPENDS:${PN} = "bash"

SYSTEMD_SERVICE:${PN} += "\
    chrony-sync-check.service \
    chrony-sync-check.timer \
"

do_install:append() {
    install -m 0644 ${WORKDIR}/chrony.conf ${D}/${sysconfdir}/chrony.conf

    # Install systemd drop-in for chronyd.service
    install -d ${D}${sysconfdir}/systemd/system/chronyd.service.d
    install -m 0644 ${WORKDIR}/chronyd.conf.systemd ${D}${sysconfdir}/systemd/system/chronyd.service.d/chronyd.conf
    install -d ${D}${libexecdir}
    install -m 0775 ${WORKDIR}/chrony-helper ${D}${libexecdir}

    install -d ${D}${systemd_unitdir}/system/
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants/
    install -c -m 0755 ${WORKDIR}/chronyd-sync-check.sh ${D}${libexecdir}/chronyd-sync-check
    install -c -m 0644 ${WORKDIR}/chrony-sync-check.service ${D}${systemd_unitdir}/system
    install -c -m 0644 ${WORKDIR}/chrony-sync-check.timer ${D}${systemd_unitdir}/system
}
