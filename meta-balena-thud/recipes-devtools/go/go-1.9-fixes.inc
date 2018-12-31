GO_BASEVERSION = "1.9"
FILESEXTRAPATHS_prepend := "${THISDIR}/go-${GO_BASEVERSION}:"
SRC_URI += "file://0001-Implement-arm_sync_file_range-and-SyncFileRange-wrap.patch"
