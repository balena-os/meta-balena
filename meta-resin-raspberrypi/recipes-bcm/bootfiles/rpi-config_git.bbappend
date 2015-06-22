do_deploy_append() {
    # Enable i2c by default
    echo "dtparam=i2c_arm=on" >>${DEPLOYDIR}/bcm2835-bootfiles/config.txt
    # Enable SPI by default
    echo "dtparam=spi=on" >>${DEPLOYDIR}/bcm2835-bootfiles/config.txt
    # Enable One Wire by default
    echo "device_tree_overlay=w1-gpio-pullup-overlay.dtb" >> ${DEPLOYDIR}/bcm2835-bootfiles/config.txt
}
