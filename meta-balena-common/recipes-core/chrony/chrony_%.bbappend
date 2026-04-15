FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://balena_chrony.conf \
    file://chronyd.conf.systemd \
    file://chrony-helper \
    file://chrony-healthcheck \
    "
FILES:${PN} += "\
    ${libexecdir}/chrony-helper \
    ${libexecdir}/chrony-healthcheck \
"

RDEPENDS:${PN} = "bash healthdog"

S_UNPACK = "${@d.getVar('UNPACKDIR') or d.getVar('WORKDIR')}"

do_install:append() {
    install -m 0644 ${S_UNPACK}/balena_chrony.conf ${D}/${sysconfdir}/chrony.conf

    # Install systemd drop-in for chronyd.service
    install -d ${D}${sysconfdir}/systemd/system/chronyd.service.d
    install -m 0644 ${S_UNPACK}/chronyd.conf.systemd ${D}${sysconfdir}/systemd/system/chronyd.service.d/chronyd.conf
    install -d ${D}${libexecdir}
    install -m 0775 ${S_UNPACK}/chrony-helper ${D}${libexecdir}
    install -m 0775 ${S_UNPACK}/chrony-healthcheck ${D}${libexecdir}
}
