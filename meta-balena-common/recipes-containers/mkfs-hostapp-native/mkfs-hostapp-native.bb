SUMMARY = "Resin hostapp rootfs creation tool"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://Dockerfile \
    file://create.ext4 \
    file://mkfs.hostapp \
    "

inherit native

DEPENDS = " \
    balena-native \
    hostapp-update-native \
    e2fsprogs-native \
    "

python __anonymous() {
    # Force BALENA_STORAGE to use the machine specific definition even if we
    # are building a native recipe
    machine = d.getVar("MACHINE", True)
    bs_machine = d.getVar("BALENA_STORAGE_" + machine, True)
    if bs_machine:
        d.setVar("BALENA_STORAGE", bs_machine)
}

S = "${WORKDIR}"

do_compile () {
    rm -rf ${B}/work
    mkdir -p ${B}/work

    cp Dockerfile create.* mkfs.hostapp ${B}/work/
    for i in ${B}/work/create.*; do
        sed -i "s/@BALENA_STORAGE@/${BALENA_STORAGE}/g" $i
    done

    IMAGETAG="${PN}:$(date +%s)"
    DOCKER_API_VERSION=${BALENA_API_VERSION} docker build --tag ${IMAGETAG} ${B}/work
    DOCKER_API_VERSION=${BALENA_API_VERSION} docker save "$IMAGETAG" > ${B}/work/mkfs-hostapp-image.tar
    DOCKER_API_VERSION=${BALENA_API_VERSION} docker rmi "$IMAGETAG"

    sed -i "s/@IMAGE@/${IMAGETAG}/" ${B}/work/mkfs.hostapp
}
do_compile[network] = "1"

do_install () {
    install -d ${D}/${bindir}
    install ${B}/work/mkfs.hostapp ${D}/${bindir}/

    install -d ${D}/${datadir}
    install ${B}/work/mkfs-hostapp-image.tar ${D}/${datadir}/
}
