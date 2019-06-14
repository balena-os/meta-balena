FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://0002-plymouth-systemd-append.patch \
    file://0003-plymouth-Default-theme-is-resin.patch \
    file://0004-Avoid-depending-on-systemd-ask-password-path-unit.patch \
    file://0005-dont-start-services-in-container.patch \
    "
