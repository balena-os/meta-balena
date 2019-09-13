# Use stretch as we have devices with old 3.10 kernel that won't build with gcc8 in buster
FROM balenalib/intel-nuc-debian:stretch-20190717

# Install dependencies
RUN apt-get update && apt-get install -y curl wget build-essential libelf-dev bc flex libssl-dev bison gcc-arm-linux-gnueabi gcc-aarch64-linux-gnu

# Fetch kernel module headers built and source
ADD example_module /usr/src/app/example_module_headers_src/
ADD example_module /usr/src/app/example_module_headers_built/
ADD kernel_source.tar.gz /usr/src/app/kernel_source
ADD kernel_modules_headers.tar.gz /usr/src/app/
WORKDIR /usr/src/app

# Workaround for a subtle issue in the linker path. Debian defaults to /lib64/ld-linux-x86-64.so.2 while balenaOS defaults to /lib/ld-linux-x86-64.so.2 for os/headers. Affects NUC.
RUN if [ -f /lib64/ld-linux-x86-64.so.2 ]; then \
	if [ ! -f /lib/ld-linux-x86-64.so.2 ]; then \
		ln -s /lib64/ld-linux-x86-64.so.2  /lib/ld-linux-x86-64.so.2 ; \
	fi; \
    fi;

ARG kernel_arch
ARG cross_compile_prefix
# Compile external hello module using header sources
RUN ARCH=${kernel_arch} CROSS_COMPILE=${cross_compile_prefix} make -C /usr/src/app/kernel_source/*/build modules_prepare
RUN ARCH=${kernel_arch} CROSS_COMPILE=${cross_compile_prefix} KERNEL_TREE_PATH=/usr/src/app/kernel_source/*/build/ MODULE_PATH=/usr/src/app/example_module_headers_src  make -C /usr/src/app/example_module_headers_src

# Compile external hello module using pre-built headers
# We run modules_prepare again because the tools pre-compiled are actually the target device arch. While we cross-compile for testing.
RUN ARCH=${kernel_arch} CROSS_COMPILE=${cross_compile_prefix} make -C /usr/src/app/kernel_modules_headers/ modules_prepare
RUN ARCH=${kernel_arch} CROSS_COMPILE=${cross_compile_prefix} KERNEL_TREE_PATH=/usr/src/app/kernel_modules_headers/ MODULE_PATH=/usr/src/app/example_module_headers_built  make -C /usr/src/app/example_module_headers_built
