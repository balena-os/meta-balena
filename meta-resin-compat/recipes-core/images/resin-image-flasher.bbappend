# Make sure you have the resin-image rootfs ready
IMAGE_DEPENDS_resin-sdcard_append = " resin-image:do_rootfs"

# This task is not available in poky versions older than krogoth
IMAGE_DEPENDS_resin-sdcard_remove = " resin-image:do_image_complete"
