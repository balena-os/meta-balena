# This is a resin image
include recipes-core/images/resin-image.inc

# We modify the sdcard construction
inherit classes/sdcard_image_resin-rpi.bbclass
