# Resin.io layer for Yocto.

The following gives a rough overview of the directories.

* **classes** : Has the reusable components used by various recipes. 
    * classes/image-resin-rpi.bbclass - Has the functions used for putting together the image. Yocto generates the rootfs and boot partition tars which are put together with the noobs installer.

* **conf** : Has the configuration file which tells the yocto's builder [bitbake] to use this repo. This is mostly never changed.

* **recipes-core** : The structure of this directory is mimicked from the yocto layers to override the psplash and the image recipes that are actually to be called to put together the build.

* **recipes-devtools** : This has the docker recipe that uses docker-arm.

* **recipes-images** : This has all the other files used in deployment - We currently use the rpi-init to initialise the btrfs partition along with adding in the initial supervisor build. supervisot-init is used to launch the supervisor.

* **recipes-kernel** : This has the recipe for adding additional build configs to the BSP kernel to enable docker support.

This layer is designed to be used by yocto-resin-rpi or other device specific build repos we have.      