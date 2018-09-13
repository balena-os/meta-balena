# Specifics for Rust 1.20.0

SRC_URI += "\
	https://static.rust-lang.org/dist/rustc-${PV}-src.tar.gz;name=rust \
    "
SRC_URI[rust.md5sum] = "1d3c5d25d8e6215e7d0b6d4d4c9835b9"
SRC_URI[rust.sha256sum] = "2aa4875ff4472c6e35262bbb9052cb2623da3dae6084a858cc59d36f33f18214"

# later versions of rust change the directory that they unextract to
RUSTSRC = "${WORKDIR}/rustc-${PV}-src"
# set this as our default
S = "${RUSTSRC}"

LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=12922f5565a22267bd82aaeb6d3548e5"
