DESCRIPTION = "eBPF hostapp extension: a kernel with BTF and the BPF tracing surface, its matching modules, and the userspace tooling"
LICENSE = "MIT"

inherit kernel-extension-image

IMAGE_INSTALL:append = " bpftool libbpf"
