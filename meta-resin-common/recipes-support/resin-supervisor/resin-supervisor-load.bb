DESCRIPTION = "Resin Supervisor packager"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PR = "r1.2"

SRC_URI = "file://supervisor.conf"
S = "${WORKDIR}"

PROVIDES="resin-supervisor"
RPROVIDES_${PN} = "resin-supervisor"

SRC_REPOSITORY = "rpi-supervisor"
TARGET_REPOSITORY = "armhfv7-supervisor"
LED_FILE = "/sys/class/leds/beaglebone\:green\:usr3/brightness"

FILES_${PN} = "${sysconfdir}/* /resin-data/* /mnt/data-disk/* ${servicedir}"

do_install() {
    install -d ${D}/resin-data
    install -d ${D}/mnt/data-disk
    install -d ${D}${servicedir}
    docker pull resin/${SRC_REPOSITORY}:${SUPERVISOR_TAG}
    docker tag -f resin/${SRC_REPOSITORY}:${SUPERVISOR_TAG} resin/${TARGET_REPOSITORY}:latest
    docker save resin/${TARGET_REPOSITORY}:latest > ${WORKDIR}/${TARGET_REPOSITORY}.tar
    install -m 0444 ${WORKDIR}/${TARGET_REPOSITORY}.tar ${D}/resin-data/${TARGET_REPOSITORY}.tar
    touch ${WORKDIR}/BTRFS_MOUNT_POINT
    install -m 0444 ${WORKDIR}/BTRFS_MOUNT_POINT ${D}/mnt/data-disk/BTRFS_MOUNT_POINT

    install -d ${D}${sysconfdir}
    install -m 0755 ${WORKDIR}/supervisor.conf ${D}${sysconfdir}/
    sed -i -e 's:@TARGET_REPOSITORY@:resin/${TARGET_REPOSITORY}:g' ${D}${sysconfdir}/supervisor.conf
    sed -i -e 's:@LED_FILE@:${LED_FILE}:g' ${D}${sysconfdir}/supervisor.conf
}
