# Make sure you have the raw resin image ready in DEPLOY_DIR_IMAGE (poky
# rocko has the raw image in the deploy dir image after the do_image_complete
# task has been finished)
do_image[depends] += "resin-image:do_image_complete"
