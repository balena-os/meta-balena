SUMMARY = "Graceful shutdown test service for signal propagation testing"
DESCRIPTION = "Test service to reproduce and debug signal handling during systemd shutdown"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

# Installation paths for graceful-shutdown files
GRACEFUL_SHUTDOWN_LIB_DIR = "${libdir}/graceful-shutdown"
GRACEFUL_SHUTDOWN_RUNTIME_DIR = "/mnt/state/graceful-shutdown"

SRC_URI = " \
    file://signal-test.c \
    file://Dockerfile \
    file://start-graceful-shutdown \
    file://graceful-shutdown-healthcheck \
    file://graceful-shutdown.service \
    file://spawn-multiple-sig-catcher \
    file://spawn-multiple-sig-catcher.service \
    file://setup-graceful-shutdown \
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
    # Install everything to /usr/lib/graceful-shutdown
    install -d ${D}${GRACEFUL_SHUTDOWN_LIB_DIR}
    install -m 0755 ${WORKDIR}/start-graceful-shutdown ${D}${GRACEFUL_SHUTDOWN_LIB_DIR}/
    install -m 0755 ${WORKDIR}/graceful-shutdown-healthcheck ${D}${GRACEFUL_SHUTDOWN_LIB_DIR}/
    install -m 0755 ${WORKDIR}/spawn-multiple-sig-catcher ${D}${GRACEFUL_SHUTDOWN_LIB_DIR}/
    install -m 0644 ${WORKDIR}/Dockerfile ${D}${GRACEFUL_SHUTDOWN_LIB_DIR}/
    install -m 0755 ${B}/signal-test ${D}${GRACEFUL_SHUTDOWN_LIB_DIR}/
    
    # Install setup script to /usr/sbin
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/setup-graceful-shutdown ${D}${sbindir}/

    # Install systemd services
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/graceful-shutdown.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${WORKDIR}/spawn-multiple-sig-catcher.service ${D}${systemd_system_unitdir}/
    
    # Substitute variables in service files
    sed -i -e 's,@BINDIR@,${bindir},g' \
           -e 's,@GRACEFUL_SHUTDOWN_RUNTIME_DIR@,${GRACEFUL_SHUTDOWN_RUNTIME_DIR},g' \
        ${D}${systemd_system_unitdir}/graceful-shutdown.service
    
    sed -i -e 's,@GRACEFUL_SHUTDOWN_RUNTIME_DIR@,${GRACEFUL_SHUTDOWN_RUNTIME_DIR},g' \
        ${D}${systemd_system_unitdir}/spawn-multiple-sig-catcher.service
    
    # Substitute variables in scripts
    sed -i -e 's,@GRACEFUL_SHUTDOWN_RUNTIME_DIR@,${GRACEFUL_SHUTDOWN_RUNTIME_DIR},g' \
        ${D}${GRACEFUL_SHUTDOWN_LIB_DIR}/start-graceful-shutdown
    
    sed -i -e 's,@GRACEFUL_SHUTDOWN_RUNTIME_DIR@,${GRACEFUL_SHUTDOWN_RUNTIME_DIR},g' \
        ${D}${GRACEFUL_SHUTDOWN_LIB_DIR}/spawn-multiple-sig-catcher
    
    # Substitute variables in setup script
    sed -i -e 's,@GRACEFUL_SHUTDOWN_LIB_DIR@,${GRACEFUL_SHUTDOWN_LIB_DIR},g' \
           -e 's,@GRACEFUL_SHUTDOWN_RUNTIME_DIR@,${GRACEFUL_SHUTDOWN_RUNTIME_DIR},g' \
        ${D}${sbindir}/setup-graceful-shutdown
}

FILES:${PN} += " \
    ${GRACEFUL_SHUTDOWN_LIB_DIR}/signal-test \
    ${GRACEFUL_SHUTDOWN_LIB_DIR}/spawn-multiple-sig-catcher \
    ${GRACEFUL_SHUTDOWN_LIB_DIR}/start-graceful-shutdown \
    ${GRACEFUL_SHUTDOWN_LIB_DIR}/graceful-shutdown-healthcheck \
    ${GRACEFUL_SHUTDOWN_LIB_DIR}/Dockerfile \
    ${sbindir}/setup-graceful-shutdown \
    ${systemd_system_unitdir}/graceful-shutdown.service \
    ${systemd_system_unitdir}/spawn-multiple-sig-catcher.service \
"

# Service is not enabled by default - manual testing only
SYSTEMD_AUTO_ENABLE = "disable"

