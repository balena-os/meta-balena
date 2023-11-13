# Needed to get newuidmap/newgidmap built.
# TODO: Or maybe not, I think they are build by default. What
# is missing, maybe, is copying the binaries to the proper target.
PACKAGECONFIG[subids] = "--enable-subordinate-ids"
PACKAGECONFIG:append = " subids"

# TODO: And here is me trying to copy the binaries to the proper target.
do_install:append() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/src/newuidmap ${D}${bindir}
    install -m 0755 ${WORKDIR}/src/newgidmap ${D}${bindir}
}
