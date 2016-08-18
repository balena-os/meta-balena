# Contributing new board support to resin.io

Pre-requisites: yocto BSP layer for your particular board, supplying the BSP (board support package). Should be compatible to the yocto releases resin currently supports.

Every repository used to build a resin.io host Operating System is typically named resin-`<board-family>`. For example, consider the [resin-intel][resin-intel repo] repository which can be used to build a resin.io image for
the Intel NUC boards.

### Repository breakout
-----------------------

The resin-`<board-family>` repository uses git submodules for including required subprojects.

The root directory shall contain 2 directory entries: a "layers" directory and the [resin-yocto-scripts][resin-yocto-scripts] git submodule.
This submodule is typically using latest master branch.
The root directory also includes the following files: CHANGELOG.md, LICENSE, README.md, VERSION and one or more files (depending on the number of supported boards)
named `<yocto-machine-name>`.coffee (e.g. [intel-corei7-64.coffee][intel-corei7-64 coffee]) which correspond to each of the boards this repository will add support for.

The "layers" directory contains the git submodules of the yocto layers used in the build process. This normally means the following components are present:

- [poky][poky]  at the revision required by the board BSP
- [meta-openembedded][meta-openembedded] at the revision poky uses
- [meta-resin][meta-resin] using the master branch
- [oe-meta-go][oe-meta-go] using the master branch (there were no branches corresponding to the yocto releases at the time this howto was written)
- yocto BSP layer for the board (for example, the BSP layer for Intel NUC is [meta-intel][meta-intel repo])
- additional yocto layers required by the board BSP (check the yocto BSP layer of the respective board for instructions on how to build the BSP and what are the yocto dependencies of that particular BSP layer)

In addition to the above git submodules, the "layers" directory also contains a meta-resin-`<board-family>` directory (please note this directory is not a git submodule). This directory contains the required customization for making a board resin.io enabled.
For example, the [resin-intel][resin-intel repo] repository contains the directory `layers/meta-resin-intel` to supplement the bsp from `layers/meta-intel` git submodule.

### meta-resin-`<board-family>` breakout
----------------------------------------

This directory contains a COPYING.Apache-2.0 file with the Apache Version 2.0 license, a README.md file specifying the supported boards and a number of directories out of which the mandatory ones are:

- conf directory - contains the following files:

    - layer.conf (see this [layer.conf][layer.conf intel] for an example)

    - samples/bblayers.conf.sample file in which all the required yocto layers are listed (see this [bblayers.conf.sample][bblayers.conf.sample intel] for an example)

    - samples/local.conf.sample file which defines part of the build configuration (see the meta-resin [README.md][meta-resin-readme] for an overview of some of the variables used
    in the local.conf.sample file). An existing file can be used (e.g. [local.conf.sample][local.conf.sample intel]) but making sure the "Supported machines" area lists the appropriate machines this repository is used for.

- recipes-containers/docker-disk directory - contains docker-resin-supervisor-disk.bbappend that shall define the following variable(s):

    - SUPERVISOR_REPOSITORY_`<yocto-machine-name>`

        This variable is used to specify the build of the supervisor. It can be one of (must match the architecture of the board): **resin/armv7hf-supervisor** (for armv7 boards), **resin/i386-supervisor**
        (for x86 boards), **resin/amd64-supervisor** (for x86-64 boards), **resin/rpi-supervisor** (for raspberry pi 1), **resin/armel-supervisor** (for armv5 boards).

    - LED_FILE_`<yocto-machine-name>`

        This variable should point to the linux sysfs path of an unused LED if available for that particular board. (this allows the unused LED to be flashed from the resin.io dashboard for quick visual device
        identification purposes). If no such unused LED exists, this variable shall not be used.

- recipes-core/images directory: shall contain at least a resin-image.bbappend file

    Depending on the type of board you are adding support for, you should have your device support either just resin-image or both resin-image-flasher and resin-image. Generally, resin-image is for boards that boot directly
