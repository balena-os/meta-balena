# Specifics for Rust 1.20.0

## This is information on the rust-snapshot (binary) used to build our current release.
## snapshot info is taken from rust/src/stage0.txt
## TODO: find a way to add additional SRC_URIs based on the contents of an
##       earlier SRC_URI.
RS_VERSION = "1.19.0"

RUST_STD_SNAPSHOT = "rust-std-${RS_VERSION}-${RUST_BUILD_SYS}"
RUSTC_SNAPSHOT = "rustc-${RS_VERSION}-${RUST_BUILD_SYS}"
CARGO_VERSION = "0.20.0"
CARGO_SNAPSHOT = "cargo-${CARGO_VERSION}-${RUST_BUILD_SYS}"

SRC_URI += " \
	https://static.rust-lang.org/dist/${RUST_STD_SNAPSHOT}.tar.gz;name=rust-std-snapshot;subdir=rust-snapshot-components \
	https://static.rust-lang.org/dist/${RUSTC_SNAPSHOT}.tar.gz;name=rustc-snapshot;subdir=rust-snapshot-components \
	https://static.rust-lang.org/dist/${CARGO_SNAPSHOT}.tar.gz;name=cargo-snapshot;subdir=rust-snapshot-components \
	"

# These are x86_64-unknown-linux-gnu hashes, how can we add more?
SRC_URI[rustc-snapshot.md5sum] = "e5077b80cc953a1fb9c767aa039d5984"
SRC_URI[rustc-snapshot.sha256sum] = "4c8df3088d17c8e06bf58d453d39bd521487defcefc8193203b80f0fb797d6fe"
SRC_URI[rust-std-snapshot.md5sum] = "2bff47764df01c99f349908601c10478"
SRC_URI[rust-std-snapshot.sha256sum] = "5905803e8a127f656bf253978692f0d6cf6c9206c527e4d6d7e981980618d1b6"
SRC_URI[cargo-snapshot.md5sum] = "63aa861b029eec9f559f4fb5a10c287d"
SRC_URI[cargo-snapshot.sha256sum] = "a677d13b01d00ad13edf75c7d1b484421c7fc09338bf9ed6d456b4685bb42ed1"
