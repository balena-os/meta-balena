include resin-rpi.inc

IMAGE_FEATURES_append = "debug-tweaks \
                        "
IMAGE_INSTALL_append = "nano supervisor-init-staging vpn-init-staging \
			"
IMAGE_FSTYPES_forcevariable = "resin-noobs-dev"
