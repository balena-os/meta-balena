FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append = " \
    file://defconfig \
    file://balenaos.cfg \
    "

RDEPENDS:${PN}:append = " openssl"

ALTERNATIVE_PRIORITY[hwclock] = "100"

# glibc enables 64bit time for stat and similar routines only if both _FILE_OFFSET_BITS=64 and _TIME_BITS=64 are set on 32bit platforms.
#
#   See https://www.phoronix.com/scan.php?page=news_item&px=Glibc-More-Y2038-Work
CFLAGS:append:class-target = " -DHAVE_PROC_UPTIME -D_TIME_BITS=64 -D_FILE_OFFSET_BITS=64"
