# Contributing New Board Support to Balena.io

Pre-requisites: a [Yocto](https://www.yoctoproject.org) Board Support Package (BSP) layer for your particular board. It should be compatible to the Yocto releases balenaOS supports.

Repositories used to build balenaOS host Operating System (OS) are typically named balena-`<board-family>`. For example, consider [balena-raspberrypi](https://github.com/balena-os/balena-raspberrypi) which is used for building the OS for [Raspberryi Pi](https://raspberrypi.org), or [balena-intel][balena-intel repo] repository which can be used to build a balena.io image for the Intel NUC boards.

Contributing support for a new board consists of creating a Yocto layer that includes:

* general hardware support for the specific board,
* the balenaOS-specific software features,
* deployment-specific features (i.e. settings to create SD card, USB thumb drive, or self-flashing images)

The following documentations walks you through the steps of creating such a Yocto package. Because of the substantial difference between the hardware of many boards, this document provides general directions, and often it might be helpful to see the examples of already supported boards. The list of the relevant repositories is found at the end of this document.

## Board Support Repository Breakout

The balena-`<board-family>` repositories use [git submodules](https://git-scm.com/docs/git-submodule) for including required Yocto layers from the relevant sub-projects.

The root directory contains:

|Directories|
|:-----------------:|
|  `layers` |
| [balena-yocto-scripts][balena-yocto-scripts] (git submodule)|

and

|Files|
|:-----------------:|
| `CHANGELOG.md`|
|`LICENSE`|
|`README.md`|
|`VERSION`|
|`repo.yml`|
|`<board-name>.svg`|
|`coffee file(s)`|

_Note: you add submodules by `git submodule add <url> <directory>`, see the git documentation for more details._

### About coffee file(s)

One or more files named `<board-name>.coffee`, where `<board-name>` is equal to the corresponding `yocto-machine-name`. Should add one for each of the boards that the repository adds support for (eg. [`raspberry-pi3.coffee`](https://github.com/balena-os/balena-raspberrypi/blob/master/raspberrypi3.coffee) for Raspberry Pi 3 in `balena-raspberrypi`). This file contains information on the Yocto build for the specific board, in [CoffeeScript](http://coffeescript.org/) format. A minimal version of this file, using [Raspberry Pi 3 as the example](https://github.com/balena-os/balena-raspberrypi/), would be:

```
module.exports =
  yocto:
    machine: 'raspberrypi3'
    image: 'resin-image'
    fstype: 'resinos-img'
    version: 'yocto-jethro'
    deployArtifact: 'resin-image-raspberrypi3.resinos-img'
    compressed: true
```

### Layers directory breakdout

The layout for the `layers` directory:

```
├── CHANGELOG.md
├── LICENSE
├── README.md
├── VERSION
├── repo.yml
├── <board-name-1>.svg
├── <board-name-2>.svg
├── layers
│   ├── meta-openembedded
│   ├── meta-<vendor>
│   ├── meta-balena
│   ├── meta-balena-<board-family>
│   ├── oe-meta-go
│   └── poky
├── <board-name-1>.coffee
├── <board-name-2>.coffee
...
└── balena-yocto-scripts
```

The `layers` directory contains the git submodules of the yocto layers used in the build process. This normally means the following components are present:

- [poky][poky]  at the version/revision required by the board BSP
- [meta-openembedded][meta-openembedded] at the revision poky uses
- [meta-balena][meta-balena] using the master branch
- [meta-rust][meta-rust] at the revision poky uses
- Yocto BSP layer for the board (for example, the BSP layer for Raspberry Pi is [meta-raspberrypi](https://github.com/agherzan/meta-raspberrypi))
- any additional Yocto layers required by the board BSP (check the Yocto BSP layer of the respective board for instructions on how to build the BSP and what are the Yocto dependencies of that particular BSP layer)

In addition to the above git submodules, the `layers` directory requires a meta-balena-`<board-family>` directory (please note this directory is _not_ a git submodule). This directory contains the required customization for making a board balena.io enabled. For example, the [balena-raspberrypi](https://github.com/balena-os/balena-raspberrypi) repository contains the directory `layers/meta-balena-raspberrypi` to supplement the BSP from `layers/meta-raspberrypi` git submodule, with any changes that might be required by balenaOS.

## meta-balena-`<board-family>` breakout

This directory contains optional and mandatory directories:

|Mandatory                                                  |Optional (as needed)|
|:------------------------------------------------------:|:---------------------------------:|
|    `conf`                                                         | `recipes-containers/docker-disk` |
|    `recipes-core/images`                     | |
|    `recipes-kernel/linux directory` | |
|    `recipes-support/resin-init`          | |


###  `conf` directory - contains the following files:

  1. `layer.conf`, see the [layer.conf](https://github.com/balena-os/balena-raspberrypi/blob/master/layers/meta-balena-raspberrypi/conf/layer.conf) from `meta-balena-raspberrypi` for an example, and see [Yocto documentation](http://www.yoctoproject.org/docs/2.0/mega-manual/mega-manual.html#bsp-filelayout-layer)
   2. `samples/bblayers.conf.sample` file in which all the required Yocto layers are listed, see this [bblayers.conf.sample](https://github.com/balena-os/balena-raspberrypi/blob/master/layers/meta-balena-raspberrypi/conf/samples/bblayers.conf.sample) from `meta-balena-raspberrypi` for an example, and see the [Yocto documentation](http://www.yoctoproject.org/docs/2.0/mega-manual/mega-manual.html#var-BBLAYERS)
   3. `samples/local.conf.sample` file which defines part of the build configuration (see the meta-balena [README.md][meta-balena-readme] for an overview of some of the variables use in the `local.conf.sample` file). An existing file can be used (e.g. [local.conf.sample](https://github.com/balena-os/balena-raspberrypi/blob/master/layers/meta-balena-raspberrypi/conf/samples/local.conf.sample)) but making sure the "Supported machines" area lists the appropriate machines this repository is used for. See also the [Yocto documentation](http://www.yoctoproject.org/docs/2.0/mega-manual/mega-manual.html#structure-build-conf-local.conf).


### `recipes-core/images` directory

Which contains at least a `resin-image.bbappend` file. Depending on the type of board you are adding support for, you should have your device support either just `resin-image` or both `resin-image-flasher` and `resin-image`. Generally, `resin-image` is for boards that boot directly from external storage (these boards do not have internal storage to install balena.io on). `resin-image-flasher` is used when the targeted board has internal storage so this flasher image is burned onto an SD card or USB stick that is used for the initial boot. When booted, this flasher image will automatically install balena.io on internal storage.

  The `resin-image.bbappend` file shall define the following variables:

***
- `IMAGE_FSTYPES_<yocto-machine-name>`: this variable is used to declare the type of the produced image. It can be ext3, ext4, resinos-img etc. The usual type for a board that can boot from SD card, USB, is "resinos-img".

- `RESIN_BOOT_PARTITION_FILES_<yocto-machine-name>`: this allows adding files from the build's deploy directory into the vfat formatted resin-boot partition (can be used to add bootloader config files, first stage bootloader, initramfs or anything else needed for the booting process to take place for your particular board). If the board uses different bootloader configuration files when booting from either external media (USB thumb drive, SD card etc.) or from internal media (mSATA, eMMC etc) then you would want to make use of this variable to make sure the different bootloader configuration files get copied over and further manipulated as needed (see `INTERNAL_DEVICE_BOOTLOADER_CONFIG_<yocto-machine-name>` and `INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH_<yocto-machine-name>` below). Please note that you only reference these files here, it is the responsibility of a `.bb` or `.bbappend` to provide and deploy them (for bootloader config files this is done with an append typically in `recipes-bsp/<your board's bootloader>/<your board's bootloader>.bbappend`, see [balena-intel grub bbappend][balena-intel grub append] for an example).

 It is a space separated list of items with the following format: *FilenameRelativeToDeployDir:FilenameOnTheTarget*. If *FilenameOnTheTarget* is omitted then the *FilenameRelativeToDeployDir* will be used.

  For example to have the Intel NUC `bzImage-intel-corei7-64.bin` copied from deploy directory over to the boot partition, renamed to `vmlinuz`:

    ```sh   RESIN_BOOT_PARTITION_FILES_nuc =  "bzImage-intel-corei7-64.bin:vmlinuz"    ```
***

  The `resin-image-flasher.bbappend` file shall define the following variables:

***
- `IMAGE_FSTYPES_<yocto-machine-name>` (see above)
- `RESIN_BOOT_PARTITION_FILES_<yocto-machine-name>` (see above). For example, if the board uses different bootloader configuration files for booting from SD/USB and internal storage (see below the use of `INTERNAL_DEVICE_BOOTLOADER_CONFIG` variable), then make sure these files end up in the boot partition (i.e. they should be listed in this `RESIN_BOOT_PARTITION_FILES_<yocto-machine-name>` variable)

***

### `recipes-kernel/linux directory`

 Shall contain a `.bbappend` to the kernel recipe used by the respective board. This kernel `.bbappend` must "inherit kernel-resin" in order to add the necessary kernel configs for using with balena.io

### `recipes-support/resin-init` directory

Shall contain a `resin-init-flasher.bbappend` file if you intend to install balena.io to internal storage and hence use the flasher image.


`resin-init-flasher.bbappend` should define the following variables:

***
  - `INTERNAL_DEVICE_KERNEL_<yocto-machine-name>`: used to identify the internal storage where balena.io will be written to.

  - `INTERNAL_DEVICE_BOOTLOADER_CONFIG_<yocto-machine-name>`: used to specify the filename of the bootloader configuration file used by your board when booting from internal media. Must be the same as the *FilenameOnTheTarget* parameter of the bootloader internal config file used in the `RESIN_BOOT_PARTITION_FILES_<yocto-machine-name>` variable from `recipes-core/images/resin-image-flasher.bbappend`.

  - `INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH_<yocto-machine-name>`: used to specify the relative path, including filename, to the resin-boot partition where `INTERNAL_DEVICE_BOOTLOADER_CONFIG_<yocto-machine-name>` will be copied to.

    For example, setting

    ```sh    INTERNAL_DEVICE_BOOTLOADER_CONFIG_intel-corei7-64 = "grub.cfg_internal"    ````
    and
    ```sh    INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH_intel-corei7-64 = "/EFI/BOOT/grub.cfg"    ```
    will result that after flashing the file `grub.cfg`_internal is copied with the name `grub.cfg` to the /EFI/BOOT/ directory on the resin-boot partition.


  - `BOOTLOADER_FLASH_DEVICE`: used to identify the internal storage where the bootloader needs to be flashed to. This is only the case usually when the bootloader needs to be in a SPI flash like memory where the bootrom code expect it to read it from raw disk instead from a partition.
    Note that if `BOOTLOADER_FLASH_DEVICE` is set, then also `BOOTLOADER_IMAGE`, `BOOTLOADER_BLOCK_SIZE_OFFSET` and `BOOTLOADER_SKIP_OUTPUT_BLOCKS` need to be set.

  - `BOOTLOADER_IMAGE`: used to specify the name of the bootloader binary, from the resin-boot partition, that is to be written to `BOOTLOADER_FLASH_DEVICE`.

  - `BOOTLOADER_BLOCK_SIZE_OFFSET`: used to specify the block size with which `BOOTLOADER_IMAGE` is to be written to `BOOTLOADER_FLASH_DEVICE`.

  - `BOOTLOADER_SKIP_OUTPUT_BLOCKS`: used to specify how many blocks of size `BOOTLOADER_BLOCK_SIZE_OFFSET` need to be skipped from `BOOTLOADER_FLASH_DEVICE` when writing `BOOTLOADER_IMAGE` to it.

    Note: Some hardware requires the use of a MLO (a.k.a. SPL - secondary program loader) that is to be copied in static RAM and executed from there (static RAM is small in size) and this first stage bootloader is responsible for initializing the regular RAM and then copying the regular bootloader to this regular RAM and passing execution to it.
    For this purpose a second set of variables called BOOTLOADER_FLASH_DEVICE_1, BOOTLOADER_IMAGE_1, BOOTLOADER_BLOCK_SIZE_OFFSET_1 and BOOTLOADER_SKIP_OUTPUT_BLOCKS_1 can be used to accomodate this use case.

    For example, setting

    ```sh    BOOTLOADER_FLASH_DEVICE = "mtdblock0"    ```
    ```sh    BOOTLOADER_IMAGE = "u-boot.imx"    ```
    ```sh    BOOTLOADER_BLOCK_SIZE_OFFSET = "1024"    ```
    and
    ```sh    BOOTLOADER_SKIP_OUTPUT_BLOCKS = "3"    ```

    will result that the file u-boot.imx from the resin-boot partition is written to /dev/mtdblock0 with a block size of 1024 bytes and after the first 3 * 1024 bytes of /dev/mtdblock0.

***

and the optional ones are:

### `recipes-containers/docker-disk` directory

Which contains `docker-resin-supervisor-disk.bbappend` that can define the following variable(s):

***
- `LED_FILE_<yocto-machine-name>`: this variable should point to the [Linux sysfs path of an unused LED](https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-class-led) if available for that particular board. This allows the unused LED to be flashed for quick visual device identification purposes. If no such unused LED exists, this variable shall not be used.

***

The directory structure then looks similar to this:
```
├── conf
│   ├── layer.conf
│   └── samples
│       ├── bblayers.conf.sample
│       └── local.conf.sample
├── recipes-bsp
│   └── bootfiles
├── recipes-containers
│   └── docker-disk
│       └── docker-resin-supervisor-disk.bbappend
├── recipes-core
│   ├── images
│   │   └── resin-image.bbappend
├── recipes-kernel
│   └── linux
│       ├── linux-<board-family>-<version>
│       │   └── <patch files>
│       ├── linux-<board-family>_%.bbappend
│       └── linux-<board>_<version>.bbappend
└── recipes-support
    └── resin-init
        ├── files
        │   └── resin-init-board
        └── resin-init-board.bbappend
```

## Building

See the [meta-balena Readme](https://github.com/balena-os/meta-balena/blob/master/README.md) on how to build the new resinOS image after setting up the new board package as defined above.

## Troubleshooting

For specific examples on how board support is provided for existing devices, see the repositories below.

## Currently Supported Hardware Families

### ARM

* [Beaglebone](http://beagleboard.org/bone): [balena-beaglebone](https://github.com/balena-os/balena-beaglebone)
* [Raspberry Pi](https://raspberrypi.org): [balena-raspberrypi](https://github.com/balena-os/balena-raspberrypi)
* [Freescale/NXP](http://www.nxp.com/): [balena-fsl-arm](https://github.com/balena-os/balena-fsl-arm)
* [ODROID](http://www.hardkernel.com/main/main.php): [balena-odroid](https://github.com/balena-os/balena-odroid)
* [Parallella](https://www.parallella.org/): [balena-parallella](https://github.com/balena-os/balena-parallella)
* [Technologic Systems](https://www.embeddedarm.com/): [balena-ts](https://github.com/balena-os/balena-ts)
* [Toradex](https://www.toradex.com/): [balena-toradex](https://github.com/balena-os/balena-toradex)
* [VIA](http://www.viatech.com/en/): [balena-via-arm](https://github.com/balena-os/balena-via-arm)
* [Zynq](http://www.xilinx.com/products/silicon-devices/soc/zynq-7000.html): [balena-zc702](https://github.com/balena-os/balena-zc702)
* [Samsung Artik](https://www.artik.io/): [balena-artik](https://github.com/balena-os/balena-artik)

### x86

* [Intel Edison](http://www.intel.com/content/www/us/en/do-it-yourself/edison.html): [balena-edison](https://github.com/balena-os/balena-edison)
* [Intel NUC](http://www.intel.com/content/www/us/en/nuc/overview.html): [balena-intel](https://github.com/balena-os/balena-intel)

### Other

* [QEMU](http://wiki.qemu.org/Main_Page): [balena-qemu](https://github.com/balena-os/balena-qemu)

[balena-intel repo]: https://github.com/balena-os/balena-intel
[balena-intel grub append]: https://github.com/balena-os/balena-intel/tree/master/layers/meta-balena-genericx86/recipes-bsp/grub
[meta-intel repo]: http://git.yoctoproject.org/cgit/cgit.cgi/meta-intel
[intel-corei7-64 coffee]: https://github.com/balena-os/balena-intel/blob/master/intel-corei7-64.coffee
[balena-yocto-scripts]: https://github.com/balena-os/balena-yocto-scripts
[poky]: http://git.yoctoproject.org/cgit/cgit.cgi/poky
[meta-openembedded]: https://github.com/openembedded/meta-openembedded
[meta-balena]: https://github.com/balena-os/meta-balena
[meta-rust]: https://github.com/meta-rust/meta-rust
[layer.conf intel]: https://github.com/balena-os/balena-intel/blob/master/layers/meta-balena-genericx86/conf/layer.conf
[meta-balena-readme]: https://github.com/balena-os/meta-balena/blob/master/README.md
[local.conf.sample intel]: https://github.com/balena-os/balena-intel/blob/master/layers/meta-balena-genericx86/conf/samples/local.conf.sample
[bblayers.conf.sample intel]: https://github.com/balena-os/balena-intel/blob/master/layers/meta-balena-genericx86/conf/samples/bblayers.conf.sample

## FAQ

### Kernel complains that CONFIG_AUFS was not activated

The versions before v2.0-beta.3 didn't support kernel sources that were not git repositories. Starting with this version aufs patches will get applied on kernel recipes which use tar achives for example as well. For the older version this is considered a limitation.
