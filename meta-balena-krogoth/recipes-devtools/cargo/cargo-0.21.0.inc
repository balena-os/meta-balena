CARGO_SNAPSHOT = "cargo-0.20.0-${RUST_BUILD_SYS}"
SRC_URI[cargo-snapshot.md5sum] = "63aa861b029eec9f559f4fb5a10c287d"
SRC_URI[cargo-snapshot.sha256sum] = "a677d13b01d00ad13edf75c7d1b484421c7fc09338bf9ed6d456b4685bb42ed1"

SRC_URI += "\
	https://static.rust-lang.org/dist/${CARGO_SNAPSHOT}.tar.gz;name=cargo-snapshot \
"

# When building cargo-native we don't have a built cargo to use so we must use
# the snapshot to bootstrap the build of cargo
CARGO_class-native = "${WORKDIR}/${CARGO_SNAPSHOT}/cargo/bin/cargo"
