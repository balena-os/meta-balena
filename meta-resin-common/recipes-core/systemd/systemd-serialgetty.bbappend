# we define ${S} to supress build warning complaining about S not being defined
S = "${WORKDIR}"
ALLOW_EMPTY_${PN} = "1"

do_install_append() {
    # Staging Resin build
    if ${@bb.utils.contains('DISTRO_FEATURES','resin-staging','true','false',d)}; then
        echo "Staging environment"
    else
        find ${D} -name "serial-getty@*.service" -delete
        # We will need to delete empty directory to avoid installed vs shipped QA issue
        find ${D} -empty -type d -delete
    fi
}
