# Temporary bbclass to ease resin->balena transition

python __anonymous () {
	bb.warn("resin-u-boot bbclass is deprecated and will be removed in the next releases. The new bbclass name is balena-u-boot.")
}

inherit balena-u-boot
