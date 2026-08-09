# balena-tracing.bbclass
#
# The userspace tracing payload: syscall, library call, network and kernel
# event tracing.

# :append so inherit order cannot clobber an IMAGE_INSTALL set by the recipe.
IMAGE_INSTALL:append = " perf strace tcpdump ltrace"
