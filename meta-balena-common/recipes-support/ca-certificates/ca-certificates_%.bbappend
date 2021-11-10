FILESEXTRAPATHS:append := ":${THISDIR}/${PN}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "extract-balena-ca.service"

RDEPENDS:${PN}:class-target += "os-helpers-logging"

SRC_URI:append = " \
    file://extract-balena-ca \
    file://extract-balena-ca.service \
"

do_install:append:class-target () {
    # Create a drop-in directory for balena-controlled CAs
    install -d ${D}/usr/share/ca-certificates/balena/

    # Add a service to regenerate CA chain on update
    install -d ${D}${bindir}/
    install -m 0755 ${WORKDIR}/extract-balena-ca ${D}${bindir}/

    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/extract-balena-ca.service ${D}${systemd_unitdir}/system/

    # Make update-ca-certificates use our directory instead of the non-existing default
    sed -i -e "s,^LOCALCERTSDIR=.*$,LOCALCERTSDIR=\$SYSROOT/usr/share/ca-certificates/balena," ${D}/usr/sbin/update-ca-certificates
}

FILES:${PN} += " \
    ${bindir}/extract-balena-ca \
    ${systemd_unitdir}/system/extract-balena-ca.service \
"
