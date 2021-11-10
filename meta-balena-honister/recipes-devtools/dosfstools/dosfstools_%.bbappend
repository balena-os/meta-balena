# Starting with Gatesgarth, Poky updated from dosfstools 4.1 to dosfstools 4.2
# which already includes this patch, so we can safely remove it.
SRC_URI:remove = "file://0001-src-check.c-Fix-up-mtools-created-bad-dir-entries.patch"
