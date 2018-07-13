# Common variables used by all Rust builds
export rustlibdir = "${libdir}/rust"
FILES_${PN} += "${rustlibdir}/*.so"
FILES_${PN}-dev += "${rustlibdir}/*.rlib"
FILES_${PN}-dbg += "${rustlibdir}/.debug"

RUSTLIB = "-L ${STAGING_LIBDIR}/rust"
RUSTFLAGS += "${RUSTLIB}"
RUSTLIB_DEP ?= "libstd-rs"

# Responsible for taking Yocto triples and converting it to Rust triples

def rust_base_triple(d, thing):
    '''
    Mangle bitbake's *_SYS into something that rust might support (see
    rust/mk/cfg/* for a list)

    Note that os is assumed to be some linux form
    '''

    arch = d.getVar('{}_ARCH'.format(thing))
    # All the Yocto targets are Linux and are 'unknown'
    vendor = "-unknown"
    os = d.getVar('{}_OS'.format(thing))
    libc = d.getVar('TCLIBC')

    # Prefix with a dash and convert glibc -> gnu
    if libc == "glibc":
        libc = "-gnu"
    elif libc == "musl":
        libc = "-musl"

    # Don't double up musl (only appears to be the case on aarch64)
    if os == "linux-musl":
        if libc != "-musl":
            bb.fatal("{}_OS was '{}' but TCLIBC was not 'musl'".format(thing, os))
        os = "linux"

    # This catches ARM targets and appends the necessary hard float bits
    if os == "linux-gnueabi" or os == "linux-musleabi":
        libc = bb.utils.contains('TUNE_FEATURES', 'callconvention-hard', 'hf', '', d)
    return arch + vendor + '-' + os + libc

# Naming explanation
# Yocto
# - BUILD_SYS - Yocto triple of the build environment
# - HOST_SYS - What we're building for in Yocto
# - TARGET_SYS - What we're building for in Yocto
#
# So when building '-native' packages BUILD_SYS == HOST_SYS == TARGET_SYS
# When building packages for the image HOST_SYS == TARGET_SYS
# This is a gross over simplification as there are other modes but
# currently this is all that's supported.
#
# Rust
# - TARGET - the system where the binary will run
# - HOST - the system where the binary is being built
#
# Rust additionally will use two additional cases:
# - undecorated (e.g. CC) - equivalent to TARGET
# - triple suffix (e.g. CC_x86_64_unknown_linux_gnu) - both
#   see: https://github.com/alexcrichton/gcc-rs
# The way that Rust's internal triples and Yocto triples are mapped together
# its likely best to not use the triple suffix due to potential confusion.

RUST_BUILD_SYS = "${@rust_base_triple(d, 'BUILD')}"
RUST_HOST_SYS = "${@rust_base_triple(d, 'HOST')}"
RUST_TARGET_SYS = "${@rust_base_triple(d, 'TARGET')}"

# wrappers to get around the fact that Rust needs a single
# binary but Yocto's compiler and linker commands have
# arguments. Technically the archiver is always one command but
# this is necessary for builds that determine the prefix and then
# use those commands based on the prefix.
WRAPPER_DIR = "${WORKDIR}/wrapper"
RUST_BUILD_CC = "${WRAPPER_DIR}/build-rust-cc"
RUST_BUILD_CXX = "${WRAPPER_DIR}/build-rust-cxx"
RUST_BUILD_CCLD = "${WRAPPER_DIR}/build-rust-ccld"
RUST_BUILD_AR = "${WRAPPER_DIR}/build-rust-ar"
RUST_TARGET_CC = "${WRAPPER_DIR}/target-rust-cc"
RUST_TARGET_CXX = "${WRAPPER_DIR}/target-rust-cxx"
RUST_TARGET_CCLD = "${WRAPPER_DIR}/target-rust-ccld"
RUST_TARGET_AR = "${WRAPPER_DIR}/target-rust-ar"

create_wrapper () {
	file="$1"
	shift

	cat <<- EOF > "${file}"
	#!/bin/sh
	$@ "\$@"
	EOF
	chmod +x "${file}"
}

# compiler is used by gcc-rs
# linker is used by rustc/cargo
# archiver is used by the build of libstd-rs
do_rust_create_wrappers () {
	mkdir -p "${WRAPPER_DIR}"

	# Yocto Build / Rust Host C compiler
	create_wrapper "${RUST_BUILD_CC}" "${BUILD_CC}"
	# Yocto Build / Rust Host C++ compiler
	create_wrapper "${RUST_BUILD_CXX}" "${BUILD_CXX}"
	# Yocto Build / Rust Host linker
	create_wrapper "${RUST_BUILD_CCLD}" "${BUILD_CCLD}" "${BUILD_LDFLAGS}"
	# Yocto Build / Rust Host archiver
	create_wrapper "${RUST_BUILD_AR}" "${BUILD_AR}"

	# Yocto Target / Rust Target C compiler
	create_wrapper "${RUST_TARGET_CC}" "${CC}"
	# Yocto Target / Rust Target C++ compiler
	create_wrapper "${RUST_TARGET_CXX}" "${CXX}"
	# Yocto Target / Rust Target linker
	create_wrapper "${RUST_TARGET_CCLD}" "${CCLD}" "${LDFLAGS}"
	# Yocto Target / Rust Target archiver
	create_wrapper "${RUST_TARGET_AR}" "${AR}"
}

addtask rust_create_wrappers before do_configure after do_patch
do_rust_create_wrappers[dirs] += "${WRAPPER_DIR}"
