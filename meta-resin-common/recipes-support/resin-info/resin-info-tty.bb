DESCRIPTION = "Resin TTY replacement file"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r0"

ALLOW_EMPTY_${PN} = "1"

SRC_URI = " \
    file://tty-replacement \
    file://tty-replacement.service \
    "
S = "${WORKDIR}"

inherit allarch systemd

RDEPENDS_${PN} = " \
    bash \
    "
SYSTEMD_SERVICE_${PN} = "${@bb.utils.contains('DISTRO_FEATURES', 'resin-staging', '', 'tty-replacement.service', d)}"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

do_install() {
   if ${@bb.utils.contains('DISTRO_FEATURES','resin-staging','false','true',d)}; then
       install -d ${D}${base_bindir}/
       install -m 0755 ${WORKDIR}/tty-replacement ${D}${base_bindir}/

       if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
           install -d ${D}${systemd_unitdir}/system
           install -c -m 0644 ${WORKDIR}/tty-replacement.service ${D}${systemd_unitdir}/system

           sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
               -e 's,@SBINDIR@,${sbindir},g' \
               -e 's,@BINDIR@,${bindir},g' \
               ${D}${systemd_unitdir}/system/*.service
       fi       
   fi
}
