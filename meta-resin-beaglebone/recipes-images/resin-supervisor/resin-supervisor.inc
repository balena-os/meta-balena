DESCRIPTION = "Resin Supervisor packager"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
PR = "r1.0"

FILES_${PN} = "${servicedir}/* ${baseprefix}/* "

VERSION = "master"

SRC_REPOSITORY = "rpi-supervisor"

TARGET_REPOSITORY = "armhfv7-supervisor"

do_install() {
	install -d ${D}${servicedir}
	install -d ${D}${baseprefix}
	install -d ${D}${baseprefix}/resin-data
        docker pull resin/${SRC_REPOSITORY}:${VERSION}
	docker tag resin/${SRC_REPOSITORY}:${VERSION} resin/${TARGET_REPOSITORY}:latest
	docker save resin/${TARGET_REPOSITORY}:latest > ${WORKDIR}/${TARGET_REPOSITORY}.tar
	pixz ${WORKDIR}/${TARGET_REPOSITORY}.tar ${WORKDIR}/${TARGET_REPOSITORY}.tar.xz  
	install -m 0444 ${WORKDIR}/${TARGET_REPOSITORY}.tar.xz ${D}${servicedir}/${TARGET_REPOSITORY}.tar.xz
}
