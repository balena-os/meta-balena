# Fix setscene depends on jpeg
# http://lists.openembedded.org/pipermail/openembedded-core/2014-July/094617.html
PIXBUFCACHE_SYSROOT_DEPS_class-native += "jpeg-native:do_populate_sysroot_setscene"
