# extension-scripts.bbclass
#
# make-mod-scripts variant that prepares the extension kernel build dir.

# BBCLASSEXTEND leaves PN unchanged for this class.
PN = "make-mod-scripts-extension"

STAGING_KERNEL_DIR = "${STAGING_KERNEL_EXTENSION_DIR}"
STAGING_KERNEL_BUILDDIR = "${STAGING_KERNEL_EXTENSION_BUILDDIR}"

# get_kernellocalversion_file() reads kernel-localversion only. A wrong
# LOCALVERSION makes prepare regenerate kernel.release, and the vermagic.
KERNEL_LOCALVERSION = "${@oe.utils.read_file('${STAGING_KERNEL_BUILDDIR}/kernel-extension-localversion')}"

# Replaces the virtual/kernel entries from make-mod-scripts.
do_configure[depends] = "virtual/kernel-extension:do_shared_workdir openssl-native:do_populate_sysroot"
do_compile[depends] = "virtual/kernel-extension:do_compile_kernelmodules"
