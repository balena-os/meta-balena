FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://0001-plymouth-systemd-append.patch \
    file://0002-plymouth-default-theme-is-resin.patch \
    file://0003-dont-start-services-in-container.patch \
    file://0004-Avoid-depending-on-systemd-ask-password-path-unit.patch \
    "
