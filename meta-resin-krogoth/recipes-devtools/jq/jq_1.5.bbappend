

FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

SRC_URI += "file://Support-without-oniguruma.patch"

DEPENDS_remove_class-native = "onig-native"

EXTRA_OECONF_append_class-native = "--without-oniguruma"

BBCLASSEXTEND = "native"
