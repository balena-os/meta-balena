FILESEXTRAPATHS_append_vab820-quad := ":${THISDIR}/files"

SRC_URI_append_vab820-quad = " \
    file://add_env_is_nowhere.patch \
    file://change_bootcmd.patch \
"
