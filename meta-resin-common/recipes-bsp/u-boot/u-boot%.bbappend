inherit u-boot-header-mod

APPEND_ENV_FILE = "rEnv.append"

FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot:"
SRC_URI_append = " file://${APPEND_ENV_FILE}"
