FILESEXTRAPATHS_append := ":${THISDIR}/files"

SRC_URI_append = " \
    file://dnsmasq.conf \
    file://dnsmasq.conf.systemd \
    "

FILES_${PN} += "${exec_prefix}/lib/tmpfiles.d/"

do_install_append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system/dnsmasq.service.d
        install -c -m 0644 ${WORKDIR}/dnsmasq.conf.systemd ${D}${sysconfdir}/systemd/system/dnsmasq.service.d/dnsmasq.conf

        # /etc/resolv.conf is now a symlink to /run/resolv.conf (poky b80da02ce9b683f96393fe0ea1f5f1a5f1a07c89) so we use systemd tmpfiles to specify dnsmasq listening on 127.0.0.2
        install -d ${D}${exec_prefix}/lib/tmpfiles.d/
        echo 'w /run/resolv.conf - - - - # we use dnsmasq at 127.0.0.2 so that user containers can run their own dns cache and forwarder and not conflict with dnsmasq on the host\\nnameserver 127.0.0.2\\n' >> ${D}${exec_prefix}/lib/tmpfiles.d/systemd-dnsmasq.conf
    fi
}
