FILESEXTRAPATHS_append_nuc := ":${THISDIR}/files"

SRC_URI_append_nuc = " file://grub.cfg"

do_deploy_append_nuc() {
    install -m 644 ${WORKDIR}/grub.cfg ${DEPLOYDIR}
}
