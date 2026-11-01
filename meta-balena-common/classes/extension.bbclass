# extension.bbclass
#
# kernel-headers-test variant for the extension kernel headers.

# BBCLASSEXTEND leaves PN unchanged for this class.
PN = "kernel-headers-test-extension"

KERNEL_HEADERS_TARBALL = "${KERNEL_EXTENSION_DEPLOY_DIR}/kernel_modules_headers.tar.gz"

# Replaces the base kernel-devsrc dependency.
do_compile[depends] = "kernel-devsrc-extension-headers:do_deploy"
