do_install:append() {
	rm -f "${D}/usr/bin/zstdgrep" "${D}/usr/bin/zstdless" "${D}/usr/bin/pzstd"
}
