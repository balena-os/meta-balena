DESCRIPTION = "Balena Public Keys"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

ALLOW_EMPTY:${PN} = "1"

SRC_URI = ""

S = "${WORKDIR}"

inherit allarch
inherit deploy

DEPENDS = "ca-certificates-native coreutils-native curl-native jq-native"

do_patch[noexec] = "1"
do_configure() {
    if [ "x${SIGN_API}" != "x" ]; then
        return 0
    fi

    DEST_DIR="${B}/balena-keys"

    mkdir -p "${DEST_DIR}"

    export CURL_CA_BUNDLE="${STAGING_DIR_NATIVE}/etc/ssl/certs/ca-certificates.crt"

    # Get public GPG key for GRUB
    if [ "x${SIGN_GRUB_KEY_ID}" = "x" ]; then
        RESPONSE_FILE=$(mktemp)
        curl --fail "${SIGN_API}/gpg/key/${SIGN_GRUB_KEY_ID}" > "${RESPONSE_FILE}"
        jq -r ".key" < "${RESPONSE_FILE}" | gpg --dearmor > "${DEST_DIR}/grub.gpg"
        rm -f "${RESPONSE_FILE}"
    fi

    # Get public key for 3rd party kernel module signing
    if [ "x${SIGN_KMOD_KEY_ID}" = "x" ]; then
        RESPONSE_FILE=$(mktemp)
        curl --fail "${SIGN_API}/kmod/cert/${SIGN_KMOD_KEY_ID}" > "${RESPONSE_FILE}"
        jq -r .cert "${RESPONSE_FILE}" > "${DEST_DIR}/kmod.crt"
        rm -f "${RESPONSE_FILE}"
    fi

    # Get PK EFI variable
    if [ "x${SIGN_EFI_PK_KEY_ID}" = "x" ]; then
        RESPONSE_FILE=$(mktemp)
        curl --fail "${SIGN_API}/secureboot/pk/${SIGN_EFI_PK_KEY_ID}" > "${RESPONSE_FILE}"
        jq -r .pk "${RESPONSE_FILE}" > "${DEST_DIR}/PK.auth"
        rm -f "${RESPONSE_FILE}"
    fi

    # Get KEK EFI variable
    if [ "x${SIGN_EFI_KEK_KEY_ID}" = "x" ]; then
        RESPONSE_FILE=$(mktemp)
        curl --fail "${SIGN_API}/secureboot/kek/${SIGN_EFI_KEK_KEY_ID}" > "${RESPONSE_FILE}"
        jq -r .kek "${RESPONSE_FILE}" > "${DEST_DIR}/KEK.auth"
        jq -r .esl "${RESPONSE_FILE}" > "${DEST_DIR}/KEK.esl"
        rm -f "${RESPONSE_FILE}"
    fi

    # Get db EFI variable
    if [ "x${SIGN_EFI_KEY_ID}" = "x" ]; then
        RESPONSE_FILE=$(mktemp)
        curl --fail "${SIGN_API}/secureboot/db/${SIGN_EFI_KEY_ID}" > "${RESPONSE_FILE}"
        jq -r .db "${RESPONSE_FILE}" > "${DEST_DIR}/db.auth"
        jq -r .esl "${RESPONSE_FILE}" > "${DEST_DIR}/db.esl"
        rm -f "${RESPONSE_FILE}"
    fi
}
do_compile[noexec] = "1"
do_build[noexec] = "1"
do_install() {
    DESTDIR="/usr/share/balena-keys"
}
do_deploy() {
    DESTDIR="${DEPLOYDIR}/balena-keys/"
    mkdir "${DESTDIR}"
}
