FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://chronyd.conf.systemd \
    file://chrony-helper \
    file://chrony-healthcheck \
    "
FILES:${PN} += "\
    ${libexecdir}/chrony-helper \
    ${libexecdir}/chrony-healthcheck \
"

RDEPENDS:${PN} = "bash healthdog"

do_install:append() {
    # Install systemd drop-in for chronyd.service
    install -d ${D}${sysconfdir}/systemd/system/chronyd.service.d
    install -m 0644 ${UNPACKDIR}/chronyd.conf.systemd ${D}${sysconfdir}/systemd/system/chronyd.service.d/chronyd.conf
    install -d ${D}${libexecdir}
    install -m 0775 ${UNPACKDIR}/chrony-helper ${D}${libexecdir}
    install -m 0775 ${UNPACKDIR}/chrony-healthcheck ${D}${libexecdir}
}
