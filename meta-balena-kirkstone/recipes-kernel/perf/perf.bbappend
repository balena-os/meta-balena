PERF_SRC:append:aarch64 = " arch/arm64/include/uapi/asm/bpf_perf_event.h arch/arm64/tools"
RDEPENDS:${PN}-tests += "perl"

# Kernels from 6.2 onwards dropped the in-tree tools/lib/traceevent copy and
# expect the library to come from the sysroot. Kirkstone has no libtraceevent
# recipe, so build perf without it.
EXTRA_OEMAKE += "NO_LIBTRACEEVENT=1"
