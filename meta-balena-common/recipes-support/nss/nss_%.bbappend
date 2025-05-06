# package some test binaries in a separate package which we won't include in the rootfs
PACKAGES =+ "${PN}-test-bins"
FILES:${PN}-test-bins = "\
    ${bindir}/*test \
"
