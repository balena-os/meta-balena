FILESEXTRAPATHS_append := ":${THISDIR}/${BPN}"

SRC_URI_append = "\
        file://0001-cfgparser-Modify-bootcfg-path-to-work-with-a-balena-.patch \
	file://0002-kexecboot-Add-configuration-option-to-boot-directly-.patch \
	file://0003-kexecboot-Avoid-segmentation-failt-if-no-item-select.patch \
	file://0004-kexecboot-Add-a-reuse-cmdline-configuration-option.patch \
"

EXTRA_OECONF_append = " --enable-default-boot --enable-no-checks --enable-reuse-cmdline"
