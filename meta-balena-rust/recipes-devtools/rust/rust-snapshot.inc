## This is information on the rust-snapshot (binary) used to build our current release.
## snapshot info is taken from rust/src/stage0.json
## Rust is self-hosting and bootstraps itself with a pre-built previous version of itself.
## The exact (previous) version that has been used is specified in the source tarball.
## The version is replicated here.
## TODO: find a way to add additional SRC_URIs based on the contents of an
##       earlier SRC_URI.

SNAPSHOT_VERSION = "1.72.0"

# TODO: Add hashes for other architecture toolchains as well. Make a script?
SRC_URI[rust-std-snapshot-x86_64.sha256sum] = "36f27513a6e4381f15b0cd14097c885af537f990cb6193cec3337c429367bf23"
SRC_URI[rustc-snapshot-x86_64.sha256sum] = "5b5d7854a0d73368f15146c1aa47e4dbccf12762c93282f410a09a605929ce09"
SRC_URI[cargo-snapshot-x86_64.sha256sum] = "4a401dfe7b3056dc0d42acbcd380b2b90f936577706ca74ef5327af0f5abd0a0"

SRC_URI[rust-std-snapshot-aarch64.sha256sum] = "41d259c6f84280fd0e7719fea03a7583ba54e33e8ac32a2a7b703ffb0aebb7d9"
SRC_URI[rustc-snapshot-aarch64.sha256sum] = "1948a80453956d494457dcced1942e2e204fb26d4e57e718ef1c7aa378efbedb"
SRC_URI[cargo-snapshot-aarch64.sha256sum] = "95741a4cd2073adbd74a7c5596bb912abf4b2dfe00d70a9919cba4a836b7a0ff"

SRC_URI[rust-std-snapshot-powerpc64le.sha256sum] = "b6ef684ebf77063dbc1ff0abfe1316651fa73bbb95b023255b301b415867ff8b"
SRC_URI[rustc-snapshot-powerpc64le.sha256sum] = "20ed9ec0599e6582a218dae544566ddf7e2af46341705f35de874c90d7eecc0c"
SRC_URI[cargo-snapshot-powerpc64le.sha256sum] = "f659bf3ab70c376c736b7d7112d1fcee32a56dbfa66f6ef4fc039652f66c99e7"

SRC_URI += " \
    https://static.rust-lang.org/dist/${RUST_STD_SNAPSHOT}.tar.xz;name=rust-std-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
    https://static.rust-lang.org/dist/${RUSTC_SNAPSHOT}.tar.xz;name=rustc-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
    https://static.rust-lang.org/dist/${CARGO_SNAPSHOT}.tar.xz;name=cargo-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
"

RUST_STD_SNAPSHOT = "rust-std-${SNAPSHOT_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
RUSTC_SNAPSHOT = "rustc-${SNAPSHOT_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
CARGO_SNAPSHOT = "cargo-${SNAPSHOT_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
