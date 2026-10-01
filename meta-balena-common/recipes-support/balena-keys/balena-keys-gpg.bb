DESCRIPTION = "Balena Public GPG Keys"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://balenaos-gpg-key.conf"

inherit allarch deploy

EXCLUDE_FROM_WORLD = "1"
INHIBIT_DEFAULT_DEPS = "1"

do_deploy() {
    # Intentionally generate the keys as a part of do_deploy to avoid the possibility
    # of leaving traces in the cache. The deployed directory will be explicitly removed
    # before the end of the build, when everything is signed.

    install -d "${DEPLOYDIR}/balena-keys"

    GPGHOME="${DEPLOYDIR}/gpghome"
    install -d "${GPGHOME}"

    export GPG_TTY="$(tty)"
    gpg -vv --homedir "${GPGHOME}" --batch --generate-key "${WORKDIR}/balenaos-gpg-key.conf"
    gpg -vv --homedir "${GPGHOME}" --export > "${DEPLOYDIR}/balena-keys/grub.gpg"
    gpgconf --homedir "${GPGHOME}" --kill gpg-agent
}
do_deploy[depends] += " gnupg-native:do_populate_sysroot coreutils-native:do_populate_sysroot pinentry-native:do_populate_sysroot"
do_deploy[nostamp] = "1"
addtask deploy before do_build
