# glibc enables 64bit time for stat and similar routines only if both _FILE_OFFSET_BITS=64 and _TIME_BITS=64 are set on 32bit platforms.
# jq is used in the HUP scripts to access config.json.
#   See https://www.phoronix.com/scan.php?page=news_item&px=Glibc-More-Y2038-Work
CFLAGS:append:class-target = " -DHAVE_PROC_UPTIME -D_TIME_BITS=64 -D_FILE_OFFSET_BITS=64"
