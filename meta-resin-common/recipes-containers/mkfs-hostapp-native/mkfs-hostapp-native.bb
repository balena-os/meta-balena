SUMMARY = "Resin hostapp rootfs creation tool"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://Dockerfile \
    file://create \
    file://mkfs.hostapp-ext4 \
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

    cp Dockerfile create mkfs.hostapp-ext4 ${B}/work/
    sed -i "s/@BALENA_STORAGE@/${BALENA_STORAGE}/g" ${B}/work/create

    IMAGE_ID=$(DOCKER_API_VERSION=1.22 docker build ${B}/work | grep -o -E '[a-z0-9]{12}' | tail -n1)
    DOCKER_API_VERSION=1.22 docker save "$IMAGE_ID" > ${B}/work/mkfs-hostapp-ext4-image.tar
    DOCKER_API_VERSION=1.22 docker rmi "$IMAGE_ID"

    sed -i "s/@IMAGE@/${IMAGE_ID}/" ${B}/work/mkfs.hostapp-ext4
}

do_install () {
    install -d ${D}/${bindir}
    install ${B}/work/mkfs.hostapp-ext4 ${D}/${bindir}/

    install -d ${D}/${datadir}
    install ${B}/work/mkfs-hostapp-ext4-image.tar ${D}/${datadir}/
}
