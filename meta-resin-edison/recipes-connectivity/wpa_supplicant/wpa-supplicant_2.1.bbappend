# This looks like a bug in edison-src - the patch was provided but not included in
# SRC_URI
SRC_URI_append_edison = " file://fix-libnl3-host-contamination.patch"
