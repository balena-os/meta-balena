CONNECTIVITY_MODULES_append_edison = " \
    bcm43340-mod \
    "

CONNECTIVITY_FIRMWARES_append_edison = " \
    bcm43340-bt \
    bcm43340-fw \
    "

# TODO
# There is no linux firmware in daisy
CONNECTIVITY_FIRMWARES_remove_edison = "linux-firmware-bcm43143"
