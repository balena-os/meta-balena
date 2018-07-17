DESCRIPTION = "Resin info"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

ALLOW_EMPTY_${PN} = "1"

SRC_URI = " \
    file://resin-info \
    file://resin-info@.service \
    "
S = "${WORKDIR}"

inherit allarch

TTYS = "tty1"

RDEPENDS_${PN} = "bash"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

do_install() {
    install -d ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/resin-info ${D}${sbindir}/

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system/
        install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants/
        install -m 0644 ${WORKDIR}/resin-info@.service ${D}${systemd_unitdir}/system/

        if ${@bb.utils.contains('DISTRO_FEATURES','development-image','true','false',d)}; then
            # Enable services
            for ttydev in ${TTYS}; do
                ln -sf ${systemd_unitdir}/system/resin-info@.service \
                    ${D}${sysconfdir}/systemd/system/multi-user.target.wants/resin-info@$ttydev.service
            done
        fi

        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}

FILES_${PN} += "${systemd_unitdir}/system/*.service ${sysconfdir}"
