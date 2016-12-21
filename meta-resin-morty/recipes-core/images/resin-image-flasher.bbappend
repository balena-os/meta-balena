# Make sure you have the sdcard resin image ready in DEPLOY_DIR_IMAGE (poky krogoth/morty has the sdcard image in the deploy dir image after the do_image_complete task has been finished)
IMAGE_DEPENDS_resin-sdcard_append = " resin-image:do_image_complete"
