include resin-rpi.inc

IMAGE_INSTALL_append = "supervisor-init vpn-init \
			"

IMAGE_FSTYPES_forcevariable = "resin-noobs"
