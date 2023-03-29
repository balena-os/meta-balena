DESCRIPTION = "Balena db hashes for UEFI secure boot"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit allarch deploy

EXCLUDE_FROM_WORLD = "1"
INHIBIT_DEFAULT_DEPS = "1"
ALLOW_EMPTY:${PN} = "1"

do_get_db() {
    DEST_DIR="${B}/balena-keys"
    if [ "x${SIGN_API}" = "x" ]; then
        bbnote "Signing API not defined"
        return
    fi
    mkdir -p "${DEST_DIR}"

    hash-to-efi-sig-list "${DEPLOY_DIR_IMAGE}"/grub-efi-boot*.efi.secureboot "${DEST_DIR}/db.esl"

    FIRST_KEK=$(echo "${SIGN_EFI_KEK_KEY_ID}" | cut -d, -f1)

    REQUEST_FILE=$(mktemp)
    echo "{\"signing_key_id\": \"${FIRST_KEK}\", \"esl\": \"$(base64 -w 0 ${DEST_DIR}/db.esl)\", \"append\": true}" > "${REQUEST_FILE}"

    export CURL_CA_BUNDLE="${STAGING_DIR_NATIVE}/etc/ssl/certs/ca-certificates.crt"
    for EFI_VAR in db dbx; do
        RESPONSE_FILE=$(mktemp)
        curl --fail "${SIGN_API}/secureboot/${EFI_VAR}" \
            -X POST \
            -H "Content-Type: application/json" \
            -H "X-API-Key: ${SIGN_API_KEY}" \
            -d "@${REQUEST_FILE}" \
            -o "${RESPONSE_FILE}"

        jq -r ".auth" < "${RESPONSE_FILE}" | base64 -d > "${DEST_DIR}/${EFI_VAR}.auth"
        rm -f "${RESPONSE_FILE}"
    done

    rm -f "${REQUEST_FILE}"
}
do_get_db[cleandirs] = "${B}"
do_get_db[network] = "1"
addtask get_db before do_build
do_get_db[depends] += " \
    curl-native:do_populate_sysroot \
    jq-native:do_populate_sysroot \
    ca-certificates-native:do_populate_sysroot \
    coreutils-native:do_populate_sysroot \
    gnupg-native:do_populate_sysroot \
    efitools-native:do_populate_sysroot \
    grub-efi:do_deploy \
    "

do_deploy() {
    mkdir -p "${DEPLOYDIR}/balena-keys/"
    for DB_FILE in "${B}/balena-keys/"*; do
        cp "${DB_FILE}" "${DEPLOYDIR}/balena-keys/"
    done
}
addtask deploy after do_get_db

deltask do_fetch
deltask do_unpack
deltask do_patch
deltask do_configure
deltask do_compile
deltask do_install

do_package[vardeps] += " \
    SIGN_API \
    SIGN_EFI_KEK_KEY_ID \
    "
