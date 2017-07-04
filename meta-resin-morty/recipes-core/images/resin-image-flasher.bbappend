# Make sure you have the resin raw image ready in DEPLOY_DIR_IMAGE (poky
# krogoth/morty has the raw image in the deploy dir image after the
# do_image_complete task has been finished)
IMAGE_DEPENDS_resinos-img_append = " resin-image:do_image_complete"
