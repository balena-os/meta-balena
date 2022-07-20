# Ensure we have the raw balena image ready in DEPLOY_DIR_IMAGE
do_image[depends] += "balena-image:do_image_complete"
