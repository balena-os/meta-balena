# balena-tracing.bbclass
#
# The userspace tracing payload: syscall, library call, network and kernel
# event tracing.

BALENA_TRACING_LTRACE = "ltrace"
BALENA_TRACING_LTRACE:riscv32 = ""
BALENA_TRACING_LTRACE:riscv64 = ""

# :append so inherit order cannot clobber an IMAGE_INSTALL set by the recipe.
IMAGE_INSTALL:append = " perf strace tcpdump ${BALENA_TRACING_LTRACE}"
