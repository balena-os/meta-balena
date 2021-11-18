inherit deploy

# Do not run on native recipes
do_sign_efi:class-native() {
    :
}

do_sign_efi () {
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
        echo "{\"key_id\": \"${SIGN_EFI_KEY_ID}\", \"payload\": \"$(base64 -w 0 ${SIGNING_ARTIFACT})\"}" > "${REQUEST_FILE}"
        CURL_CA_BUNDLE="${STAGING_DIR_NATIVE}/etc/ssl/certs/ca-certificates.crt" curl --fail "${SIGN_API}/secureboot/efi" -X POST -H "Content-Type: application/json" -H "X-API-Key: ${SIGN_API_KEY}" -d "@${REQUEST_FILE}" > "${RESPONSE_FILE}"
        jq -r ".signed" < "${RESPONSE_FILE}" | base64 -d > "${SIGNING_ARTIFACT}.signed"
        rm -f "${REQUEST_FILE}" "${RESPONSE_FILE}"
    done
}

do_deploy_append:class-target() {
    for SIGNING_ARTIFACT in ${SIGNING_ARTIFACTS}; do
        if [ -f "${SIGNING_ARTIFACT}.signed" ]; then
            install -m 0644 "${SIGNING_ARTIFACT}.signed" "${DEPLOYDIR}/"$(basename ${SIGNING_ARTIFACT}).signed
        fi
    done
}

do_sign_efi[depends] += " \
    curl-native:do_populate_sysroot \
    jq-native:do_populate_sysroot \
    ca-certificates-native:do_populate_sysroot \
    coreutils-native:do_populate_sysroot \
    gnupg-native:do_populate_sysroot \
    "
