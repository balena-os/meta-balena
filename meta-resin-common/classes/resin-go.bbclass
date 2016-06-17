inherit go

# Fix host-user-contaminated
do_install_append() {
    chown root:root -R ${D}
}

FILES_${PN} += "${GOBIN_FINAL}/*"
