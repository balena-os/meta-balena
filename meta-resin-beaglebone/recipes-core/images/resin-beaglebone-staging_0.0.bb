include resin-beaglebone.inc

IMAGE_FEATURES_append = "debug-tweaks \
			"
IMAGE_INSTALL_append = "nano htop vpn-init-staging supervisor-init-staging beaglebone-resin-supervisor-master \
			"
