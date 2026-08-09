# kernel-extension-image.bbclass
#
# Packages the extension kernel and its modules as a hostapp overlay. Inherit
# it from an image recipe and append whatever userspace the extension exists to
# deliver.

inherit balena-hostapp-extension

IMAGE_INSTALL = "kernel-extension-modules kernel-extension-image-initramfs"

# x86 device types have no devicetree to package.
IMAGE_INSTALL += "${@'kernel-extension-devicetree' if d.getVar('KERNEL_DEVICETREE') else ''}"

# Mount left of the hostapp in mobynit's overlay stack. 100 leaves headroom
# both directions for overlays that need to shadow or be shadowed by the
# extension kernel.
HOSTAPP_EXTENSION_LABEL_OVERRIDE = "100"

# revisit once the poky submodule moves off kirkstone
# Fixed in upstream openembedded-core
# commit efa88e1c227d695319197f511701e0230d301f39 ("rootfs.py: Run depmod(wrapper) against each compiled kernel"
USE_DEPMOD = "0"

# This extension carries no userspace, so the /bin and /sbin compatibility
# symlinks would only shadow the hostapp's.
HOSTAPP_EXTENSION_REMOVE_PATHS:append = " bin sbin"
