FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://kexecboot.cfg \
"

inherit allarch deploy

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

do_install () {
    install -d ${D}/boot
    sed -i -e 's,@KEXECBOOT_LABEL@,${KEXECBOOT_LABEL},g' kexecboot.cfg
    sed -i -e 's,@KEXEC_KERNEL_IMAGETYPE@,${KEXEC_KERNEL_IMAGETYPE},g' kexecboot.cfg
    sed -i -e 's,@KEXEC_KERNEL_DEVICETREE@,${KEXEC_KERNEL_DEVICETREE},g' kexecboot.cfg
    sed -i -e 's/@KEXEC_KERNEL_CMDLINE@/${KEXEC_KERNEL_CMDLINE}/g' kexecboot.cfg
    install -m 0644 kexecboot.cfg ${D}/boot/boot.cfg
}

KEXEC_KERNEL_IMAGETYPE ?= "${@oe.utils.squashspaces(d.getVar('KERNEL_IMAGETYPE'))}"
KEXEC_KERNEL_DEVICETREE ?= "${@oe.utils.squashspaces(d.getVar('KERNEL_DEVICETREE'))}"
KEXEC_KERNEL_CMDLINE ?= "${@oe.utils.squashspaces(d.getVar('OS_KERNEL_CMDLINE'))}"
