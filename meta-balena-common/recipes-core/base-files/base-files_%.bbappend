FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://mdns.allow \
    "

do_install:append () {
	# Systemd provides mtab so if activated, don't let base-files provide it too
	# We avoid errors at do_rootfs in this way when using opkg
	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
		rm -f ${D}${sysconfdir}/mtab
	fi

	# Supervisor depends on the existance of /lib/modules even if we don't
	# deploy any kernel modules (ex.: resinOS in container)
	install -d -m 755 ${D}/usr/lib/modules
}

do_install_basefilesissue:append () {
	distro_version_nodate="${@d.getVar('DISTRO_VERSION').replace('snapshot-${DATE}','snapshot').replace('${DATE}','')}"
	sed -i "s/${distro_version_nodate}/${HOSTOS_VERSION}/g" ${D}${sysconfdir}/issue
	sed -i "s/${distro_version_nodate}/${HOSTOS_VERSION}/g" ${D}${sysconfdir}/issue.net
}

do_install:append:libc-glibc () {
	install -m 0644 ${WORKDIR}/mdns.allow ${D}${sysconfdir}/mdns.allow
}
