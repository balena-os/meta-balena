FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://console_null_workaround \
    file://prepare \
    file://fsck \
    file://fsuuidsinit \
    file://machineid \
    file://resindataexpander \
    file://rorootfs \
    file://rootfs \
    file://finish \
    file://cryptsetup \
    file://cryptsetup-efi-tpm \
    file://kexec \
    file://udevcleanup \
    file://recovery \
    file://migrate \
    file://zram \
    "

do_install:append() {
    install -m 0755 ${WORKDIR}/console_null_workaround ${D}/init.d/000-console_null_workaround
    install -m 0755 ${WORKDIR}/prepare ${D}/init.d/70-prepare
    install -m 0755 ${WORKDIR}/fsuuidsinit ${D}/init.d/75-fsuuidsinit
    install -m 0755 ${WORKDIR}/fsck ${D}/init.d/87-fsck
    install -m 0755 ${WORKDIR}/rootfs ${D}/init.d/90-rootfs
    install -m 0755 ${WORKDIR}/migrate ${D}/init.d/92-migrate
    install -m 0755 ${WORKDIR}/finish ${D}/init.d/99-finish

    install -m 0755 ${WORKDIR}/machineid ${D}/init.d/91-machineid
    install -m 0755 ${WORKDIR}/resindataexpander ${D}/init.d/88-resindataexpander
    install -m 0755 ${WORKDIR}/rorootfs ${D}/init.d/89-rorootfs
    install -m 0755 ${WORKDIR}/udevcleanup ${D}/init.d/98-udevcleanup
    if [ ${@bb.utils.contains('MACHINE_FEATURES', 'efi', 'true', 'false',d)} = 'true' ] &&
       [ ${@bb.utils.contains('MACHINE_FEATURES', 'tpm', 'true', 'false',d)} = 'true' ]; then
        install -m 0755 ${WORKDIR}/cryptsetup-efi-tpm ${D}/init.d/72-cryptsetup
    else
        install -m 0755 ${WORKDIR}/cryptsetup ${D}/init.d/72-cryptsetup
    fi
    install -m 0755 ${WORKDIR}/recovery ${D}/init.d/00-recovery

    install -m 0755 ${WORKDIR}/kexec ${D}/init.d/92-kexec
    sed -i -e "s,@@KERNEL_IMAGETYPE@@,${KERNEL_IMAGETYPE}," "${D}/init.d/92-kexec"
    sed -i -e "s,@@KERNEL_IMAGETYPE@@,${KERNEL_IMAGETYPE}," "${D}/init.d/92-migrate"
    install -m 0755 ${WORKDIR}/zram ${D}/init.d/12-zram
}

PACKAGES:append = " \
    initramfs-module-console-null-workaround \
    initramfs-module-fsck \
    initramfs-module-machineid \
    initramfs-module-resindataexpander \
    initramfs-module-rorootfs \
    initramfs-module-prepare \
    initramfs-module-fsuuidsinit \
    initramfs-module-cryptsetup \
    initramfs-module-kexec \
    initramfs-module-udevcleanup \
    initramfs-module-recovery \
    initramfs-module-migrate \
    initramfs-module-zram \
    "

RRECOMMENDS:${PN}-base += "initramfs-module-rootfs"

SUMMARY:initramfs-module-console-null-workaround = "Workaround needed for when console=null is passed in kernel cmdline"
RDEPENDS:initramfs-module-console-null-workaround = "${PN}-base"
FILES:initramfs-module-console-null-workaround = "/init.d/000-console_null_workaround"

SUMMARY:initramfs-module-fsck = "Filesystem check for partitions"
RDEPENDS:initramfs-module-fsck = "${PN}-base e2fsprogs-e2fsck dosfstools-fsck"
FILES:initramfs-module-fsck = "/init.d/87-fsck"

SUMMARY:initramfs-module-machineid = "Bind mount machine-id to rootfs"
RDEPENDS:initramfs-module-machineid = "${PN}-base initramfs-module-udev"
FILES:initramfs-module-machineid = "/init.d/91-machineid"

SUMMARY:initramfs-module-resindataexpander = "Expand the data partition to the end of device"
RDEPENDS:initramfs-module-resindataexpander = "${PN}-base initramfs-module-udev busybox parted util-linux-lsblk e2fsprogs-resize2fs os-helpers-fs"
FILES:initramfs-module-resindataexpander = "/init.d/88-resindataexpander"

SUMMARY:initramfs-module-rorootfs = "Mount our rootfs"
RDEPENDS:initramfs-module-rorootfs = "${PN}-base"
FILES:initramfs-module-rorootfs = "/init.d/89-rorootfs"

SUMMARY:initramfs-module-rootfs = "initramfs support for locating and mounting the root partition"
RDEPENDS:initramfs-module-rootfs = "${PN}-base os-helpers-fs os-helpers-logging"
FILES:initramfs-module-rootfs = "/init.d/90-rootfs"

SUMMARY:initramfs-module-prepare = "Prepare initramfs console"
RDEPENDS:initramfs-module-prepare = "${PN}-base os-helpers-logging os-helpers-fs"
FILES:initramfs-module-prepare = "/init.d/70-prepare"

SUMMARY:initramfs-module-fsuuidsinit = "Regenerate default filesystem UUIDs"
RDEPENDS:initramfs-module-fsuuidsinit = "${PN}-base"
FILES:initramfs-module-fsuuidsinit = "/init.d/75-fsuuidsinit"

SUMMARY:initramfs-module-cryptsetup = "Unlock encrypted partitions"
RDEPENDS:initramfs-module-cryptsetup = "${PN}-base cryptsetup libgcc lvm2-udevrules os-helpers-logging os-helpers-fs balena-config-vars-config"
RDEPENDS:initramfs-module-cryptsetup:append = "${@bb.utils.contains('MACHINE_FEATURES', 'tpm', ' os-helpers-tpm2', '',d)}"
RDEPENDS:initramfs-module-cryptsetup:append = "${@bb.utils.contains('MACHINE_FEATURES', 'efi', ' os-helpers-efi', '',d)}"
FILES:initramfs-module-cryptsetup = "/init.d/72-cryptsetup"

SUMMARY:initramfs-module-kexec = "Find and start a new kernel if in stage2"
RDEPENDS:initramfs-module-kexec = " \
    kexec-tools \
    os-helpers-logging \
    util-linux-findmnt \
    "
FILES:initramfs-module-kexec = "/init.d/92-kexec"

SUMMARY:initramfs-module-udevcleanaup = "Cleanup the udev database before transitioning to the rootfs"
RDEPENDS:initramfs-module-udevcleanaup = "${PN}-base"
FILES:initramfs-module-udevcleanup = "/init.d/98-udevcleanup"

SUMMARY:initramfs-module-recovery = "Boot into a recovery shell"
RDEPENDS:initramfs-module-recovery = "${PN}-base android-tools-adbd"
FILES:initramfs-module-recovery = "/init.d/00-recovery"

SUMMARY:initramfs-module-migrate = "OS Migration"
RDEPENDS:initramfs-module-migrate = " \
    util-linux-findmnt \
    resin-init-flasher \
    util-linux-mountpoint \
    bash \
    balena-config-vars-config \
    "
FILES:initramfs-module-migrate = "/init.d/92-migrate"

SUMMARY:initramfs-module-zram = "Mount tmp as zram"
RDEPENDS:initramfs-module-zram = "${PN}-base util-linux-zramctl"
FILES:initramfs-module-zram = "/init.d/12-zram"

RDEPENDS:${PN}-base:append = " util-linux-mountpoint"
