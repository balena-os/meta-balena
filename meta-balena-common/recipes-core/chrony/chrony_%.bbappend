FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://chrony.conf \
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
    install -m 0644 ${WORKDIR}/chrony.conf ${D}/${sysconfdir}/chrony.conf

    # Install systemd drop-in for chronyd.service
    install -d ${D}${sysconfdir}/systemd/system/chronyd.service.d
    install -m 0644 ${WORKDIR}/chronyd.conf.systemd ${D}${sysconfdir}/systemd/system/chronyd.service.d/chronyd.conf
    install -d ${D}${libexecdir}
    install -m 0775 ${WORKDIR}/chrony-helper ${D}${libexecdir}
    install -m 0775 ${WORKDIR}/chrony-healthcheck ${D}${libexecdir}
}
