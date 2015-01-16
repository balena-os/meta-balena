FILESEXTRAPATHS_prepend := "${THISDIR}/config:"
SRC_URI_append = "file://docker.cfg \
		  file://device_drivers.cfg \
                "
KERNEL_CONFIG_FRAGMENTS_append = " \
				${WORKDIR}/docker.cfg \
				${WORKDIR}/device_drivers.cfg \
				"
