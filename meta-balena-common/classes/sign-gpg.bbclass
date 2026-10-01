inherit deploy

do_sign_gpg () {
    # The task itself does not need SIGN_API defined but we treat it
    # as a global switch to enable/disable all signing
    if [ "x${SIGN_API}" = "x" ]; then
        bbnote "Signing disabled"
        return 0
    fi

    export GPG_TTY="$(tty)"

    for SIGNING_ARTIFACT in ${SIGNING_ARTIFACTS}; do
        if [ -z "${SIGNING_ARTIFACT}" ] || [ ! -f "${SIGNING_ARTIFACT}" ]; then
            bbfatal "Nothing to sign"
        fi

        gpg -vv --homedir "${DEPLOY_DIR_IMAGE}/gpghome" --batch --yes --detach-sign "${SIGNING_ARTIFACT}"
    done
}

do_deploy:append() {
    for SIGNING_ARTIFACT in ${SIGNING_ARTIFACTS}; do
        if [ -f "${SIGNING_ARTIFACT}.sig" ]; then
            # Deploy the detached signature if available, the original file has already been deployed
            install -m 0644 "${SIGNING_ARTIFACT}.sig" "${DEPLOYDIR}/$(basename ${SIGNING_ARTIFACT}).sig"
        fi
    done
}

# this does not actually call SIGN_API but assumes that if SIGN_API is non-empty, the image should be signed
do_sign_gpg[depends] += "${@oe.utils.conditional('SIGN_API','','',' balena-keys-gpg:do_deploy gnupg-native:do_populate_sysroot coreutils-native:do_populate_sysroot pinentry-native:do_populate_sysroot',d)}"
