FILESEXTRAPATHS_append_edison := ":${THISDIR}/files"

SRC_URI_append_edison = "file://defconfig"

#This patch if applied will enable sylog as a feature, remove it
SRC_URI_remove_edison = "file://login-utilities.cfg"

#Remove the syslog related packages because our busybox does not compile it
SYSTEMD_PACKAGES_remove_edison := "${PN}-syslog"
SYSTEMD_SERVICE_${PN}-syslog_remove_edison := "${PN}-syslog.service"

#Remove alternative syslog files
ALTERNATIVE_${PN}-syslog_remove_edison = "syslog-conf"

do_install_edison () {
	if [ "${prefix}" != "/usr" ]; then
		sed -i "s:^/usr/:${prefix}/:" busybox.links*
	fi
	if [ "${base_sbindir}" != "/sbin" ]; then
		sed -i "s:^/sbin/:${base_sbindir}/:" busybox.links*
	fi

	install -d ${D}${sysconfdir}/init.d

	if ! grep -q "CONFIG_FEATURE_INDIVIDUAL=y" ${B}/.config; then
		# Install /bin/busybox, and the /bin/sh link so the postinst script
		# can run. Let update-alternatives handle the rest.
		install -d ${D}${base_bindir}
		if [ "${BUSYBOX_SPLIT_SUID}" = "1" ]; then
			install -m 4755 ${B}/busybox.suid ${D}${base_bindir}
			install -m 0755 ${B}/busybox.nosuid ${D}${base_bindir}
			install -m 0644 ${S}/busybox.links.suid ${D}${sysconfdir}
			install -m 0644 ${S}/busybox.links.nosuid ${D}${sysconfdir}
			if grep -q "CONFIG_FEATURE_SH_IS_ASH=y" ${B}/.config; then
				ln -sf busybox.nosuid ${D}${base_bindir}/sh
			fi
			# Keep a default busybox for people who want to invoke busybox directly.
			# This is also useful for the on device upgrade. Because we want
			# to use the busybox command in postinst.
			ln -sf busybox.nosuid ${D}${base_bindir}/busybox
		else
			if grep -q "CONFIG_FEATURE_SUID=y" ${B}/.config; then
				install -m 4755 ${B}/busybox ${D}${base_bindir}
			else
				install -m 0755 ${B}/busybox ${D}${base_bindir}
			fi
			install -m 0644 ${S}/busybox.links ${D}${sysconfdir}
			if grep -q "CONFIG_FEATURE_SH_IS_ASH=y" ${B}/.config; then
				ln -sf busybox ${D}${base_bindir}/sh
			fi
			# We make this symlink here to eliminate the error when upgrading together
			# with busybox-syslog. Without this symlink, the opkg may think of the
			# busybox.nosuid as obsolete and remove it, resulting in dead links like
			# /bin/sed -> /bin/busybox.nosuid. This will make upgrading busybox-syslog fail.
			# This symlink will be safely deleted in postinst, thus no negative effect.
			ln -sf busybox ${D}${base_bindir}/busybox.nosuid
		fi
	else
		install -d ${D}${base_bindir} ${D}${base_sbindir}
		install -d ${D}${libdir} ${D}${bindir} ${D}${sbindir}
		cat busybox.links | while read FILE; do
			NAME=`basename "$FILE"`
			install -m 0755 "0_lib/$NAME" "${D}$FILE.${BPN}"
		done
		# add suid bit where needed
		for i in `grep -E "APPLET.*BB_SUID_((MAYBE|REQUIRE))" include/applets.h | grep -v _BB_SUID_DROP | cut -f 3 -d '(' | cut -f 1 -d ','`; do
			find ${D} -name $i.${BPN} -exec chmod a+s {} \;
		done
		install -m 0755 0_lib/libbusybox.so.${PV} ${D}${libdir}/libbusybox.so.${PV}
		ln -sf sh.${BPN} ${D}${base_bindir}/sh
		ln -sf ln.${BPN} ${D}${base_bindir}/ln
		ln -sf test.${BPN} ${D}${bindir}/test
		if [ -f ${D}/linuxrc.${BPN} ]; then
			mv ${D}/linuxrc.${BPN} ${D}/linuxrc
		fi
		install -m 0644 ${S}/busybox.links ${D}${sysconfdir}
	fi

	if grep -q "CONFIG_SYSLOGD=y" ${B}/.config; then
		install -m 0755 ${WORKDIR}/syslog ${D}${sysconfdir}/init.d/syslog.${BPN}
		install -m 644 ${WORKDIR}/syslog-startup.conf ${D}${sysconfdir}/syslog-startup.conf.${BPN}
		install -m 644 ${WORKDIR}/syslog.conf ${D}${sysconfdir}/syslog.conf.${BPN}
	fi
	if grep "CONFIG_CROND=y" ${B}/.config; then
		install -m 0755 ${WORKDIR}/busybox-cron ${D}${sysconfdir}/init.d/
	fi
	if grep "CONFIG_HTTPD=y" ${B}/.config; then
		install -m 0755 ${WORKDIR}/busybox-httpd ${D}${sysconfdir}/init.d/
		install -d ${D}/srv/www
	fi
	if grep "CONFIG_UDHCPD=y" ${B}/.config; then
		install -m 0755 ${WORKDIR}/busybox-udhcpd ${D}${sysconfdir}/init.d/
	fi
	if grep "CONFIG_HWCLOCK=y" ${B}/.config; then
		install -m 0755 ${WORKDIR}/hwclock.sh ${D}${sysconfdir}/init.d/
	fi
	if grep "CONFIG_UDHCPC=y" ${B}/.config; then
		install -d ${D}${sysconfdir}/udhcpc.d
		install -d ${D}${datadir}/udhcpc
                install -m 0755 ${WORKDIR}/simple.script ${D}${sysconfdir}/udhcpc.d/50default
		install -m 0755 ${WORKDIR}/default.script ${D}${datadir}/udhcpc/default.script
	fi
	if grep "CONFIG_INETD=y" ${B}/.config; then
		install -m 0755 ${WORKDIR}/inetd ${D}${sysconfdir}/init.d/inetd.${BPN}
		sed -i "s:/usr/sbin/:${sbindir}/:" ${D}${sysconfdir}/init.d/inetd.${BPN}
		install -m 0644 ${WORKDIR}/inetd.conf ${D}${sysconfdir}/
	fi
        if grep "CONFIG_MDEV=y" ${B}/.config; then
               install -m 0755 ${WORKDIR}/mdev ${D}${sysconfdir}/init.d/mdev
               if grep "CONFIG_FEATURE_MDEV_CONF=y" ${B}/.config; then
                       install -m 644 ${WORKDIR}/mdev.conf ${D}${sysconfdir}/mdev.conf
               fi
	fi

    if ${@base_contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        if grep -q "CONFIG_SYSLOGD=y" ${B}/.config; then
            install -d ${D}${systemd_unitdir}/system
            sed 's,@base_sbindir@,${base_sbindir},g' < ${WORKDIR}/busybox-syslog.service.in \
                > ${D}${systemd_unitdir}/system/busybox-syslog.service
            sed 's,@base_sbindir@,${base_sbindir},g' < ${WORKDIR}/busybox-klogd.service.in \
                > ${D}${systemd_unitdir}/system/busybox-klogd.service
            if [ -f ${WORKDIR}/busybox-syslog.default ] ; then
                install -d ${D}${sysconfdir}/default
                install -m 0644 ${WORKDIR}/busybox-syslog.default ${D}${sysconfdir}/default/busybox-syslog
            fi
            ln -sf /dev/null ${D}${systemd_unitdir}/system/syslog.service
        fi
        if grep -q "CONFIG_KLOGD=y" ${B}/.config; then
            install -d ${D}${systemd_unitdir}/system
            sed 's,@base_sbindir@,${base_sbindir},g' < ${WORKDIR}/busybox-klogd.service.in \
                > ${D}${systemd_unitdir}/system/busybox-klogd.service
        fi
    fi

    # Remove the sysvinit specific configuration file for systemd systems to avoid confusion
    if ${@base_contains('DISTRO_FEATURES', 'sysvinit', 'false', 'true', d)}; then
	rm -f ${D}${sysconfdir}/syslog-startup.conf.${BPN}
    fi
}
