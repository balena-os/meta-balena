inherit deploy

do_sign_gpg () {
    if [ "x${SIGN_API}" = "x" ]; then
        bbnote "Signing API not defined"
        return 0
    fi
    if [ "x${SIGN_API_KEY}" = "x" ]; then
        bbfatal "Signing API key must be defined"
    fi

    for SIGNING_ARTIFACT in ${SIGNING_ARTIFACTS}; do
        if [ -z "${SIGNING_ARTIFACT}" ] || [ ! -f "${SIGNING_ARTIFACT}" ]; then
            bbfatal "Nothing to sign"
        fi
        REQUEST_FILE=$(mktemp)
        RESPONSE_FILE=$(mktemp)
        echo "{\"key_id\": \"${SIGN_GRUB_KEY_ID}\", \"payload\": \"$(base64 -w 0 ${SIGNING_ARTIFACT})\"}" > "${REQUEST_FILE}"
        CURL_CA_BUNDLE="${STAGING_DIR_NATIVE}/etc/ssl/certs/ca-certificates.crt" \
            curl --retry 5 --fail "${SIGN_API}/gpg/sign" \
                 -X POST \
                 -H "Content-Type: application/json" \
                 -H "X-API-Key: ${SIGN_API_KEY}" \
                 -d "@${REQUEST_FILE}" \
                 -o "${RESPONSE_FILE}"
        jq -r ".signature" < "${RESPONSE_FILE}" | base64 -d > "${SIGNING_ARTIFACT}.sig"
        rm -f "${REQUEST_FILE}" "${RESPONSE_FILE}"
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

do_sign_gpg[network] = "1"
do_sign_gpg[depends] += " \
    curl-native:do_populate_sysroot \
    jq-native:do_populate_sysroot \
    ca-certificates-native:do_populate_sysroot \
    coreutils-native:do_populate_sysroot \
    gnupg-native:do_populate_sysroot \
    "

do_sign_gpg[vardeps] += " \
    SIGN_API \
    SIGN_GRUB_KEY_ID \
    "
