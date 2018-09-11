# Temporary bbclass to ease resin->balena transition

python __anonymous () {
	bb.warn("kernel-resin bbclass is deprecated and will be removed in the next releases. The new bbclass name is balena-kernel.")
}

inherit balena-kernel
