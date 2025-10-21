SUMMARY = "Graceful shutdown test service for signal propagation testing"
DESCRIPTION = "Test service to reproduce and debug signal handling during systemd shutdown"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://signal-test.c \
    file://Dockerfile \
    file://start-graceful-shutdown \
    file://graceful-shutdown-healthcheck \
    file://graceful-shutdown.service \
    file://spawn-multiple-sig-catcher \
    file://spawn-multiple-sig-catcher.service \
"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "graceful-shutdown.service spawn-multiple-sig-catcher.service"

RDEPENDS:${PN} = " \
    balena \
    systemd \
    healthdog \
    bash \
"

do_compile() {
    ${CC} ${CFLAGS} ${LDFLAGS} -static -o signal-test ${WORKDIR}/signal-test.c
}

do_install() {
    # Install the signal-test binary
    install -d ${D}${bindir}
    install -m 0755 ${B}/signal-test ${D}${bindir}/signal-test
    install -m 0755 ${WORKDIR}/spawn-multiple-sig-catcher ${D}${bindir}/spawn-multiple-sig-catcher

    # Install scripts and Dockerfile to /usr/lib/graceful-shutdown
    install -d ${D}${libdir}/graceful-shutdown
    install -m 0755 ${WORKDIR}/start-graceful-shutdown ${D}${libdir}/graceful-shutdown/
    install -m 0755 ${WORKDIR}/graceful-shutdown-healthcheck ${D}${libdir}/graceful-shutdown/
    install -m 0644 ${WORKDIR}/Dockerfile ${D}${libdir}/graceful-shutdown/
    install -m 0755 ${B}/signal-test ${D}${libdir}/graceful-shutdown/

    # Install systemd services
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/graceful-shutdown.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${WORKDIR}/spawn-multiple-sig-catcher.service ${D}${systemd_system_unitdir}/
    
    # Substitute @BINDIR@
    sed -i -e 's,@BINDIR@,${bindir},g' ${D}${systemd_system_unitdir}/graceful-shutdown.service
}

FILES:${PN} += " \
    ${bindir}/signal-test \
    ${bindir}/spawn-multiple-sig-catcher \
    ${libdir}/graceful-shutdown/start-graceful-shutdown \
    ${libdir}/graceful-shutdown/graceful-shutdown-healthcheck \
    ${libdir}/graceful-shutdown/Dockerfile \
    ${libdir}/graceful-shutdown/signal-test \
    ${systemd_system_unitdir}/graceful-shutdown.service \
    ${systemd_system_unitdir}/spawn-multiple-sig-catcher.service \
"

# Service is not enabled by default - manual testing only
SYSTEMD_AUTO_ENABLE = "disable"

