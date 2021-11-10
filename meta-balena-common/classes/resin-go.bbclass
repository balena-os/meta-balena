inherit go

do_compile:prepend() {
    export CGO_ENABLED=0
}

# Fix host-user-contaminated
do_install:append() {
    chown root:root -R ${D}

    # Install all binaries in bindir
    if [ -d "${D}${GOROOT_FINAL}/bin"  ]; then
        mkdir -p ${D}${bindir}
        find ${D}${GOROOT_FINAL}/bin -type f -exec mv '{}' ${D}${bindir} \;
        rm -rf ${D}${GOROOT_FINAL}/bin
    fi
}

FILES:${PN} += "${bindir}"
