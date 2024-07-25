# Customer Board Support

There are several ways for enabling balenaOS support for your hardware:

1. Checking out if balenaOS doesn't already provide support for your board through our [supported devices list](https://docs.balena.io/reference/hardware/devices/).
2. Consider our [Custom Device Support (CDS) service](https://cds.balena.io/). This is a paid service where we create a custom balenaOS build for you and maintain it for a monthly fee.
3. Building and maintaining balenaOS yourselves using our Customer Board Support (CBS) documentation. This will require knowledge of the Yocto project and familiarity with tools used to build custom images. Follow along the documentation for CBS below:

## Pre-requisites

A [Yocto](https://www.yoctoproject.org) Board Support Package (BSP) layer for your particular board. It should be compatible with the Yocto releases balenaOS supports.

The repositories used to build the balenaOS host Operating System (OS) are typically called balena-`<board-family>`. For example, consider [balena-raspberrypi](https://github.com/balena-os/balena-raspberrypi) which is used for building the OS for [Raspberryi Pi](https://raspberrypi.org), or [balena-intel][balena-intel repo] repository which can be used to build a balenaOS image for the Intel NUC boards.

Contributing support for a new board is a process that involves the following steps:

- [Create the board support repository](#step-1-board-support-repository-breakout)
- [Contact balena to have the repository transferred/cloned and the build system jobs created](#step-2-contact-balena)
- [Send a Pull Request for a hardware contract which describes the board's capabilities](#step-3-hardware-contract)
- [Maintaining the repository and OS updates](#step-4-maintaining-the-repository-and-os-updates)

## Step 1: Board Support Repository Breakout

The following documentation walks you through creating such a Yocto package. Because of the substantial difference between the hardware of many boards, this document provides general directions,
and often it might be helpful to see the examples of already supported boards. The list of the relevant repositories is found at the end of this document.

There is a [sample repo](https://github.com/balena-os/balena-board-template) which we encourage you use as a starting base for your repository.

The balena-`<board-family>` repositories use [git submodules](https://git-scm.com/docs/git-submodule) for including required Yocto layers from the relevant sub-projects.
_Note: you add submodules by `git submodule add <url> <directory>`, see the git documentation for more details. The submodules have to be added using the https protocol._

The root directory structure contains the following directories:

```
├──.github
├──.versionbot
├── balena-yocto-scripts
└── layers
```

and files:

```
├── .gitignore
├── .gitmodules
├── CHANGELOG.md
├── LICENSE
├── README.md
├── VERSION
├── repo.yml
├── <board-name-1>.coffee
├── <board-name-2>.coffee
...
└── <board-name-x>.coffee
```

For versioning checks to pass, it is mandatory that the root directory structure reflects the given example and for each commit message body to adhere to the Yocto Contribution Guidelines. Please refer to the device repository [Pull Requests example](https://github.com/balena-os/balena-raspberrypi#pull-requests) for valid commit log formats.

### About coffee file(s)

One or more files named `<board-name>.coffee`, where `<board-name>` is the corresponding yocto machine name. Should add one for each of the boards that the repository adds support for (eg. [raspberrypi3.coffee](https://github.com/balena-os/balena-raspberrypi/blob/master/raspberrypi3.coffee) or [rockpi-4b-rk3399.coffee](https://github.com/balena-os/balena-rockpi/blob/master/rockpi-4b-rk3399.coffee)). This file contains information on the Yocto build for the specific board, in [CoffeeScript](http://coffeescript.org/) format.

### Layers directory breakout

The typical layout for the `layers` directory is:

```
├── layers
│   ├── meta-balena
│   ├── meta-balena-<board-family>
│   ├── meta-<vendor>
│   ├── meta-openembedded
│   ├── meta-rust
│   └── poky
```

The `layers` directory contains the git submodules of the yocto layers used in the build process. The BSP git submodule(s) used should be publicly available repositories.
All git submodules need to be cloned using the https protocol. This normally means the following components are present:

- [meta-balena][meta-balena] using the master branch
- meta-\<vendor\> : the Yocto BSP layer for the board (for example, the BSP layer for Raspberry Pi is [meta-raspberrypi](https://github.com/agherzan/meta-raspberrypi))
- [meta-openembedded][meta-openembedded] at the branch equivalent to the poky version
- [meta-rust][meta-rust] at the revision poky uses
- [poky][poky] at the version/revision required by the board BSP (this fork must be used to not be rate-limited by the yocto project git when doing lots of builds)
- any additional Yocto layers required by the board BSP (check the Yocto BSP layer of the respective board for instructions on how to build the BSP and what are the Yocto dependencies of that particular BSP layer). These should be public repo(s).

In addition to the above git submodules, the `layers` directory requires a meta-balena-`<board-family>` directory (please note this directory is _not_ a git submodule). This directory contains the required customization for making a board balena.io enabled. For example, the [balena-raspberrypi](https://github.com/balena-os/balena-raspberrypi) repository contains the directory `layers/meta-balena-raspberrypi` to supplement the BSP from `layers/meta-raspberrypi` git submodule, with any changes that might be required by balenaOS.

### meta-balena-`<board-family>` breakout

We call this directory the balena integration directory. It is a Yocto layer that includes:

- balenaOS-specific software features,
- deployment-specific features (i.e., settings to create SD card, USB thumb drive, or self-flashing images)

This directory contains optional and mandatory directories:

|                         Mandatory                         |       Optional (as needed)       |
| :-------------------------------------------------------: | :------------------------------: |
|                          `conf`                           | `recipes-containers/docker-disk` |
| `recipes-bsp/<bootloader recipes dir used by your board>` |                                  |
|                   `recipes-core/images`                   |                                  |
|             `recipes-kernel/linux directory`              |                                  |
|                     `recipes-support`                     |                                  |

### `conf` directory - contains the following files:

1. `layer.conf`, see the [layer.conf](https://github.com/balena-os/balena-raspberrypi/blob/master/layers/meta-balena-raspberrypi/conf/layer.conf) from `meta-balena-raspberrypi` for an example, and see [Yocto documentation](http://www.yoctoproject.org/docs/2.0/mega-manual/mega-manual.html#bsp-filelayout-layer)
2. `samples/bblayers.conf.sample` file in which all the required Yocto layers are listed, see this [bblayers.conf.sample](https://github.com/balena-os/balena-raspberrypi/blob/master/layers/meta-balena-raspberrypi/conf/samples/bblayers.conf.sample), and see the [Yocto documentation](http://www.yoctoproject.org/docs/2.0/mega-manual/mega-manual.html#var-BBLAYERS)
3. `samples/local.conf.sample` file which defines part of the build configuration (see the meta-balena [README.md][meta-balena-readme] for an overview of some of the variables use in the `local.conf.sample` file). You can use as guide an existing sample (e.g. [local.conf.sample](https://github.com/balena-os/balena-rockpi/blob/master/layers/meta-balena-rockpi/conf/samples/local.conf.sample)) but making sure the "Supported machines" area lists the appropriate machines this repository is used for. See also the [Yocto documentation](http://www.yoctoproject.org/docs/2.0/mega-manual/mega-manual.html#structure-build-conf-local.conf).

### `recipes-bsp`

This directory should contain the changes to the bootloader recipes used by your board. For example, for u-boot based boards, it must define the [following](https://github.com/balena-os/balena-rockpi/blob/master/layers/meta-balena-rockpi/recipes-bsp/u-boot/u-boot-rockpi-4.bbappend#L3-L5), and it must include at least a patch to the u-boot bootcmd that changes the default boot command to include balena required setup. See this [example](https://github.com/balena-os/balena-rockpi/blob/master/layers/meta-balena-rockpi/recipes-bsp/u-boot/files/0001-Integrate-with-Balena-u-boot-environment.patch), or if you use a newer u-boot you can simply use config fragments to alter the bootcmd like done [here](https://github.com/balena-os/balena-nanopi-r2c/blob/master/layers/meta-balena-nanopi-r2c/recipes-bsp/u-boot/files/balenaos_bootcommand.cfg).

### `recipes-core/images` directory

This directory contains at least a `balena-image.bbappend` file. Depending on the type of board you are adding support for, you should have your device support either just `balena-image` or both `balena-image-flasher` and `balena-image`. Generally, `balena-image` is for boards that run directly from external storage (these boards do not have internal storage to install balenaOS on). `balena-image-flasher` is used when the targeted board has internal storage, so this flasher image is burned onto an SD card or USB stick that is used for the initial boot. When booted, this flasher image will automatically install balenaOS on internal storage.

The `balena-image.bbappend` file shall define the following variable(s):

- `BALENA_BOOT_PARTITION_FILES_<yocto-machine-name>`: this allows adding files from the build's deploy directory into the vfat formatted resin-boot partition (can be used to add bootloader config files, first stage bootloader, initramfs or anything else needed for the booting process to take place for your particular board). If the board uses different bootloader configuration files when booting from either external media (USB thumb drive, SD card, etc.) or from internal media (mSATA, eMMC etc.) then you would want to make use of this variable to make sure the different bootloader configuration files get copied over and further manipulated as needed (see `INTERNAL_DEVICE_BOOTLOADER_CONFIG_<yocto-machine-name>` and `INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH_<yocto-machine-name>` below). Please note that you only reference these files here. It is the responsibility of a `.bb` or `.bbappend` to provide and deploy them (for bootloader config files, this is done with an append typically in `recipes-bsp/<your board's bootloader>/<your board's bootloader>.bbappend`, see [balena-intel grub bbappend][balena-intel grub append] for an example).

It is a space separated list of items with the following format: _FilenameRelativeToDeployDir:FilenameOnTheTarget_. If _FilenameOnTheTarget_ is omitted then the _FilenameRelativeToDeployDir_ will be used.

For example, to have the Intel NUC `bzImage-intel-corei7-64.bin` copied from the deploy directory over to the boot partition, renamed to `vmlinuz`:

    BALENA_BOOT_PARTITION_FILES_nuc = "bzImage-intel-corei7-64.bin:vmlinuz"

The `balena-image-flasher.bbappend` file shall define the following variable(s):

- `BALENA_BOOT_PARTITION_FILES_<yocto-machine-name>` (see above). For example, if the board uses different bootloader configuration files for booting from SD/USB and internal storage (see below for the use of `INTERNAL_DEVICE_BOOTLOADER_CONFIG` variable), then make sure these files end up in the boot partition (i.e. they should be listed in this `BALENA_BOOT_PARTITION_FILES_<yocto-machine-name>` variable)

### `recipes-kernel/linux directory`

Shall contain a `.bbappend` to the kernel recipe used by the respective board. This kernel `.bbappend` must "inherit kernel-balena" in order to add the necessary kernel configs for balenaOS

### `recipes-support/resin-init` directory

Shall contain a `resin-init-flasher.bbappend` file if you intend to install balenaOS to internal storage and hence use the flasher image.

`resin-init-flasher.bbappend` should define the following variables:

- `INTERNAL_DEVICE_KERNEL_<yocto-machine-name>`: used to identify the internal storage where balenaOS will be written to.

- if required - `INTERNAL_DEVICE_BOOTLOADER_CONFIG_<yocto-machine-name>`: used to specify the filename of the bootloader configuration file used by your board when booting from internal media. Must be the same as the _FilenameOnTheTarget_ parameter of the bootloader internal config file used in the `BALENA_BOOT_PARTITION_FILES_<yocto-machine-name>` variable from `recipes-core/images/balena-image-flasher.bbappend`.

- if required - `INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH_<yocto-machine-name>`: used to specify the relative path, including filename, to the resin-boot partition where `INTERNAL_DEVICE_BOOTLOADER_CONFIG_<yocto-machine-name>` will be copied to.

  For example, setting.

  `INTERNAL_DEVICE_BOOTLOADER_CONFIG_intel-corei7-64 = "grub.cfg_internal"`
  and
  `INTERNAL_DEVICE_BOOTLOADER_CONFIG_PATH_intel-corei7-64 = "/EFI/BOOT/grub.cfg"`
  will result that after flashing the file `grub.cfg`\_internal is copied with the name `grub.cfg` to the /EFI/BOOT/ directory on the resin-boot partition.

- `BOOTLOADER_FLASH_DEVICE`: used to identify the internal storage which the bootloader needs to be flashed to. This is only the case usually when the bootloader needs to be in a SPI flash-like memory where the bootrom code expects it to read it from raw disk instead from a partition.
  Note that if `BOOTLOADER_FLASH_DEVICE` is set, then also `BOOTLOADER_IMAGE`, `BOOTLOADER_BLOCK_SIZE_OFFSET` and `BOOTLOADER_SKIP_OUTPUT_BLOCKS` need to be set.

- `BOOTLOADER_IMAGE`: used to specify the name of the bootloader binary, from the resin-boot partition, that is to be written to `BOOTLOADER_FLASH_DEVICE`.

- `BOOTLOADER_BLOCK_SIZE_OFFSET`: used to specify the block size with which `BOOTLOADER_IMAGE` is to be written to `BOOTLOADER_FLASH_DEVICE`.

- `BOOTLOADER_SKIP_OUTPUT_BLOCKS`: used to specify how many blocks of size `BOOTLOADER_BLOCK_SIZE_OFFSET` need to be skipped from `BOOTLOADER_FLASH_DEVICE` when writing `BOOTLOADER_IMAGE` to it.

  Note: Some hardware requires the use of a MLO (a.k.a. SPL - secondary program loader) that is to be copied in static RAM and executed from there (static RAM is small in size), and this first stage bootloader is responsible for initializing the regular RAM and then copying the regular bootloader to this regular RAM and passing execution to it.
  For this purpose, a second set of variables called BOOTLOADER_FLASH_DEVICE_1, BOOTLOADER_IMAGE_1, BOOTLOADER_BLOCK_SIZE_OFFSET_1, and BOOTLOADER_SKIP_OUTPUT_BLOCKS_1 can be used to accommodate this use case.

For example, setting:

    BOOTLOADER_FLASH_DEVICE = "mtdblock0"
    BOOTLOADER_IMAGE = "u-boot.imx"
    BOOTLOADER_BLOCK_SIZE_OFFSET = "1024"
    BOOTLOADER_SKIP_OUTPUT_BLOCKS = "3"

will result that the file `u-boot.imx` from the resin-boot partition is written to /dev/mtdblock0 with a block size of 1024 bytes and after the first 3 \* 1024 bytes of /dev/mtdblock0.

### `recipes-support/hostapp-update-hooks` directory

Shall contain a `hostapp-update-hooks.bbappend` with content based on if your board uses [u-boot](https://github.com/balena-os/balena-rockpi/blob/master/layers/meta-balena-rockpi/recipes-support/hostapp-update-hooks/hostapp-update-hooks.bbappend#L5) or [grub](https://github.com/balena-os/balena-intel/blob/master/layers/meta-balena-genericx86/recipes-support/hostapp-update-hooks/hostapp-update-hooks.bbappend#L4). Then it may also need to include an additional [hook](https://github.com/balena-os/balena-rockpi/blob/master/layers/meta-balena-rockpi/recipes-support/hostapp-update-hooks/files/99-flash-bootloader) for writing the bootloader(s) binary in the right place(s) when doing hostOS updates.

The optional directories in meta-balena-\<board-family\> are:

### `recipes-support/balena-info` directory

Should contain a `balena-info.bbappend` file which specifies the list of virtual consoles where the balena ascii art should be displayed. For example: `TTYS=tty1 ttymxc0` would display the ascii art on the framebuffer and UART consoles of an iMX board.

### `recipes-containers/docker-disk` directory

Which contains `balena-supervisor.bbappend` that can define the following variable(s):

- `LED_FILE_<yocto-machine-name>`: this variable should point to the [Linux sysfs path of an unused LED](https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-class-led) if available for that particular board. This allows the unused LED to be flashed for quick visual device identification purposes. If no such unused LED exists, this variable shall not be used.

The directory structure then looks similar to this:

```
├── conf
│   ├── layer.conf
│   └── samples
│       ├── bblayers.conf.sample
│       └── local.conf.sample
├── recipes-bsp
│   └── <bootloader recipes dir used by your board>
├── recipes-containers
│   └── docker-disk
│       └── balena-supervisor.bbappend
├── recipes-core
│   ├── images
│   │   └── balena-image.bbappend
├── recipes-kernel
│   └── linux
│       ├── linux-<board-family>-<version>
│       │   └── <patch files>
│       ├── linux-<board-family>_%.bbappend
│       └── linux-<board>_<version>.bbappend
└── recipes-support
    └── hostapp-update-hooks
        ├── files
        │   └── <bootloader update hook>
        └──  hostapp-update-hooks.bbappend
    └── resin-init
        └── resin-init-flasher.bbappend
```

### Building

See the [meta-balena Readme](https://github.com/balena-os/meta-balena/blob/master/README.md) on building the new balenaOS image after setting up the new board package as defined above.

## Step 2: Contact balena

When you have completed the development of the yocto board support repository as detailed in the previous step, please get in touch with balena to finish the process of having your board available in the balenaCloud dashboard.  
Your board repository needs to be hosted in the [balena-os GitHub organization](https://github.com/balena-os). The repository transfer needs to be made to a balena team member. To transfer, go to your yocto board GitHub repository and click the
`Settings` button on the top. On the `General` page scroll to the bottom, over to `Danger Zone` and click on `Transfer` then select `Specify an organization or username` and fill in the balena team member username that you agreed on with balena.
Depending on your needs and upon agreeing with balena, this new repository can be hosted either as a public repository for everyone to access or hosted privately with access provided to selected users.
For private repositories, you would also have to supply balena a list of GitHub usernames of contributors that need to be provided access to the future private repository. Balena will add them as outside collaborators.

The next step is automated testing support. In order to have automated OS deploys, you need to have your new hardware integrated with balena's automated testing rig. Contact balena for the details on how
to have your autokit setup moved to balena's testing fleet.

## Step 3: Hardware contract

Having a board supported by balena also means having a hardware contract describing that device type.  
balena allows for public or private device types. Public device types can be used by all users while private device types are only accessible to selected users upon agreeing with balena.
Note that public/private device type visibility mentioned here is independent of the GitHub repository visibility (you can choose to have any combination of these two).

For publicly available device types, the hardware contracts are located [here](https://github.com/balena-io/contracts/tree/master/contracts/hw.device-type)
and you must send a Pull Request to this public contract repository with the appropriate contract.
See [this](https://github.com/balena-io/contracts/pull/296) as an example to base on.

For private device types, balena will make the necessary changes when supplied with the hardware contract.

## Step 4: Setting up Hardware in the Loop Testing Pipeline

In order to have the balenaOS image deployed to balenaCloud, it must first pass the [balenaOS automated test suite](https://github.com/balena-os/meta-balena/tree/master/tests).
This involves the following steps:

1. Order [parts to build](https://github.com/balena-io-hardware/autokit-assembly-doc/blob/master/source/bom/bom.csv) the autokit test harness, [set it up](https://github.com/balena-io-hardware/autokit-assembly-doc/blob/master/README.md), and connect it to the board for which the the device support is being done for. With the autokit setup, you would be able to run the automated test suite and test your balenaOS image on the board.
2. Follow the [getting started guide](https://balena-os.github.io/leviathan/pages/Getting-Started/quickstart.html#quick-start-guides) to set up our test environment, firstly run the tests with a [virtual device](https://balena-os.github.io/leviathan/pages/Getting-Started/quickstart/quickstart-qemu.html) and then the [guide to running the tests with the autokit](https://balena-os.github.io/leviathan/pages/Getting-Started/quickstart/quickstart-autokit.html)
3. Once the autokit setup with your device under test is confirmed to be working locally, it must be incorporated into the BalenaOS CI/CD pipeline. This requires contacting the balena team, and provisioning the autokit setup into Balena's autokit fleet.  
4. After the autokit has been added to the BalenaOS CI/CD pipeline, the board support repository will have required tests run on your autokit setup for each pull request of the board support repository.
5. The board support repository being part of `balena-os` GitHub org means it would effectively receive automatic updates from meta-balena to keep BalenaOS updated. Each update PR will run the tests on the autokit, which will merge when the tests pass. On merge, the balenaOS release will then be automatically deployed to the balenaCloud production environment.

## Step 5: Maintaining the repository and OS updates

Once the board is supported in balena, it will receive automatic pull requests with updates of meta-balena as new releases of meta-balena get done.
It will also receive automatic pull request updates to other balena related sub modules. 
These automatic pull requests get merged if the CI builds succeed and automated tests pass.
As long as the autokit setup is still active, tests will be run on the test device, and pull requests tested.
Any merged PR with passing tests will result in a new release being deployed to production automatically.

Maintaining / pushing updates to the code other than meta-balena updates need to be done through pull requests in the appropriate board repository in the balena-os GitHub org and will be reviewed by balena prior to merging.


## Currently Supported Hardware Families

See the repositories below for specific examples on how board support is provided for existing devices.

### ARM

- [Beaglebone](http://beagleboard.org/bone): [balena-beaglebone](https://github.com/balena-os/balena-beaglebone)
- [Raspberry Pi](https://raspberrypi.org): [balena-raspberrypi](https://github.com/balena-os/balena-raspberrypi)
- [Freescale/NXP](http://www.nxp.com/): [balena-fsl-arm](https://github.com/balena-os/balena-fsl-arm)
- [ODROID](http://www.hardkernel.com/main/main.php): [balena-odroid](https://github.com/balena-os/balena-odroid)
- [Parallella](https://parallella.org/): [balena-parallella](https://github.com/balena-os/balena-parallella)
- [Technologic Systems](https://www.embeddedts.com/): [balena-ts](https://github.com/balena-os/balena-ts)
- [Toradex](https://www.toradex.com/): [balena-toradex](https://github.com/balena-os/balena-toradex)
- [VIA](http://www.viatech.com/en/): [balena-via-arm](https://github.com/balena-os/balena-via-arm)
- [Zynq](http://www.xilinx.com/products/silicon-devices/soc/zynq-7000.html): [balena-zc702](https://github.com/balena-os/balena-zc702)
- [Samsung Artik](https://www.artik.io/): [balena-artik](https://github.com/balena-os/balena-artik)

### x86

- [Intel Edison](http://www.intel.com/content/www/us/en/do-it-yourself/edison.html): [balena-edison](https://github.com/balena-os/balena-edison)
- [Intel NUC](http://www.intel.com/content/www/us/en/nuc/overview.html): [balena-intel](https://github.com/balena-os/balena-intel)

### Other

- [QEMU](http://wiki.qemu.org/Main_Page): [balena-qemu](https://github.com/balena-os/balena-qemu)

## Troubleshooting

### Kernel complains that CONFIG_AUFS was not activated

The versions before v2.0-beta.3 didn't support kernel sources that were not git repositories. Starting with this version, aufs patches will get applied on kernel recipes that use tar archives, for example as well. For the older version, this is considered a limitation.

[balena-intel repo]: https://github.com/balena-os/balena-intel
[balena-intel grub append]: https://github.com/balena-os/balena-intel/tree/master/layers/meta-balena-genericx86/recipes-bsp/grub
[meta-intel repo]: http://git.yoctoproject.org/cgit/cgit.cgi/meta-intel
[intel-corei7-64 coffee]: https://github.com/balena-os/balena-intel/blob/master/intel-corei7-64.coffee
[balena-yocto-scripts]: https://github.com/balena-os/balena-yocto-scripts
[poky]: https://github.com/balena-os/poky
[meta-openembedded]: https://github.com/openembedded/meta-openembedded
[meta-balena]: https://github.com/balena-os/meta-balena
[meta-rust]: https://github.com/meta-rust/meta-rust
[layer.conf intel]: https://github.com/balena-os/balena-intel/blob/master/layers/meta-balena-genericx86/conf/layer.conf
[meta-balena-readme]: https://github.com/balena-os/meta-balena/blob/master/README.md
[local.conf.sample intel]: https://github.com/balena-os/balena-intel/blob/master/layers/meta-balena-genericx86/conf/samples/local.conf.sample
[bblayers.conf.sample intel]: https://github.com/balena-os/balena-intel/blob/master/layers/meta-balena-genericx86/conf/samples/bblayers.conf.sample
