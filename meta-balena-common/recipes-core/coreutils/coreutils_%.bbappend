# glibc enables 64bit time for stat and similar routines only if both _FILE_OFFSET_BITS=64 and _TIME_BITS=64 are set on 32bit platforms.
#
# We thus set them to avoid HUP failing when both conditions below are met simultaneously:
# - files in the current OS boot partitions have any of m_time/c_time/a_time set to a value that exceeds year 2038,
#   because mtcopy did not preserve the creation date during copying to the boot partition at build time.
# - HUP is done to a system that uses glibc 2.34 or newer, which now returns EOVERFLOW if 32bit fallback functions are
#   used on time structures that hold 64bit time values.
#
#   HUP failure would have been caused by commands like mkdir mv etc, which would return an error exit code when checking
#   if the file to be created/replaced already exists by using stat() internally.
#
#   See https://www.phoronix.com/scan.php?page=news_item&px=Glibc-More-Y2038-Work
CFLAGS:append:class-target = " -DHAVE_PROC_UPTIME -D_TIME_BITS=64 -D_FILE_OFFSET_BITS=64"
