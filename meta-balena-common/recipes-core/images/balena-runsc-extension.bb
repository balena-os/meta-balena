DESCRIPTION = "runsc hostapp extension: gVisor as an alternate OCI container runtime"
LICENSE = "MIT"

inherit balena-hostapp-extension

IMAGE_INSTALL = "runsc"

# Extend-only. The extension contributes /usr/bin/runsc and its runtime
# drop-in, and shadows no hostapp content, so it needs no override priority.
HOSTAPP_EXTENSION_LABEL_OVERRIDE = ""

# balenad only picks up a new runtime when it restarts, so the extension cannot
# take effect on the boot that installs it. This is also the class default.
HOSTAPP_EXTENSION_LABEL_REQUIRES_REBOOT = "1"

# An extension is a rootfs tarball, not a bootable image. The class does not
# set these yet; meta-balena PR #3920 hoists them into it, at which point this
# block and remove_unnecessary_files below can go.
IMAGE_LINGUAS = ""
VIRTUAL-RUNTIME_init_manager = ""
INITRAMFS_IMAGE = ""
IMAGE_FSTYPES = "tar.gz"

# An overlay contributes its own content only. The state directories have to
# come from the hostapp underneath it.
remove_unnecessary_files() {
    rm -rf ${IMAGE_ROOTFS}/etc ${IMAGE_ROOTFS}/var ${IMAGE_ROOTFS}/run
}
IMAGE_PREPROCESS_COMMAND += "remove_unnecessary_files;"
