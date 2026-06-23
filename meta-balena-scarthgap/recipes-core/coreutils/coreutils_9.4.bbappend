# coreutils 9.4 (scarthgap) derives 'uptime' solely from a utmp BOOT_TIME record
# and no longer reads /proc/uptime. balenaOS has no usable BOOT_TIME entry in
# utmp, so uptime fails with "couldn't get boot time" and prints "up ???? days".
# Restore the pre-9.4 /proc/uptime read, gated on the -DHAVE_PROC_UPTIME flag that
# meta-balena-common's coreutils bbappend already sets (a dead no-op against 9.4's
# rewritten uptime.c until this patch revives it).
#
# Pinned to coreutils 9.4 in the scarthgap layer on purpose: older layers
# (dunfell/honister/kirkstone, coreutils 8.32-9.1) still ship the working
# /proc/uptime code, and this patch's context would not apply to them. The
# version-pinned filename means it only ever attaches to coreutils_9.4.bb.
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append = " file://0001-uptime-restore-proc-uptime-fallback.patch"
