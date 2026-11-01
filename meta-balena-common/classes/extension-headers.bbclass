# extension-headers.bbclass
#
# kernel-devsrc variant for the extension kernel headers.
# Assignments here win: the class parses after the bbappends.

# BBCLASSEXTEND leaves PN unchanged for this class.
PN = "kernel-devsrc-extension-headers"

# Drops kernel-modules-headers, which the base recipe provides.
PROVIDES = ""

STAGING_KERNEL_DIR = "${STAGING_KERNEL_EXTENSION_DIR}"
STAGING_KERNEL_BUILDDIR = "${STAGING_KERNEL_EXTENSION_BUILDDIR}"
KERNEL_VERSION = "${@oe.utils.read_file('${STAGING_KERNEL_BUILDDIR}/kernel-extension-abiversion')}"
KERNEL_HEADERS_DEPLOY_DIR = "${DEPLOYDIR}/kernel-extension"

# Replaces the virtual/kernel entries from kernelsrc and kernel-devsrc.
do_patch[depends] = "virtual/kernel-extension:do_shared_workdir"
do_install[depends] = "virtual/kernel-extension:do_shared_workdir virtual/kernel-extension:do_install"
do_package[depends] = "virtual/kernel-extension:do_populate_sysroot"

# Replaces module-base's make-mod-scripts, which prepares the base kernel.
do_configure[depends] = "make-mod-scripts-extension:do_compile"
