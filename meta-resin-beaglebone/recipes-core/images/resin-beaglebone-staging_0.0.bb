include resin-beaglebone.inc

IMAGE_FEATURES_append = "debug-tweaks \
			"
IMAGE_INSTALL_append = "nano htop vpn-init supervisor-init beaglebone-resin-supervisor-master \
			"
