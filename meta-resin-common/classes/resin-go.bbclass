inherit go

do_compile_prepend() {
    export CGO_ENABLED=0
}

# Fix host-user-contaminated
do_install_append() {
    chown root:root -R ${D}
}

FILES_${PN} += "${GOBIN_FINAL}/*"
