inherit deploy

do_sign_kmod () {
    if [ "x${SIGN_API}" = "x" ]; then
        bbnote "Signing API not defined"
        return 0
    fi
    if [ "x${SIGN_API_KEY}" = "x" ]; then
        bbfatal "Signing API key must be defined"
    fi

    for SIGNING_ARTIFACT in ${SIGNING_ARTIFACTS}; do
        if [ -z "${SIGNING_ARTIFACT}" ]; then
            bbfatal "Nothing to sign"
        fi

        UNSIGNED_ARTIFACT="${SIGNING_ARTIFACT}.unsigned"
        if [ -f "${UNSIGNED_ARTIFACT}" ]; then
            # We have already backed up the unsigned version, use it and remove the destination
            # This should only happen when re-running do_sign_kmod
            rm -f "${SIGNING_ARTIFACT}"
        elif [ -f "${SIGNING_ARTIFACT}" ]; then
            # No backup has been performed but the unsigned file exists
            # Back up the unsigned version and clean up the destination
            # This should be the most common path
            mv "${SIGNING_ARTIFACT}" "${UNSIGNED_ARTIFACT}"
        else
            bbfatal "Unable to find ${SIGNING_ARTIFACT}"
        fi

        REQUEST_FILE=$(mktemp)
        RESPONSE_FILE=$(mktemp)
        echo "{\"key_id\": \"${SIGN_KMOD_KEY_ID}\", \"payload\": \"$(base64 -w 0 ${UNSIGNED_ARTIFACT})\"}" > "${REQUEST_FILE}"
        CURL_CA_BUNDLE="${STAGING_DIR_NATIVE}/etc/ssl/certs/ca-certificates.crt" curl --fail --silent "${SIGN_API}/kmod/sign" -X POST -H "Content-Type: application/json" -H "X-API-Key: ${SIGN_API_KEY}" -d "@${REQUEST_FILE}" > "${RESPONSE_FILE}"
        jq -r ".signed" < "${RESPONSE_FILE}" | base64 -d > "${SIGNING_ARTIFACT}"
        rm -f "${REQUEST_FILE}" "${RESPONSE_FILE}"
    done
}

do_sign_kmod[depends] += " \
    curl-native:do_populate_sysroot \
    jq-native:do_populate_sysroot \
    ca-certificates-native:do_populate_sysroot \
    coreutils-native:do_populate_sysroot \
    gnupg-native:do_populate_sysroot \
    "
