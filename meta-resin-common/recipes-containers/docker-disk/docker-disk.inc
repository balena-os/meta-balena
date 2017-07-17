DESCRIPTION = "Docker data disk image generator"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "util-linux-native"

inherit deploy
require docker-utils.inc

SRC_URI = " \
    file://Dockerfile \
    file://entry.sh \
    "
S = "${WORKDIR}"

PROVIDES="docker-disk"
RPROVIDES_${PN} = "docker-disk"

PARTITION_SIZE ?= "1024"

do_patch[noexec] = "1"
do_configure[noexec] = "1"

do_compile () {
    if [ -z "${PARTITION_SIZE}" ]; then
        bbfatal "docker-disk: PARTITION_SIZE needs to have a value (megabytes)."
    fi

    # At this point we really need internet connectivity for building the looper
    if [ "x${@connected(d)}" != "xyes" ]; then
        bbfatal "docker-disk: Can't compile as there is no internet connectivity on this host."
    fi

    # Make sure there is at least one available loop device
    losetup -f > /dev/null 2>&1 || bbfatal "docker-disk: Host must have at least one available loop device."

    docker build -t looper -f ${WORKDIR}/Dockerfile ${WORKDIR}
    docker run --rm --privileged -e DOCKER_STORAGE=${DOCKER_STORAGE} -e PARTITION_SIZE=${PARTITION_SIZE} -e TARGET_REPOSITORY=${TARGET_REPOSITORY} -e TARGET_TAG=${TARGET_TAG} -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v ${B}:/export looper
}
do_compile[vardeps] += "PARTITION_SIZE TARGET_REPOSITORY TARGET_TAG"

do_deploy () {
    install ${B}/resin-data.img ${DEPLOYDIR}/resin-data.img
}
addtask deploy before do_package after do_install

PACKAGE_ARCH = "${MACHINE_ARCH}"
