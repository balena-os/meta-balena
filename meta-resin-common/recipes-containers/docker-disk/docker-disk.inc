DESCRIPTION = "Docker data disk image generator"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "util-linux-native e2fsprogs-native"

inherit deploy
require docker-utils.inc

SRC_URI = " \
    file://Dockerfile \
    file://entry.sh \
    "
S = "${WORKDIR}"
B = "${S}/build"

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

    # We force the PATH to be the standard linux path in order to use the host's
    # docker daemon instead of the result of docker-native. This avoids version
    # mismatches
    DOCKER=$(PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" which docker)

    # Populate ${B}/resin-data
    RANDOM=$$
    _image_name="docker-disk-$RANDOM"
    _container_name="docker-disk-$RANDOM"
    $DOCKER rmi ${_image_name} || true
    $DOCKER build -t ${_image_name} -f ${WORKDIR}/Dockerfile ${WORKDIR}
    mkdir -p ${B}/resin-data
    $DOCKER run --privileged --rm -e BALENA_STORAGE=${BALENA_STORAGE} \
        -e USER_ID=$(id -u) -e USER_GID=$(id -u) \
        -e TARGET_REPOSITORY=${TARGET_REPOSITORY} -e TARGET_TAG=${TARGET_TAG} \
        -e PRIVATE_REGISTRY="${PRIVATE_REGISTRY}" \
        -e PRIVATE_REGISTRY_USER="${PRIVATE_REGISTRY_USER}" \
        -e PRIVATE_REGISTRY_PASSWORD="${PRIVATE_REGISTRY_PASSWORD}" \
        -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v ${B}/resin-data:/resin-data \
        --name ${_container_name} ${_image_name}
    docker rmi ${_image_name}
}

fakeroot do_create_resin_data_partition() {
    # Create the ext4 partition out of ${B}/resin-data
    dd if=/dev/zero of=${B}/resin-data.img bs=1M count=0 seek=${PARTITION_SIZE}
    chown -R root:root ${B}/resin-data
    mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 -i 8192 -d ${B}/resin-data -F ${B}/resin-data.img
}
addtask create_resin_data_partition before do_install after do_compile

do_deploy () {
    install ${B}/resin-data.img ${DEPLOYDIR}/resin-data.img
}
addtask deploy before do_package after do_install

PACKAGE_ARCH = "${MACHINE_ARCH}"
