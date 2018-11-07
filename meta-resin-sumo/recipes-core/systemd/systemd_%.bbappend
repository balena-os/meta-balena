FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

SRC_URI_append = " \
	file://0001-core-Don-t-redirect-stdio-to-null-when-running-in-co.patch \
	file://0003-Don-t-run-specific-services-in-container.patch \
	file://0002-remove_systemd-getty-generator.patch \
	file://0003-mount-util-add-mount_option_mangle.patch \
	file://0004-umount-Fix-memory-leak.patch \
	file://0005-umount-Add-more-asserts-and-remove-some-unused-argum.patch \
	file://0006-umount-Decide-whether-to-remount-read-only-earlier.patch \
	file://0007-umount-Provide-the-same-mount-flags-too-when-remount.patch \
	file://0008-umount-Try-unmounting-even-if-remounting-read-only-f.patch \
	file://0009-umount-Don-t-bother-remounting-api-and-ro-filesystem.patch \
	file://0010-shutdown-Reduce-log-level-of-unmounts.patch \
	"
