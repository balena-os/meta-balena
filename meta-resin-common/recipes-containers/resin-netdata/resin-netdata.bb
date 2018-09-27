DESCRIPTION = "resin netdata"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd deploy
require recipes-containers/resin-netdata/resin-netdata.inc

SRC_URI += " \
	file://start-resin-netdata \
	file://resin-netdata-healthcheck \
	file://resin-netdata.service \
	"

SYSTEMD_SERVICE_${PN} = " \
	resin-netdata.service \
	"

FILES_${PN} += " \
	${systemd_unitdir} \
	/usr/lib/resin-netdata \
	"

RDEPENDS_${PN} = " \
	balena \
	coreutils \
	healthdog \
	resin-unique-key \
	resin-vars \
	systemd \
	"

python () {
	netdata_repository = d.getVar('NETDATA_REPOSITORY', True)
	if not netdata_repository:
		bb.fatal("resin-netdata-disk: There is no support for this architecture.")
}

S = "${WORKDIR}"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install () {
	# Generate netdata conf
	install -d ${D}${bindir}
	install -m 0755 ${WORKDIR}/start-resin-netdata ${D}${bindir}

	install -d ${D}${systemd_unitdir}/system
	# Yocto gets confused if we use strange file names - so we rename it here
	# https://bugzilla.yoctoproject.org/show_bug.cgi?id=8161
	install -c -m 0644 ${WORKDIR}/resin-netdata.service ${D}${systemd_unitdir}/system
	sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
		-e 's,@SBINDIR@,${sbindir},g' \
		-e 's,@BINDIR@,${bindir},g' \
		${D}${systemd_unitdir}/system/*.service

	install -d ${D}/usr/lib/resin-netdata
	install -m 0755 ${WORKDIR}/resin-netdata-healthcheck ${D}/usr/lib/resin-netdata/resin-netdata-healthcheck
}

do_deploy () {
	echo ${NETDATA_TAG} > ${DEPLOYDIR}/VERSION
}
addtask deploy before do_package after do_install