from external storage (these boards do not have internal storage to install resin.io on). resin-image-flasher is used when the targeted board has internal storage so this flasher image is burned onto an SD card or USB
stick that is used for the initial boot. When booted, this flasher image will automatically install resin.io on internal storage.

    The resin-image.bbappend file shall define the following variables:

    - IMAGE_FSTYPES_`<yocto-machine-name>`

        This variable is used to declare the type of the produced image (it can be ext3, ext4, resin-sdcard etc. The usual type for a board that can boot from SD card, USB, is "resin-sdcard").

    - RESIN_BOOT_PARTITION_FILES_`<yocto-machine-name>`

        This allows adding files from the build's deploy directory into the vfat formatted resin-boot partition (can be used to add bootloader config files, first stage bootloader,
        initramfs or anything else needed for the booting process to take place for your particular board). If the board uses different bootloader configuration files when booting from either
        external media (USB thumb drive, SD card etc.) or from internal media (mSATA, eMMC etc) then you would want make use of this variable to make sure the different bootloader configuration files
        get copied over and further manipulated as needed (see INTERNAL_DEVICE_BOOTLOADER_CONFIG_`<yocto-machine-name>` and INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH_`<yocto-machine-name>` below). Please note that
        you only reference these files here, it is the responsability of a .bb or .bbappend to provide and deploy them (for bootloader config files this is done with an append typically in
        recipes-bsp/`<your board's bootloader>`/`<your board's bootloader>`.bbappend, see [resin-intel grub bbappend][resin-intel grub append] for an example)

        It is a space separated list of items with the following format: *FilenameRelativeToDeployDir:FilenameOnTheTarget*. If *FilenameOnTheTarget* is omitted then the *FilenameRelativeToDeployDir* will be used.

        For example to have the Intel NUC bzImage-intel-corei7-64.bin copied from deploy directory over to the boot partition, renamed to vmlinuz:
        ```sh
        RESIN_BOOT_PARTITION_FILES_nuc = "bzImage-intel-corei7-64.bin:vmlinuz"
        ```

    The resin-image-flasher.bbappend file shall define the following variables:

    - IMAGE_FSTYPES_`<yocto-machine-name>` (see above)

    - RESIN_BOOT_PARTITION_FILES_`<yocto-machine-name>` (see above).
        For example, if the board uses different bootloader configuration files for booting from SD/USB and internal storage (see below the use of
        INTERNAL_DEVICE_BOOTLOADER_CONFIG variable), then make sure these files end up in the boot partition (i.e. they should be listed in this RESIN_BOOT_PARTITION_FILES_`<yocto-machine-name>` variable)

- recipes-kernel/linux directory: shall contain a .bbappend to the kernel recipe used by the respective board. This kernel .bbappend must "inherit kernel-resin" in order to add the necessary kernel configs for using with resin.io

- recipes-support/resin-init directory - shall contain a resin-init-flasher.bbappend file if you intend to install resin.io to internal storage and hence use the flasher image. This shall define the following variables:

    - INTERNAL_DEVICE_KERNEL_`<yocto-machine-name>`

        This variable is used to identify the internal storage where resin.io will be written to.

    - INTERNAL_DEVICE_BOOTLOADER_CONFIG_`<yocto-machine-name>`

        This variable is used to specify the filename of the bootloader configuration file used by your board when booting from internal media (must be the same with the *FilenameOnTheTarget* parameter
        of the bootloader internal config file used in the RESIN_BOOT_PARTITION_FILES_`<yocto-machine-name>` variable from recipes-core/images/resin-image-flasher.bbappend);

    - INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH_`<yocto-machine-name>`

        This variable is used to specify the relative path (including filename) to the resin-boot partition where INTERNAL_DEVICE_BOOTLOADER_CONFIG_`<yocto-machine-name>` will be copied to.

        For example, setting
        ```sh
        INTERNAL_DEVICE_BOOTLOADER_CONFIG_intel-corei7-64 = "grub.cfg_internal"
        ```
        and
        ```sh
        INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH_intel-corei7-64 = "/EFI/BOOT/grub.cfg"
        ```
        will result that after flashing the file grub.cfg_internal is copied with the name grub.cfg to the /EFI/BOOT/ directory on the resin-boot partition.

[resin-intel repo]: https://github.com/resin-os/resin-intel
[resin-intel grub append]: https://github.com/resin-os/resin-intel/tree/master/layers/meta-resin-intel/recipes-bsp/grub
[meta-intel repo]: http://git.yoctoproject.org/cgit/cgit.cgi/meta-intel
[intel-corei7-64 coffee]: https://github.com/resin-os/resin-intel/blob/master/intel-corei7-64.coffee
[resin-yocto-scripts]: https://github.com/resin-os/resin-yocto-scripts
[poky]: http://git.yoctoproject.org/cgit/cgit.cgi/poky
[meta-openembedded]: https://github.com/openembedded/meta-openembedded
[meta-resin]: https://github.com/resin-os/meta-resin
[oe-meta-go]: https://github.com/mem/oe-meta-go
[layer.conf intel]: https://github.com/resin-os/resin-intel/blob/master/layers/meta-resin-intel/conf/layer.conf
[meta-resin-readme]: https://github.com/resin-os/meta-resin/blob/master/README.md
[local.conf.sample intel]: https://github.com/resin-os/resin-intel/blob/master/layers/meta-resin-intel/conf/samples/local.conf.sample
[bblayers.conf.sample intel]: https://github.com/resin-os/resin-intel/blob/master/layers/meta-resin-intel/conf/samples/bblayers.conf.sample
