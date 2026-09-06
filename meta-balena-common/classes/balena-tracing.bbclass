# balena-tracing.bbclass
#
# The userspace tracing payload. Inherit alongside balena-hostapp-extension.

BALENA_TRACING_LTRACE = "ltrace"
BALENA_TRACING_LTRACE:riscv32 = ""
BALENA_TRACING_LTRACE:riscv64 = ""

IMAGE_INSTALL:append = " perf strace tcpdump ${BALENA_TRACING_LTRACE}"
