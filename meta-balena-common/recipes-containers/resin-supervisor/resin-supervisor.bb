DESCRIPTION = "resin supervisor"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd deploy
require recipes-containers/resin-supervisor/resin-supervisor.inc

LED_FILE ?= "/dev/null"

SRC_URI += " \
	file://resin-data.mount \
	file://start-resin-supervisor \
	file://supervisor.conf \
	file://resin-supervisor.service \
	file://update-resin-supervisor \
	file://update-resin-supervisor.service \
	file://update-resin-supervisor.timer \
	file://resin-supervisor-healthcheck \
	file://tmpfiles-supervisor.conf \
	"

SYSTEMD_SERVICE_${PN} = " \
	resin-supervisor.service \
	update-resin-supervisor.service \
	update-resin-supervisor.timer \
	"

FILES_${PN} += " \
	/resin-data \
	${systemd_unitdir} \
	${sysconfdir} \
	/usr/lib/resin-supervisor \
	"

RDEPENDS_${PN} = " \
	balena \
	coreutils \
	curl \
	healthdog \
	balena-unique-key \
	resin-vars \
	systemd \
	"

python () {
    supervisor_repository = d.getVar('SUPERVISOR_REPOSITORY', True)
    if not supervisor_repository:
        bb.fatal("resin-supervisor-disk: There is no support for this architecture.")
}

S = "${WORKDIR}"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install () {
	# Generate supervisor conf
	install -d ${D}${sysconfdir}/resin-supervisor/
	install -m 0755 ${WORKDIR}/supervisor.conf ${D}${sysconfdir}/resin-supervisor/
	sed -i -e 's:@SUPERVISOR_REPOSITORY@:${SUPERVISOR_REPOSITORY}:g' ${D}${sysconfdir}/resin-supervisor/supervisor.conf
	sed -i -e 's:@LED_FILE@:${LED_FILE}:g' ${D}${sysconfdir}/resin-supervisor/supervisor.conf
	sed -i -e 's:@SUPERVISOR_TAG@:${SUPERVISOR_TAG}:g' ${D}${sysconfdir}/resin-supervisor/supervisor.conf

	install -d ${D}/resin-data

	install -d ${D}${bindir}
	install -m 0755 ${WORKDIR}/update-resin-supervisor ${D}${bindir}
	install -m 0755 ${WORKDIR}/start-resin-supervisor ${D}${bindir}

	install -d ${D}${systemd_unitdir}/system
	# Yocto gets confused if we use strange file names - so we rename it here
	# https://bugzilla.yoctoproject.org/show_bug.cgi?id=8161
	install -c -m 0644 ${WORKDIR}/resin-data.mount ${D}${systemd_unitdir}/system/resin\\x2ddata.mount
	install -c -m 0644 ${WORKDIR}/resin-supervisor.service ${D}${systemd_unitdir}/system
	install -c -m 0644 ${WORKDIR}/update-resin-supervisor.service ${D}${systemd_unitdir}/system
	install -c -m 0644 ${WORKDIR}/update-resin-supervisor.timer ${D}${systemd_unitdir}/system
	sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
		-e 's,@SBINDIR@,${sbindir},g' \
		-e 's,@BINDIR@,${bindir},g' \
		${D}${systemd_unitdir}/system/*.service

	install -d ${D}/usr/lib/resin-supervisor
	install -m 0755 ${WORKDIR}/resin-supervisor-healthcheck ${D}/usr/lib/resin-supervisor/resin-supervisor-healthcheck

	# systemd tmpfiles configuration for supervisor
	mkdir -p ${D}${sysconfdir}/tmpfiles.d
	install -m 0644 ${WORKDIR}/tmpfiles-supervisor.conf ${D}${sysconfdir}/tmpfiles.d/supervisor.conf
}

do_deploy () {
	echo ${SUPERVISOR_TAG} > ${DEPLOYDIR}/VERSION
}
addtask deploy before do_package after do_install
