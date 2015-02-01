DESCRIPTION = "Resin Supervisor packager"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
PR = "r1.1"

FILES_${PN} = "/resin-data/* /mnt/data-disk/* ${servicedir}"

VERSION = "master"

SRC_REPOSITORY = "rpi-supervisor"

TARGET_REPOSITORY = "armhfv7-supervisor"

do_install() {
	install -d ${D}/resin-data
	install -d ${D}/mnt/data-disk
	install -d ${D}${servicedir}
	rce pull resin/${SRC_REPOSITORY}:${VERSION}
	rce tag -f resin/${SRC_REPOSITORY}:${VERSION} resin/${TARGET_REPOSITORY}:latest
	rce save resin/${TARGET_REPOSITORY}:latest > ${WORKDIR}/${TARGET_REPOSITORY}.tar
	install -m 0444 ${WORKDIR}/${TARGET_REPOSITORY}.tar ${D}/resin-data/${TARGET_REPOSITORY}.tar
	touch ${WORKDIR}/BTRFS_MOUNT_POINT
	install -m 0444 ${WORKDIR}/BTRFS_MOUNT_POINT ${D}/mnt/data-disk/BTRFS_MOUNT_POINT

}
