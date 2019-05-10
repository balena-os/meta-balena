# Since thud, TARGET_ARCH was changed to TUNE_PKGARCH while out go recipes are
# based on an older yocto version.
DEPENDS = "virtual/${TUNE_PKGARCH}-go go-native"
