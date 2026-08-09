# Build fixes for the perf that balena-tracing-extension ships.
EXTRA_OEMAKE:append = " NO_LIBTRACEEVENT=1"
PERF_SRC:append:aarch64 = " arch/arm64/include/uapi/asm/bpf_perf_event.h arch/arm64/tools"
RDEPENDS:${PN}-tests += "perl"
