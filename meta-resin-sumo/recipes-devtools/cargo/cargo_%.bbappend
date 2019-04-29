FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://Cargo.lock"

export CARGO_HOME = "${S}/cargo_home"

# for cargo 0.25.0, we use a known working Cargo.lock
cargo_common_do_configure_append() {
    cp ${WORKDIR}/Cargo.lock ${S}
}
