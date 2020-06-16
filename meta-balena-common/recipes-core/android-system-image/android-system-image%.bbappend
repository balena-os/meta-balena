FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

inherit systemd

RDEPENDS_${PN}_append = " os-helpers-logging"

SRC_URI_append_ = " \
    file://android-mounter.service \
    file://android-image-mounter \
"

SYSTEMD_SERVICE_${PN} += " \
    android-mounter.service \
"

do_install_append() {
    for i in rootfs cache factory firmware persist system; do
        install -d ${D}/android/$i
    done

    for i in aboot firmware imgdata misc radio recovery rpm sbl1 sdi tz; do
        install -d ${D}/android/$i
        ln -sf /android/$i ${D}/$i
    done

    rm -rf ${D}/data
    ln -sf /resin-data/android-data ${D}/data

    install -d ${D}${bindir}
    install -m 755 ${WORKDIR}/android-image-mounter ${D}${bindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/android-mounter.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}

FILES_${PN}_append = " \
    ${bindir}/android-image-mounter \
    /aboot /firmware /imgdata /misc /radio /recovery /rpm /sbl1 /sdi /tz \
    /android/aboot /android/firmware /android/imgdata /android/misc /android/radio /android/recovery /android/rpm /android/sbl1 /android/sdi /android/tz \
    /android/rootfs /android/cache /android/factory /android/firmware /android/persist /android/system \
"
