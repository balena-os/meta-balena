DESCRIPTION = "Resin Supervisor packager"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit deploy

PR = "r5"

SRC_URI = " \
    file://Dockerfile \
    file://entry.sh \
    file://supervisor.conf \
    "
S = "${WORKDIR}"

PROVIDES="resin-supervisor"
RPROVIDES_${PN} = "resin-supervisor"

REPOSITORY_TAG = "${@bb.utils.contains('DISTRO_FEATURES', 'resin-staging', 'master', 'production', d)}"
PARTITION_SIZE ?= "1024"
LED_FILE ?= "/dev/null"

do_patch[noexec] = "1"
do_configure[noexec] = "1"

python () {
    # Get the recipe version from supervisor
    import subprocess

    target_repository = d.getVar('TARGET_REPOSITORY', True)
    version = d.getVar('REPOSITORY_TAG', True)

    pull_cmd = "docker pull %s:%s" % (target_repository, version)
    pull_output = subprocess.Popen(pull_cmd, shell=True, stdout=subprocess.PIPE).communicate()[0]

    version_cmd = "echo -n `docker inspect %s:%s | grep '\"VERSION=' | head -n 1 | tr -d ' ' | tr -d '\"' | tr -d 'VERSION=\"' `" % (target_repository, version)
    version_output = subprocess.Popen(version_cmd, shell=True, stdout=subprocess.PIPE).communicate()[0]
    if version_output == "":
        bb.fatal("Cannot fetch the version")
    d.setVar('PV', version_output)
}

do_compile () {
    if [ -z "${TARGET_REPOSITORY}" ]; then
        bbfatal "One or more needed variables are not available in resin-supervisor-disk. \
            Usually these are provided with a bbappend."
    fi
    touch -t 7805200000 ${WORKDIR}/entry.sh # Make sure docker rebuilds the image only if file is changed in content
    docker build -t looper -f ${WORKDIR}/Dockerfile ${WORKDIR}
    docker run --rm --privileged -e PARTITION_SIZE=${PARTITION_SIZE} -e TARGET_REPOSITORY=${TARGET_REPOSITORY} -e TARGET_TAG=${REPOSITORY_TAG} -v ${B}:/export looper
}

do_install () {
    install -d ${D}${sysconfdir}
    install -m 0755 ${WORKDIR}/supervisor.conf ${D}${sysconfdir}/
    sed -i -e 's:@TARGET_REPOSITORY@:${TARGET_REPOSITORY}:g' ${D}${sysconfdir}/supervisor.conf
    sed -i -e 's:@LED_FILE@:${LED_FILE}:g' ${D}${sysconfdir}/supervisor.conf
}

do_deploy () {
    install ${B}/data_disk.img ${DEPLOYDIR}/data_disk.img
    echo ${PV} > ${DEPLOYDIR}/VERSION
}

addtask deploy before do_package after do_install
PACKAGE_ARCH = "${MACHINE_ARCH}"
