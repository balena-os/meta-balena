#
# Automatically apply configuration changes to a systemd unit
#

SYSTEMD_UNIT_NAMES ?= "${BPN}"
RDEPENDS:${PN}:append:class-target = " balena-units-conf"

python __anonymous () {
    systemd_unitdir=d.getVar("systemd_unitdir")
    systemd_unit_names=d.getVar("SYSTEMD_UNIT_NAMES")
    for unitname in systemd_unit_names.split(' '):
        d.appendVar('FILES:' + d.getVar('PN'), ' ' + os.path.join(systemd_unitdir, "system", unitname + "-conf.path"))
        d.appendVar('FILES:' + d.getVar('PN'), ' ' + os.path.join(systemd_unitdir, "system", unitname + "-conf.service"))
        d.appendVar("SYSTEMD_SERVICE:" + d.getVar('PN'), ' ' + unitname + "-conf.path")
        d.appendVar("SYSTEMD_SERVICE:" + d.getVar('PN'), ' ' + unitname + "-conf.service")
}

do_configure:prepend() {
    for SYSTEMD_UNIT_NAME in ${SYSTEMD_UNIT_NAMES}; do
        cat > ${WORKDIR}/${SYSTEMD_UNIT_NAME}-conf.path << EOF
[Unit]
Description=${SYSTEMD_UNIT_NAME} path watch

[Path]
PathChanged=/var/volatile/${SYSTEMD_UNIT_NAME}.json

[Install]
WantedBy=basic.target
EOF

        cat > ${WORKDIR}/${SYSTEMD_UNIT_NAME}-conf.service << EOF
[Unit]
Description=${SYSTEMD_UNIT_NAME}.json watcher service

[Service]
Type=oneshot
ExecStartPre=/bin/echo "${SYSTEMD_UNIT_NAME} configuration changed"
ExecStart=/bin/systemctl restart ${SYSTEMD_UNIT_NAME}.service
EOF
    done
}

do_install:append() {
    install -d ${D}${systemd_unitdir}/system
    for SYSTEMD_UNIT_NAME in ${SYSTEMD_UNIT_NAMES}; do
        install -c -m 0644 ${WORKDIR}/${SYSTEMD_UNIT_NAME}-conf.path ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/${SYSTEMD_UNIT_NAME}-conf.service ${D}${systemd_unitdir}/system
    done
}
