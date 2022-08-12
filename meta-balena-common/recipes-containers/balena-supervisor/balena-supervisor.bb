DESCRIPTION = "resin supervisor"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd deploy balena-configurable
require recipes-containers/balena-supervisor/balena-supervisor.inc

LED_FILE ?= "/dev/null"

SRC_URI += " \
	file://resin-data.mount \
	file://start-balena-supervisor \
	file://supervisor.conf \
	file://balena-supervisor.service \
	file://update-balena-supervisor \
	file://update-balena-supervisor.service \
	file://update-balena-supervisor.timer \
	file://balena-supervisor-healthcheck \
	file://tmpfiles-supervisor.conf \
	file://migrate-supervisor-state.service \
	"

SYSTEMD_SERVICE:${PN} = " \
	balena-supervisor.service \
	update-balena-supervisor.service \
	update-balena-supervisor.timer \
	migrate-supervisor-state.service \
	"

FILES:${PN} += " \
	/resin-data \
	${systemd_unitdir} \
	${sysconfdir} \
	/usr/lib/balena-supervisor \
	"

DEPENDS += "jq-native curl-native"

RDEPENDS:${PN} = " \
	balena \
	bash \
	coreutils \
	curl \
	healthdog \
	balena-unique-key \
	balena-config-vars \
	systemd \
	"

python () {
    supervisor_app = d.getVar('SUPERVISOR_FLEET', True)
    if not supervisor_app:
        bb.fatal("balena-supervisor: There is no support for this architecture.")
}

S = "${WORKDIR}"

do_patch[noexec] = "1"
do_compile[noexec] = "1"

do_install () {
	SUPERVISOR_IMAGE=$(jq --raw-output '.apps | .[] | select(.name=="'"${SUPERVISOR_APP}"'") | .releases[].services | .[].image' ${DEPLOY_DIR_IMAGE}/apps.json)
	bbnote "Pre-loaded supervisor: image ${SUPERVISOR_IMAGE}"
	# Generate supervisor conf
	install -d ${D}${sysconfdir}/balena-supervisor/
	install -m 0755 ${WORKDIR}/supervisor.conf ${D}${sysconfdir}/balena-supervisor/
	sed -i -e "s,@LED_FILE@,${LED_FILE},g" ${D}${sysconfdir}/balena-supervisor/supervisor.conf
	sed -i -e "s,@SUPERVISOR_VERSION@,${SUPERVISOR_VERSION},g" ${D}${sysconfdir}/balena-supervisor/supervisor.conf
	sed -i -e "s,@SUPERVISOR_IMAGE@,${SUPERVISOR_IMAGE},g" ${D}${sysconfdir}/balena-supervisor/supervisor.conf

	install -d ${D}/resin-data

	install -d ${D}${bindir}
	install -m 0755 ${WORKDIR}/update-balena-supervisor ${D}${bindir}
	install -m 0755 ${WORKDIR}/start-balena-supervisor ${D}${bindir}

	install -d ${D}${systemd_unitdir}/system
	# Yocto gets confused if we use strange file names - so we rename it here
	# https://bugzilla.yoctoproject.org/show_bug.cgi?id=8161
	install -c -m 0644 ${WORKDIR}/resin-data.mount ${D}${systemd_unitdir}/system/resin\\x2ddata.mount
	install -c -m 0644 ${WORKDIR}/balena-supervisor.service ${D}${systemd_unitdir}/system
	install -c -m 0644 ${WORKDIR}/update-balena-supervisor.service ${D}${systemd_unitdir}/system
	install -c -m 0644 ${WORKDIR}/update-balena-supervisor.timer ${D}${systemd_unitdir}/system
	install -c -m 0644 ${WORKDIR}/migrate-supervisor-state.service ${D}${systemd_unitdir}/system
	# symlinks to legacy resin-supervisor systemd unit files
	ln -s balena-supervisor.service ${D}${systemd_unitdir}/system/resin-supervisor.service
	ln -s update-balena-supervisor.service ${D}${systemd_unitdir}/system/update-resin-supervisor.service
	ln -s update-balena-supervisor.timer ${D}${systemd_unitdir}/system/update-resin-supervisor.timer
	sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
		-e 's,@SBINDIR@,${sbindir},g' \
		-e 's,@BINDIR@,${bindir},g' \
		${D}${systemd_unitdir}/system/*.service

	install -d ${D}/usr/lib/balena-supervisor
	install -m 0755 ${WORKDIR}/balena-supervisor-healthcheck ${D}/usr/lib/balena-supervisor/balena-supervisor-healthcheck

	# systemd tmpfiles configuration for supervisor
	mkdir -p ${D}${sysconfdir}/tmpfiles.d
	install -m 0644 ${WORKDIR}/tmpfiles-supervisor.conf ${D}${sysconfdir}/tmpfiles.d/supervisor.conf
}

do_deploy () {
	echo ${SUPERVISOR_VERSION} > ${DEPLOYDIR}/VERSION
}
addtask deploy before do_package after do_install
