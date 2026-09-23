DESCRIPTION = "eBPF hostapp extension: a kernel with BTF and the BPF tracing surface, its matching modules, and the userspace tooling"
LICENSE = "MIT"

inherit kernel-extension-image

# :append rather than a plain assignment, which would parse after the inherit
# above and drop the kernel payload the class contributes.
IMAGE_INSTALL:append = " bpftool libbpf"
