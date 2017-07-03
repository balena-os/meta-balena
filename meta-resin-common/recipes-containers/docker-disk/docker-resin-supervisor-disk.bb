require docker-disk.inc

# Resin supervisor supported CPU archtectures
SUPERVISOR_REPOSITORY_armv5 = "resin/armel-supervisor"
SUPERVISOR_REPOSITORY_armv6 = "resin/rpi-supervisor"
SUPERVISOR_REPOSITORY_armv7a = "resin/armv7hf-supervisor"
SUPERVISOR_REPOSITORY_armv7ve = "resin/armv7hf-supervisor"
SUPERVISOR_REPOSITORY_aarch64 = "resin/aarch64-supervisor"
SUPERVISOR_REPOSITORY_x86 = "resin/i386-supervisor"
SUPERVISOR_REPOSITORY_x86-64 = "resin/amd64-supervisor"

SUPERVISOR_TAG ?= "v5.1.0"
TARGET_REPOSITORY ?= "${SUPERVISOR_REPOSITORY}"
TARGET_TAG ?= "${SUPERVISOR_TAG}"
LED_FILE ?= "/dev/null"

inherit systemd

SRC_URI += " \
    file://resin-data.mount \
    file://start-resin-supervisor \
    file://supervisor.conf \
    file://resin-supervisor.service \
    file://update-resin-supervisor \
    file://update-resin-supervisor.service \
    file://update-resin-supervisor.timer \
    "

SYSTEMD_SERVICE_${PN} = " \
    resin-supervisor.service \
    update-resin-supervisor.service \
    update-resin-supervisor.timer \
    "

FILES_${PN} += " \
    /resin-data \
    ${systemd_unitdir} \
    ${sysconfdir} \
    "

RDEPENDS_${PN} = " \
    bash \
    docker \
    coreutils \
    resin-vars \
    systemd \
    curl \
    resin-unique-key \
    "

python () {
    target_repository = d.getVar('TARGET_REPOSITORY', True)
    supervisor_repository = d.getVar('SUPERVISOR_REPOSITORY', True)
    tag_repository = d.getVar('TARGET_TAG', True)

    if not supervisor_repository:
        bb.fatal("resin-supervisor-disk: There is no support for this architecture.")

    # Version 0.0.0 means that the supervisor image was either not preloaded or a custom image was preloaded
    if target_repository == "" or target_repository != supervisor_repository:
        d.setVar('SUPERVISOR_VERSION','0.0.0')
        d.setVar('PV','0.0.0')
    else:
        d.setVar('SUPERVISOR_VERSION', "%s" % tag_repository)
        d.setVar('PV', "%s" % tag_repository)
}

do_install () {
    # Generate supervisor conf
    install -d ${D}${sysconfdir}/resin-supervisor/
    install -m 0755 ${WORKDIR}/supervisor.conf ${D}${sysconfdir}/resin-supervisor/
    sed -i -e 's:@SUPERVISOR_REPOSITORY@:${SUPERVISOR_REPOSITORY}:g' ${D}${sysconfdir}/resin-supervisor/supervisor.conf
    sed -i -e 's:@LED_FILE@:${LED_FILE}:g' ${D}${sysconfdir}/resin-supervisor/supervisor.conf
    sed -i -e 's:@SUPERVISOR_TAG@:${SUPERVISOR_TAG}:g' ${D}${sysconfdir}/resin-supervisor/supervisor.conf

    install -d ${D}/resin-data

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/update-resin-supervisor ${D}${bindir}
    install -m 0755 ${WORKDIR}/start-resin-supervisor ${D}${bindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system

        # Yocto gets confused if we use strange file names - so we rename it here
        # https://bugzilla.yoctoproject.org/show_bug.cgi?id=8161
        install -c -m 0644 ${WORKDIR}/resin-data.mount ${D}${systemd_unitdir}/system/resin\\x2ddata.mount

        install -c -m 0644 ${WORKDIR}/resin-supervisor.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/update-resin-supervisor.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/update-resin-supervisor.timer ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}
do_install[vardeps] += "DISTRO_FEATURES TARGET_REPOSITORY LED_FILE"

do_deploy_append () {
    echo ${SUPERVISOR_VERSION} > ${DEPLOYDIR}/VERSION
}
