# These flags are enabled system-wide
# so that 32bit kernels can succesfully
# access files with invalid modification times (i.e config.json)
# However, some packages fail to build with these
# so we therefore remove them
# See https://www.phoronix.com/scan.php?page=news_item&px=Glibc-More-Y2038-Work
TARGET_CFLAGS:remove = "-D_TIME_BITS=64"
TARGET_CFLAGS:remove = "-D_FILE_OFFSET_BITS=64"
