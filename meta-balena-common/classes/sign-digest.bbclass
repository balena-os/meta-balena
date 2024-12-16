do_sign_digest () {
    if [ "x${SIGN_API}" = "x" ]; then
        bbnote "Signing API not defined"
        return 0
    fi
    if [ "x${SIGN_API_KEY}" = "x" ]; then
        bbfatal "Signing API key must be defined"
    fi

    for SIGNING_ARTIFACT in ${SIGNING_ARTIFACTS}
    do
        if [ -z "${SIGNING_ARTIFACT}" ] || [ ! -f "${SIGNING_ARTIFACT}" ]; then
            bbfatal "Nothing to sign"
        fi

        DIGEST=$(openssl dgst -hex -sha256 "${SIGNING_ARTIFACT}" | awk '{print $2}')

        REQUEST_FILE=$(mktemp)
        RESPONSE_FILE=$(mktemp)
        echo "{\"cert_id\": \"${SIGN_KMOD_KEY_ID}\", \"digest\": \"${DIGEST}\"}" > "${REQUEST_FILE}"
        CURL_CA_BUNDLE="${STAGING_DIR_NATIVE}/etc/ssl/certs/ca-certificates.crt" curl --retry 5 --fail --silent "${SIGN_API}/cert/sign" -X POST -H "Content-Type: application/json" -H "X-API-Key: ${SIGN_API_KEY}" -d "@${REQUEST_FILE}" > "${RESPONSE_FILE}"
        jq -r ".signature" < "${RESPONSE_FILE}" | base64 -d > "${SIGNING_ARTIFACT}.sig"
        rm -f "${REQUEST_FILE}" "${RESPONSE_FILE}"
    done
}

do_sign_digest[network] = "1"
do_sign_digest[depends] += " \
    openssl-native:do_populate_sysroot \
    curl-native:do_populate_sysroot \
    jq-native:do_populate_sysroot \
    ca-certificates-native:do_populate_sysroot \
    coreutils-native:do_populate_sysroot \
    gnupg-native:do_populate_sysroot \
    "

do_sign_digest[vardeps] += " \
    SIGN_API \
    SIGN_KMOD_KEY_ID \
    "
