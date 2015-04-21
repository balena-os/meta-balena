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

PROVIDES="resin-supervisor"
RPROVIDES_${PN} = "resin-supervisor"

VERSION = "${@bb.utils.contains('DISTRO_FEATURES', 'resin-staging', 'master', 'production', d)}"
TARGET_REPOSITORY ?= "resin/i386-supervisor"
PARTITION_SIZE ?= "1024"
LED_FILE ?= "/dev/null"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

do_install () {
	install -d ${D}${sysconfdir}
	install -m 0755 ${WORKDIR}/supervisor.conf ${D}${sysconfdir}/
	sed -i -e 's:@TARGET_REPOSITORY@:${TARGET_REPOSITORY}:g' ${D}${sysconfdir}/supervisor.conf
	sed -i -e 's:@LED_FILE@:${LED_FILE}:g' ${D}${sysconfdir}/supervisor.conf
}

do_deploy () {
	install -d ${DEPLOYDIR}
	cd ${WORKDIR}
	docker build -t looper .
	docker run --privileged -e PARTITION_SIZE=${PARTITION_SIZE} -e TARGET_REPOSITORY=${TARGET_REPOSITORY} -e TARGET_TAG=${VERSION} -v ${S}:/export looper
	install ${S}/data_disk.img ${DEPLOYDIR}/data_disk.img
}

addtask deploy before do_package after do_install
do_deploy[dirs] += "${DEPLOYDIR}"
PACKAGE_ARCH = "${MACHINE_ARCH}"
