DESCRIPTION = "Resin Supervisor packager"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit deploy

PR = "r1"

SRC_URI = " \
	file://Dockerfile \
	file://entry.sh \
	"

VERSION = "${@bb.utils.contains('DISTRO_FEATURES', 'resin-staging', 'master', 'production', d)}"
TARGET_REPOSITORY ?= "resin/i386-supervisor"
PARTITION_SIZE ?= "1024"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"
do_install[noexec] = "1"

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
