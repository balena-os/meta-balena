# We only need the library from the NSS package
# so we are removing everything else

# package some test binaries in a separate package which we won't include in the rootfs
PACKAGES =+ "${PN}-test-bins"
FILES:${PN}-test-bins = "\
    ${bindir}/* \
"

PACKAGES =+ "${PN}-test-libs"
FILES:${PN}-test-libs = "\
    ${libdir}/libnssckbi-testlib.so \
"
