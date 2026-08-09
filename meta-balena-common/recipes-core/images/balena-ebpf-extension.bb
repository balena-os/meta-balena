DESCRIPTION = "eBPF hostapp extension: a kernel with BTF and the BPF tracing surface, its matching modules, and the userspace tooling"
LICENSE = "MIT"

inherit kernel-extension-image

# :append so the class's IMAGE_INSTALL assignment cannot clobber this.
IMAGE_INSTALL:append = " bpftool libbpf"
