ALLOW_EMPTY_${PN} = "1"

do_install_append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','debug-image','false','true',d)}; then
        # Non-Debug image
        find ${D} -name "serial-getty@*.service" -delete
        # We will need to delete empty directory to avoid installed vs shipped QA issue
        find ${D} -empty -type d -delete
    fi
}
