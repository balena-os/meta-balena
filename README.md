# Resin.io layer for Yocto.

This repository enables building of resin.io support for various devices.

* meta-resin-common directory has the recipies common to all our builds.
* meta-resin-<board> directory has the recipies specific to a board.


The following gives a rough overview of the directories inside individual layers.

* **classes** : Has the reusable components used by various recipes. 
    * classes/image-resin-rpi.bbclass - Has the functions used for putting together the image. Yocto generates the rootfs and boot partition tars which are put together with the noobs installer. This function currently enables two new FS types - resin-noobs and resin-noobs-dev that are used in resin-rpi and resin-rpi-dev

* **conf** : Has the configuration file which tells the yocto's builder [bitbake] to use this repo. This is mostly never changed.

* **recipes-core** : The structure of this directory is mimicked from the yocto layers to override the psplash and the image recipes [resin-rpi and resin-rpi-dev] that are actually to be called to put together the build.

* **recipes-devtools** : This has the docker recipe that uses docker-arm.

* **recipes-images** : This has all the other files used in deployment - We currently use the rpi-init to initialise the btrfs partition along with adding in the initial supervisor build. supervisot-init is used to launch the supervisor.

* **recipes-kernel** : This has the recipe for adding additional build configs to the BSP kernel to enable docker support.

