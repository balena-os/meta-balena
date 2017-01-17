require docker-disk.inc

# Resin supervisor supported CPU archtectures
SUPERVISOR_REPOSITORY_armv5 = "resin/armel-supervisor"
SUPERVISOR_REPOSITORY_armv6 = "resin/rpi-supervisor"
SUPERVISOR_REPOSITORY_armv7a = "resin/armv7hf-supervisor"
SUPERVISOR_REPOSITORY_aarch64 = "resin/armv7hf-supervisor"
SUPERVISOR_REPOSITORY_x86 = "resin/i386-supervisor"
SUPERVISOR_REPOSITORY_x86-64 = "resin/amd64-supervisor"

SUPERVISOR_TAG ?= "v2.9.0"
TARGET_REPOSITORY ?= "${SUPERVISOR_REPOSITORY}"
TARGET_TAG ?= "${SUPERVISOR_TAG}"
LED_FILE ?= "/dev/null"

inherit systemd

SRC_URI += " \
    file://resin-data.mount \
    file://supervisor.conf \
    file://resin-supervisor.service \
    file://update-resin-supervisor \
    file://update-resin-supervisor.service \
    file://update-resin-supervisor.timer \
    file://resin.target \
    file://multi-user.conf \
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
    resin-device-uuid \
    "

python () {
    # Get the recipe version from supervisor
    import subprocess

    target_repository = d.getVar('TARGET_REPOSITORY', True)
    supervisor_repository = d.getVar('SUPERVISOR_REPOSITORY', True)
    tag_repository = d.getVar('TARGET_TAG', True)

    if not supervisor_repository:
        bb.fatal("resin-supervisor-disk: There is no support for this architecture.")

    # Version 0.0.0 means that the supervisor image was either not preloaded or a custom image was preloaded
    if target_repository == "" or target_repository != supervisor_repository:
        d.setVar('SUPERVISOR_VERSION','0.0.0')
        d.setVar('PV','0.0.0')
        return

    # Only pull if connectivity - to avoid warnings and delay
    if connected(d) == "yes":
        pull_cmd = "docker pull %s:%s" % (target_repository, tag_repository)
        pull_output = subprocess.Popen(pull_cmd, shell=True, stdout=subprocess.PIPE).communicate()[0]
    else:
        bb.warn("resin-supervisor-disk: No connectivity, skipped pulling supervisor image.")

    # Inspect for fetching the version only if image exists
    # on Fedora 23 at least, docker has suffered slight changes (https://bugzilla.redhat.com/show_bug.cgi?id=1312934)
    # hence we need the following workaround until the above bug is fixed:
    imagechk_cmd = "docker images | grep '^\S*%s\s*%s'" % (target_repository, tag_repository)
    imagechk_output = subprocess.Popen(imagechk_cmd, shell=True, stdout=subprocess.PIPE).communicate()[0]
    if imagechk_output == "":
        bb.fatal("resin-supervisor-disk: No local supervisor images found.")
    version_cmd = "echo -n $(docker inspect %s:%s | jq --raw-output '.[0].Config.Env[] | select(startswith(\"VERSION=\")) | split(\"VERSION=\") | .[1]')" % (target_repository, tag_repository)
    version_output = subprocess.Popen(version_cmd, shell=True, stdout=subprocess.PIPE).communicate()[0]
    if sys.version_info.major >= 3 :
        version_output = version_output.decode()
    if version_output == "" or version_output == None:
        bb.fatal("resin-supervisor-disk: Cannot fetch version.")
    image_id_cmd = "echo -n $(docker inspect -f '{{.Id}}' %s:%s)" % (target_repository, tag_repository)
    image_id_output = subprocess.Popen(image_id_cmd, shell=True, stdout=subprocess.PIPE).communicate()[0]
    if sys.version_info.major >= 3 :
        image_id_output = image_id_output.decode()
    if image_id_output == "" or image_id_output == None:
        bb.fatal("resin-supervisor-disk: Cannot fetch image id.")
    d.setVar('SUPERVISOR_VERSION', "%s-%s" % (version_output, image_id_output.split(':',1)[-1][:12]))
    d.setVar('PV', "%s+%s" % (version_output, image_id_output.split(':',1)[-1]))
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

    # Install our custom resin target
    install -d ${D}${systemd_unitdir}/system/resin.target.wants
    install -d ${D}${sysconfdir}/systemd/system/resin.target.wants

    install -c -m 0644 ${WORKDIR}/resin.target ${D}${systemd_unitdir}/system/

    # Install drop in to introduce dependecies on multi-user target
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.d/
    install -c -m 0644 ${WORKDIR}/multi-user.conf ${D}${sysconfdir}/systemd/system/multi-user.target.d/
}
do_install[vardeps] += "DISTRO_FEATURES TARGET_REPOSITORY LED_FILE"

do_deploy_append () {
    echo ${SUPERVISOR_VERSION} > ${DEPLOYDIR}/VERSION
}
