SUMMARY = "Rust standard libaries"
HOMEPAGE = "http://www.rust-lang.org"
SECTION = "devel"
LICENSE = "MIT | Apache-2.0"

RUSTLIB_DEP = ""
inherit cargo

# Needed so cargo can find libbacktrace
RUSTFLAGS += "-L ${STAGING_LIBDIR}"

S = "${RUSTSRC}/src/libstd"

do_compile_prepend () {
    export CARGO_TARGET_DIR="${B}"
    # For Rust 1.13.0 and newer
    export RUSTC_BOOTSTRAP="1"
}

do_install () {
    mkdir -p ${D}${rustlibdir}

    cp ${B}/${TARGET_SYS}/release/deps/* ${D}${rustlibdir}
}
