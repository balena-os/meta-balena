#
# Balena RPI signing support
#

do_sign_rsa() {
    SIGNING_ARTIFACT="${1}"
    SIGNED_ARTIFACT="${2:-"${1}.sig"}"

    if [ -z "${SIGNING_ARTIFACT}" ]; then
        bbfatal "Nothing to sign"
    fi

    if [ "x${SIGN_API}" = "x" ]; then
        bbnote "Signing API not defined"
        return 1
    fi

    if [ "x${SIGN_API_KEY}" = "x" ]; then
        bbfatal "Signing API key must be defined"
    fi

    if [ "x${SIGN_RSA_KEY_ID}" = "x" ]; then
        bbfatal "RSA key ID must be defined"
    fi

    REQUEST_FILE=$(mktemp)
    RESPONSE_FILE=$(mktemp)
    _size=$(du -b "${SIGNING_ARTIFACT}" | awk '{print $1}')
    # Timeout is 1 minute plus 1 minute per MB
    _timeout=$(expr 60 +  $_size / 1024 / 1024 \* 60)
    echo "{\"key_id\": \"${SIGN_RSA_KEY_ID}\", \"payload\": \"$(base64 -w 0 ${SIGNING_ARTIFACT})\"}" > "${REQUEST_FILE}"
    if CURL_CA_BUNDLE="${STAGING_DIR_NATIVE}/etc/ssl/certs/ca-certificates.crt" curl --retry 5 --silent --show-error --max-time ${_timeout} "${SIGN_API}/rsa/sign" -X POST -H "Content-Type: application/json" -H "X-API-Key: ${SIGN_API_KEY}" -d "@${REQUEST_FILE}" --output "${RESPONSE_FILE}"; then
        jq -r ".signature" < "${RESPONSE_FILE}" | base64 -d > "${SIGNED_ARTIFACT}"
    else
        bbfatal "Failed to sign ${SIGNING_ARTIFACT} with error $?"
    fi
    rm -f "${REQUEST_FILE}" "${RESPONSE_FILE}"
}

