# kernel-extension-image.bbclass
#
# Packages the extension kernel and its modules as a hostapp overlay. Inherit
# it from an image recipe and append whatever userspace the extension exists to
# deliver.

inherit balena-hostapp-extension

# :append for the reason balena-hostapp-extension.bbclass gives. Here the
# silent result is an extension imported with no kernel content at all.
IMAGE_INSTALL:append = " kernel-extension-modules kernel-extension-image-initramfs"

# x86 device types have no devicetree to package.
IMAGE_INSTALL:append = " ${@'kernel-extension-devicetree' if d.getVar('KERNEL_DEVICETREE') else ''}"

# Mounts left of the hostapp in mobynit's overlay stack. 100 leaves headroom
# both directions for overlays that shadow or are shadowed by this one.
HOSTAPP_EXTENSION_LABEL_OVERRIDE = "100"

# Fixed upstream in openembedded-core efa88e1c227d ("rootfs.py: Run
# depmod(wrapper) against each compiled kernel"); revisit once the poky
# submodule moves off kirkstone.
USE_DEPMOD = "0"

# No userspace here, so /bin and /sbin would only shadow the hostapp's.
HOSTAPP_EXTENSION_REMOVE_PATHS:append = " bin sbin"
