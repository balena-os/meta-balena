DESCRIPTION = "Resin Configuration Recipe"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://resin-vars \
    file://config-json.path \
    file://config-json.service \
    file://os-networkmanager \
    file://os-networkmanager.service \
    file://os-networkmanager.testconfig1.json \
    file://os-networkmanager.testconfig2.json \
    file://os-networkmanager.testconfig3.json \
    file://os-networkmanager.testconfig4.json \
    file://os-networkmanager.testconfig5.json \
    file://os-networkmanager.testconfig6.json \
    file://os-udevrules \
    file://os-udevrules.service \
    file://os-sshkeys \
    file://os-sshkeys.service \
    "
S = "${WORKDIR}"

inherit allarch systemd

FILES_${PN} = "${sbindir}"

DEPENDS = "bash-native jq-native coreutils-native"
RDEPENDS_${PN} = "bash jq udev coreutils"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

SYSTEMD_SERVICE_${PN} = " \
    config-json.path \
    config-json.service \
    os-networkmanager.service \
    os-udevrules.service \
    os-sshkeys.service \
    "

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/resin-vars ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/os-networkmanager ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/os-udevrules ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/os-sshkeys ${D}${sbindir}/

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/config-json.path ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/config-json.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/os-networkmanager.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/os-udevrules.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/os-sshkeys.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi
}

runtest() {
	out=${WORKDIR}/nmconfig.test.tmp
	config=$1
	ecode=$2
	eout=$3
	failed=0
	bbnote "Run test for $config..."
	rm -rf $out 2>&1 > /dev/null
	CONFIG_PATH=${WORKDIR}/$config NM_CONF_FRAGMENT=$out bash ${D}${sbindir}/os-networkmanager && rc=$? || rc=$? 
	if [ "$rc" -ne "$ecode" ]; then
		bbwarn "Unexpected exit code."
		failed=1
	fi
	if [ "$eout" = "NO FILE" ]; then
		if [ -f "$out" ]; then
			bbwarn "Expected no output file but one was found."
			failed=1
		fi
	else
		if [ "$(cat $out)" != "$eout" ]; then
			bbwarn "Unexpected output."
			failed=1
		fi
	fi		
	if [ "$failed" -ne 0 ]; then
		bbfatal "Test for $config failed."
	else
		bbnote "Test for $config passed."
	fi
}

# Build time sanity tests checking various config.json fragments.
do_runtests() {
	bbnote "Running os-networkmanager tests..."
	runtest os-networkmanager.testconfig1.json 0 '# This file is generated based on os.networkManager configuration in config.json.
[device]
wifi.scan-rand-mac-address=yes'
	runtest os-networkmanager.testconfig2.json 0 '# This file is generated based on os.networkManager configuration in config.json.
[device]
wifi.scan-rand-mac-address=no'
	runtest os-networkmanager.testconfig3.json 0 '# This file is generated based on os.networkManager configuration in config.json.'
	runtest os-networkmanager.testconfig4.json 0 '# This file is generated based on os.networkManager configuration in config.json.
[device]
wifi.scan-rand-mac-address=foo'
	runtest os-networkmanager.testconfig5.json 1 'NO FILE'
	runtest os-networkmanager.testconfig6.json 0 '# This file is generated based on os.networkManager configuration in config.json.
[connectivity]
uri=http://www.example.com/connectivity-check
interval=7200
response=Am I online'

}
addtask runtests before do_package after do_install
