FILESEXTRAPATHS:append := ":${THISDIR}/${PN}"

SYSTEMD_UNIT_NAMES = "extract-balena-ca"
inherit systemd balena-configurable

SYSTEMD_SERVICE:${PN} = "extract-balena-ca.service"

RDEPENDS:${PN}:class-target += "os-helpers-logging"

# Roots that chain to the compromised eMudhra intermediates (CVE-2026-111943).
# https://groups.google.com/a/mozilla.org/g/dev-security-policy/c/0R3XLJL6FuE
# https://bugs.debian.org/1151413
CA_DISTRUSTED_ROOTS = " \
    emSign_ECC_Root_CA_-_G3.crt \
    Comodo_AAA_Services_root.crt \
"

SRC_URI:append = " \
    file://extract-balena-ca \
    file://extract-balena-ca.service \
"

# Delete the distrusted roots before do_install, so that no bundle trusts them.
# The native bundle matters too, because the signing classes use it.
do_compile:append () {
    for crt in ${CA_DISTRUSTED_ROOTS}; do
        if [ -e ${B}/mozilla/${crt} ]; then
            rm ${B}/mozilla/${crt}
        else
            bbnote "ca-certificates ${PV} does not trust ${crt}, remove it from CA_DISTRUSTED_ROOTS"
        fi
    done
}

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
