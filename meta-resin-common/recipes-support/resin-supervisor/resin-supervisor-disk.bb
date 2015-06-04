DESCRIPTION = "Resin Supervisor packager"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
DEPENDS = "util-linux-native"

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

RESIN_CHECK_CONN_URL ?= "index.docker.io"
DOCKER_PID_FILE ?= "/var/run/docker.pid"

# Check if host can reach a specific URL
# Used for connectivity check
def connected(d):
    import socket

    REMOTE_SERVER = d.getVar('RESIN_CHECK_CONN_URL', True)
    try:
        host = socket.gethostbyname(REMOTE_SERVER)
        socket.create_connection((host, 80), 2)
        return "yes"
    except:
        pass
    return "no"

# Check if docker is running and usable for current user
def usable_docker(d):
    import os, subprocess

    # Check docker is running
    pid_file = d.getVar('DOCKER_PID_FILE', True)
    try:
        f = open(pid_file, 'r')
    except:
        return "no"
    pid = f.read()
    f.close
    if not os.path.exists("/proc/%s" % pid):
        return "no"

    # Test docker execute permission
    cmd = "docker images > /dev/null 2>&1"
    child = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    cmd_output = child.communicate()[0]
    if child.returncode != 0:
        return "no"

    return "yes"

python () {
    # Get the recipe version from supervisor
    import subprocess

    target_repository = d.getVar('TARGET_REPOSITORY', True)
    tag_repository = d.getVar('REPOSITORY_TAG', True)

    if not target_repository:
        bb.fatal("resin-supervisor-disk: One or more needed variables are not available in resin-supervisor-disk. Usually these are provided with a bbappend.")

    # We need docker
    if usable_docker(d) != "yes":
        bb.fatal("resin-supervisor-disk: Docker needs to run on your host and current user must be able to use it.")

    # Only pull if connectivity - to avoid warnings and delay
    if connected(d) == "yes":
        pull_cmd = "docker pull %s:%s" % (target_repository, tag_repository)
        pull_output = subprocess.Popen(pull_cmd, shell=True, stdout=subprocess.PIPE).communicate()[0]

    # Inspect for fetching the version only if image exists
    imagechk_cmd = "docker images | grep %s | grep %s" % (target_repository, tag_repository)
    imagechk_output = subprocess.Popen(imagechk_cmd, shell=True, stdout=subprocess.PIPE).communicate()[0]
    if imagechk_output == "":
        bb.fatal("resin-supervisor-disk: No local supervisor images found.")
    version_cmd = "echo -n `docker inspect %s:%s | grep '\"VERSION=' | head -n 1 | tr -d ' ' | tr -d '\"' | tr -d 'VERSION=\"' `" % (target_repository, tag_repository)
    version_output = subprocess.Popen(version_cmd, shell=True, stdout=subprocess.PIPE).communicate()[0]
    if version_output == "" or version_output == None:
        bb.fatal("resin-supervisor-disk: Cannot fetch version.")
    d.setVar('PV', version_output)
}

do_patch[noexec] = "1"
do_configure[noexec] = "1"

do_compile () {
    if [ -z "${TARGET_REPOSITORY}" ]; then
        bbfatal "resin-supervisor-disk: One or more needed variables are not available in resin-supervisor-disk. Usually these are provided with a bbappend."
    fi

    # This time we really need internet connectivity for building the looper
    if [ "x${@connected(d)}" != "xyes" ]; then
        bbfatal "resin-supervisor-disk: Can't compile as there is no internet connectivity on this host."
    fi

    # Make sure there is at least one available loop device
    losetup -f > /dev/null 2>&1 || bbfatal "resin-supervisor-disk: Host must have at least one available loop device."

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
