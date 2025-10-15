DESCRIPTION = "Balena Public Keys"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit allarch deploy

EXCLUDE_FROM_WORLD = "1"
INHIBIT_DEFAULT_DEPS = "1"
ALLOW_EMPTY:${PN} = "1"
DEPENDS = "${@bb.utils.contains("MACHINE_FEATURES","efi","balena-db-hashes","",d)}"

# Fetch the specified public key from the signing server
#
# Arguments:
#
# $1: Key URL
# $2: JSON field with payload
# $3: Output key name
#
fetch_key() {
    DEST_DIR="${B}/balena-keys"
    if [ "x${SIGN_API}" = "x" ]; then
        bbnote "Signing API not defined"
        return
    fi
    mkdir -p "${DEST_DIR}"
    RESPONSE_FILE=$(mktemp)
    export CURL_CA_BUNDLE="${STAGING_DIR_NATIVE}/etc/ssl/certs/ca-certificates.crt"
    curl --fail "${SIGN_API}/${1}" -o "${RESPONSE_FILE}"
    if echo "${1}" | grep -q -w 'gpg/key' && [ "${2}" = ".key" ]; then
        jq -r "${2}" < "${RESPONSE_FILE}" | gpg --dearmor > "${DEST_DIR}/${3}"
    else
        jq -r "${2}" < "${RESPONSE_FILE}" > "${DEST_DIR}/${3}"
    fi
    rm -f "${RESPONSE_FILE}"
    ext="${3#*.}"
    if [ "${ext}" = "auth" ] || [ "${ext}" = "esl" ]; then
        if [ -f "${DEST_DIR}/${3}" ]; then
            tmpdir=$(mktemp -d)
            base64 -d "${DEST_DIR}/${3}" > "${tmpdir}/${3}"
            mv "${tmpdir}/${3}" "${DEST_DIR}/${3}"
            rm -rf "${tmpdir}"
        fi
    fi
}

do_get_public_keys() {
    fetch_key "kmod/cert/${SIGN_KMOD_KEY_ID}" ".cert" "kmod.crt"
    if ${@bb.utils.contains('MACHINE_FEATURES', 'efi', 'true', 'false', d)}; then
        fetch_key "gpg/key/${SIGN_GRUB_KEY_ID}" ".key" "grub.gpg"
        fetch_key "secureboot/pk/${SIGN_EFI_PK_KEY_ID}" ".pk" "PK.auth"
        fetch_key "secureboot/pk/${SIGN_EFI_PK_KEY_ID}" ".esl" "PK.esl"
        fetch_key "secureboot/kek/${SIGN_EFI_KEK_KEY_ID}" ".kek" "KEK.auth"
        fetch_key "secureboot/kek/${SIGN_EFI_KEK_KEY_ID}" ".esl" "KEK.esl"
    fi

    if [ -n "${SIGN_KMOD_KEY_APPEND}" ]; then
        bbnote "Appending additional module signing key(s) to trusted keys"
        # remove trailing newline, otherwise appended keys will be ignored
        sed -i '/^$/d' "${DEST_DIR}/kmod.crt"
        # PEM formatted x509 certs contain base64 encoded data between headers
        # and footers with dashes, which are troublesome to escape and parse properly.
        #
        # Certs are stripped of the headers and footers and joined by
        # semicolons before being accepted as a parameter. We parse that string
        # for certificates, reinserting the headers and footers before
        # appending to the trusted keys.
        #
        # As a final step, wrap to the same width that openssl uses when
        # generating certs for consistency
        (IFS=\;; for cert in "${SIGN_KMOD_KEY_APPEND}"; do
            printf -- "-----BEGIN CERTIFICATE-----\n%s\n-----END CERTIFICATE-----\n" "${cert}"
        done) | fold -w 64 >> "${DEST_DIR}/kmod.crt"
    fi
}
do_get_public_keys[cleandirs] = "${B}"
do_get_public_keys[network] = "1"
addtask get_public_keys before do_build
do_get_public_keys[depends] += " \
    curl-native:do_populate_sysroot \
    jq-native:do_populate_sysroot \
    ca-certificates-native:do_populate_sysroot \
    coreutils-native:do_populate_sysroot \
    "

do_deploy() {
    if [ -d "${B}/balena-keys" ]; then
        install -d "${DEPLOYDIR}/balena-keys"
        cp -r "${B}/balena-keys/" "${DEPLOYDIR}/"
    fi
}
addtask deploy after do_get_public_keys

deltask do_fetch
deltask do_unpack
deltask do_patch
deltask do_configure
deltask do_compile
deltask do_install

do_get_public_keys[vardeps] += " \
    SIGN_API \
    SIGN_KMOD_KEY_ID \
    SIGN_KMOD_KEY_APPEND \
    SIGN_EFI_PK_KEY_ID \
    SIGN_EFI_KEK_KEY_ID \
    "
