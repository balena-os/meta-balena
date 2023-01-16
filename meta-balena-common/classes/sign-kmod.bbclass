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
        if [ -z "${SIGNING_ARTIFACT}" ] || [ ! -f "${SIGNING_ARTIFACT}" ]; then
            bbfatal "Nothing to sign"
        fi
        REQUEST_FILE=$(mktemp)
        RESPONSE_FILE=$(mktemp)
        echo "{\"key_id\": \"${SIGN_KMOD_KEY_ID}\", \"payload\": \"$(base64 -w 0 ${SIGNING_ARTIFACT})\"}" > "${REQUEST_FILE}"
        CURL_CA_BUNDLE="${STAGING_DIR_NATIVE}/etc/ssl/certs/ca-certificates.crt" curl --fail --silent "${SIGN_API}/kmod/sign" -X POST -H "Content-Type: application/json" -H "X-API-Key: ${SIGN_API_KEY}" -d "@${REQUEST_FILE}" > "${RESPONSE_FILE}"
        jq -r ".signed" < "${RESPONSE_FILE}" | base64 -d > "${SIGNING_ARTIFACT}.signed"
        rm -f "${REQUEST_FILE}" "${RESPONSE_FILE}"
    done
}

do_sign_kmod[network] = "1"
do_sign_kmod[depends] += " \
    curl-native:do_populate_sysroot \
    jq-native:do_populate_sysroot \
    ca-certificates-native:do_populate_sysroot \
    coreutils-native:do_populate_sysroot \
    gnupg-native:do_populate_sysroot \
    "

do_package[vardeps] += " \
    SIGN_API \
    SIGN_KMOD_KEY_ID \
    "
