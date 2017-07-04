Change log
-----------

# v2.0.8 - 2017-07-04

* Resin-vars: Fetch all the vars in resin-vars [Pagan Gazzard]
* Add comment in supervisor.conf for clarity [Petros Angelatos]
* Prevent supervisor from killing itself [Pablo Carranza Velez]
* Store both image and tag in the temporary supervisor.conf [Pablo Carranza Velez]
* Use current changelog format with versionist [Andrei Gherzan]
* Update supervisor to v5.1.0 and use aarch64-supervisor for aarch64 [Pablo Carranza Velez]
* Validate docker config from disk to avoid panicing [Petros Angelatos]
* Versionist: add support for full versionist use [Gergely Imreh]

# v2.0.7 - 2017-06-28

* Add support for transparent proxy redirection using redsocks [Pablo]
* Add prerequisites for ipk packages in resinOS images [Andrei]
* Update supervisor to v5.0.0 [Pablo]
* Allow downloading a missing supervisor [Will]
* Add busybox patch to fix tar unpacking [Will]
* Include support for the RT5572 wireless chipset [Theodor]
* Add a quirk for /etc/mtab [Will]
* Switch to resin.io ntp pool [petrosagg]
* Undefine backwards compatibilty variable, INITRAMFS_TASK [Theodor]
* Enable CONFIG_KEYS, docker 17 requirment [Theodor]
* Update NetworkManager to 1.8.0 [Andrei]
* Update supervisor to v4.3.1 [Andrei]
* Set NetworkManager connection attempts to infinity [petrosagg]
* Update Docker to 17.03.1 [Theodor]
* Include fsck.vfat in resinOS [Andrei]

# v2.0.6 - 2017-06-06

* Update supervisor to v4.2.4 [Pablo]

# v2.0.5 - 2017-06-02

* Fix dependencies for mount service in /var/lib [Andrei]
* Various build fixes when using other package formats like ipk [Andrei]
* Define IMAGE_NAME_SUFFIX, needed for resinhup, for Yocto versions older than Morty [Florin]
* Add support for modifying the regulatory domain for wifi interfaces [Michal]
* Add support for qmi and mbim cell modems [Joshua]
* Disable all password logins on production images, rather than just root logins - this gets rid of the password prompt dialog that users have seen. [Page]

# v2.0.4 - 2017-05-16

* Enable the resin-uboot implementation to also boot flasher images from USB media [Florin]
* Use supervisor tag as supervisor recipe PV [Andrei}

# v2.0.3 - 2017-05-10

* Copy resinOS_uEnv.txt from external to internal media [Theodor]
* Fix resin-state-conf copying mechanism [Theodor]
* Don't fingerprint config.json [Andrei]
* Prevent resin-unique-key from running concurrently [Michal]
* Add iwlwifi 8265 firmware [Florin]
* Disable coredumps [Jon]
* Add bind mounts for systemd persistent data [Jon]
* Update supervisor to v4.2.2 [Page]
* Explicitly set CONFIG_HIDRAW=y [Michal]
* Fix symlink creation in resinhup_backwards_compatible_link() [Michal]

# v2.0.2 - 2017-04-24

* Fix build of kernel-modules-headers on kernel 4.8+ [Andrei]
* Use ondemand as default governor [Andrei]
* Do not force fsck on the data partition [Theodor]
* Switch to the new device register endpoint which exchanges the provisioning key for a device api key [Page]
* Switch to using a device api key for api calls and vpn authentication if it is present [Page]

# v2.0.1 - 2017-04-19

* Don't use getty generator even for development images [Andrei]
* Fix resinos-img image compression [Theodor]
* Revert 05288ce19781f9ab3b8c528f49537516b58db050 [Theodor]
* Update NetworkManager to version 1.6.2 [Florin]
* Update supervisor to v4.1.2 [Pablo]
* Add aufs hashes for more kernel versions [fboudra]
* Calculate IMAGE_ROOTFS_MAXSIZE dynamically [fboudra]
* Don't attempt UPX compression on aarch64 [fboudra]
* Tidy arch detection in kernel-modules-headers [fboudra]

# v2.0.0 - 2017-03-31

# v2.0.0-rc6 - 2017-03-31

* Update supervisor to v4.1.1 [Pablo]
* Replace echo with info in the resindataexpander initramfs script [Florin]
* Don't stop plymouth at boot [Andrei]

# v2.0.0-rc5 - 2017-03-24

* Fix busybox switch_root when console=null [Andrei]
* Make the initrams framework also parse root=LABEL= params [Florin]
* Fix audit disable dependencies [Theodor]
* Properly implement the ro_rootfs script [Theodor]
* Make rootfs identical to resinhup packages [Andrei]

# v2.0.0-rc4 - 2017-03-17

* Enable by-partuuid symlinks for our DOS partition scheme also for Poky Jethro and Poky Krogoth based boards [Florin]
* Ship with e2fsprogs-tune2fs [Michal]

# v2.0.0-rc3 - 2017-03-14

* Fix flasher detection in initramfs scripts [Andrei]
* Fix initramfs-framework build on morty [Andrei]

# v2.0.0-rc2 - 2017-03-14

* Fix initramfs-framework for non-morty boards [Theodor]
* Fix flasher when it might corrupt the internal device [Andrei]

# v2.0.0-rc1 - 2017-03-10

* Use stateless flasher partitions [Andrei]
* Refactor persistent logging [Theodor]
* Add support for RDT promote [Andrei]
* Fix image flag files on non uboot boards [Andrei]
* Update supervisor to v4.0.0 [Pablo]
* Change "test -z" with "test -n" in the U-Boot MMC scanning procedure [Florin]
* Implement MMC scanning for U-Boot [Andrei]
* Resin-info should not be present in our production images [Theodor]
* Implement resin-uboot based on v2.0 specification [Andrei]

# v2.0.0-beta13 - 2017-02-27

* Fix a compile error on krogoth boards [Andrei]

# v2.0.0-beta12 - 2017-02-27

* Disable audit subsystem [Theodor]
* Run openvpn on flasher too [Andrei]
* Add VARIANT/VARIANT_ID in os-release [Andrei]
* Modify partitions label, define entire resinOS space used to 700MiB and other minor changes [Andrei]
* Update supervisor to v3.0.1 [Pablo]
* Configure an armv7ve repository for the Resin Supervisor [Michal]
* Fix the location where to create the resinhup bundles when using poky morty [Florin]
* Introduce debug tools package group add mkfs.ext4 in resin-image [Andrei]
* Halve the UUID length to 16 bytes [Michal]

# v2.0.0-beta11 - 2017-02-15

* Fix sectors per track for targets smaller than 512 MB [Andrei]

# v2.0.0-beta10 - 2017-02-13

* Introduce new host OS versioning scheme [Andrei]
* Add jethro support [Andrei]
* Fix missing quotes when testing for IMGDEPLOYDIR [Florin]

# v2.0-beta.9 - 2017-02-07

* Use static resolv.conf [Andrei]
* Switch rootfs to ext4 [Andrei]
* Adapt resinhup for poky morty migration [Florin]
* Add support for multiple entries in INTERNAL_DEVICE_KERNEL [Andrei]
* Fix bug with the .docker mountpoint [Theodor]
* Remove the supervisor container in the update script [Pablo]
* Do not remove the supervisor container in every start [Pablo]
* Update supervisor to v3.0.0 [Pablo]

# v2.0-beta.8 - 2017-01-27

* Add xt_set kernel module for all of our devices [Theodor]
* Make /home/root/.docker writable [Theodor]
* Prevent docker from thrashing the page cache using posix_fadvise [petrosagg]
* Introduce meta-resin-morty for using meta-resin with poky morty [Florin]
* Add resinhup machine independent support in U-Boot [Andrei]
* Remove BTRFS support from the kernel [Michal]
* Backport dropbear atomic hostkey generation patch [Florin]
* Update supervisor to v2.9.0 [Pablo]
* Rewrite prepare-openvpn (style) and make it fail on error [Michal]
* Ensure prepare-openvpn.service starts after var-volatile.mount [Michal]

# v2.0-beta.7 - 2016-12-05

* Fix supervisor.conf's SUPERVISOR_TAG variable [Florin]

# v2.0-beta.6 - 2016-12-05

* Deactivate CONFIG_WATCHDOG_NOWAYOUT to make sure we can shutdown [Andrei]

# v2.0-beta.5 - 2016-11-30

* Add inode tuning (1 inode for 8192 bytes ) in mkfs.ext4 for the resin-data partition [Praneeth]
* Fix missing [Manager] section for systemd watchdog setting [Florin]
* Add missing dependency for the resin-supervisor.service [Theodor]
* Specify the supervisor tag with a local variable [Theodor]
* Update supervisor to v2.8.3 [Pablo]
* Activate kernel configs for supporting iptables REJECT, MASQUERADE targets [Florin]
* systemd: enable watchdog at 10 seconds [Florin]
* Allow resin-init-flasher to also flash both MLO and regular u-boot at the same time [Florin]
* Fix page size detection in go for arm64 boards [Andrei]

# v2.0-beta.4 - 2016-11-09

* Update supervisor to v2.8.2 [Pablo]

# v2.0-beta.3 - 2016-11-04

* Generate SUPERVISOR_REPOSITORY dynamically so no need to define it in `resin-<board>` anymore [Andrei]
* Fix container name conflict when creating a docker container [petrosagg]
* Don't compress docker binary anymore with UPX [Andrei]
* Fix /var/lib/docker corruption after power cut [petrosagg]
* Truncate hostname to 7 characters [Michal]
* Fix aufs patching on non git kernel sources [Andrei]
* Update supervisor to v2.8.1 [Pablo]

# v2.0-beta.2 - 2016-10-25

* Update supervisor to v2.7.1 [Pablo]
* Move supervisor.conf from /etc to /etc/resin-supervisor [Theodor]
* Update supervisor to v2.7.0 [Pablo]
* Add guide for new board adoption [Florin]
* Update supervisor to v2.6.2 [Pablo]

# v2.0-beta.1 - 2016-10-11

* Configure kernel with CONFIG_SECCOMP [Andrei]
* Update kernel-module-headers to v0.0.7 [Lorenzo]
* Implement persistent logging functionality [Andrei]
* Increase the root filesystem size to 300M [Andrei]
* Bump supervisor to 2.5.2 [Andrei]
* Added a warning when skipping pulling the supervisor [Page]
* Achieve read-only root filesystem [Theodor]
* Implement aufs fetch and unpack functionality in kernel-resin.bbclass [Florin]
* Use aufs as docker storage driver with ext4 as backing filesystem instead of btrfs [Florin]
* Replace connman with NetworkManager [Michal]
* Generate config.json from the build system [Theodor]
* Add usb-modeswitch [Michal]
* Allow hostname to be defined through config.json [Theodor]
* Expose docker socket over TCP on development images [Andrei]
* Integrate and configure avahi [Andrei]
* Start using gzip archives for kernel module headers [Andrei]
* Replace DEBUG_IMAGE with DEVELOPMENT_IMAGE [Theodor]
* Update supervisor to v2.5.0 [Pablo]

# v1.16 - 2016-09-27

* Update supervisor to v2.3.0 [Pablo]

# v1.15 - 2016-09-24

* Update supervisor to v2.2.1 [petrosagg]

# v1.14 - 2016-09-23

* Update supervisor to v2.2.0 [Kostas]

# v1.13 - 2016-09-23

# v1.12 - 2016-09-21

* Update supervisor to v2.1.1 [Pablo]
* Add device-type.json file to the boot partitions of our images [Florin]
* Enable kernel modules ip6table_nat, nf_nat_ipv6 and subset of ip_set [Florin]
* Change openvpn to use config file from /run [Florin]
* Change partition type of resin-conf from vfat to ext4 [Theodor]
* Move config.json to resin-boot partition [Theodor]
* Change resin-boot mount point from /boot to /mnt/boot [Theodor]
* Make dropbear host key generation atomic [Michal]
* Change the TUN device used by OpenVPN to resin-vpn to minimize conflict with user applications using tun0 [Praneeth]
* Update supervisor to v2.1.0 [Pablo]
* Use FHS structure in the root of resinhup packages [Andrei]

# v1.11 - 2016-08-31

* Backport STOPSIGNAL fix for docker [petrosagg]
* Make Docker log to journald [Michal]

# v1.10 - 2016-08-24

# v1.9 - 2016-08-24

* Provide custom splash logo for our flasher type [Theodor]
* Update supervisor to v1.14.0 [Pablo]
* Set the default supervisor tag in /etc/supervisor.conf to the bundled supervisor tag. [Page]
* Update firmware: iwlwifi-7265D-10 -> iwlwifi-7265D-13 [Michal]

# v1.8 - 2016-08-02

* Fix plymouth output to tty1 [Theodor]
* Use FAT16 filesystems as we do for partitions [Andrei]
* Fix boltdb alignment issue for armv5 in docker, fixes docker 1.10.3 on armv5 devices [Lorenzo]
* Include firmware for iwlwifi-8000C-13 - 6th generation Intel NUC [Andrei]
* Disable DHCP server functionality from dnsmasq [Florin]
* Update supervisor to v1.13.0 [Andrei]
* Start dropbearkey.service at boot and don't wait for first connection [Andrei]
* Both remove systemd-serialgetty symlinks and disable systemd-getty-generator for non-debug builds [Florin]
* Disable ntp from connman and rely only on systemd-timesyncd with selected timeservers [Florin]

# v1.7 - 2016-07-14

* Various meta-resin layer tweaks [Andrei]
* Add support for resinhup when running kernel modules operations [Andrei]
* Update supervisor to 1.12.1 [Pablo]

# v1.6 - 2016-07-06

# v1.5 - 2016-07-04

* Update resin supervisor to v1.11.6 [Florin]
* Refactor openvpn dependencies [Florin]

# v1.4 - 2016-06-27

* Replace STAGING_BUILD by DEBUG_IMAGE and various refactorings [Andrei]
* Update to latest kernel-modules-headers [Florin]

# v1.3 - 2016-06-24

* Implement mechanism for compressed kernel modules [Andrei]
* Fix connman multiple IP over DHCP [Andrei]
* Have the ability to inject custom docker images for connectable builds [Andrei]
* Integrate resin-provisioner [Andrei]
* Include slug and machine in os-release [Andrei]
* Define and implement resin connectable builds [Andrei]
* Split the registration and uuid generation, of a device, into separate packages [Theodor]
* Sanitize target arch for x86 machines [Florin]
* Ensure kernel build artefacts are present for kernel-modules-headers [Florin]
* Add "set -e" to resin-init-flasher [Florin]
* Add recipe for deploying an archive with kernel modules headers [Florin]
* Have the ability at build time to configure the preloaded docker image in the BTRFS partition [Andrei]

# v1.2 - 2016-06-08

* Remove board specific bootloader handling from the flasher [Florin]
* Provide script to inject board specific flashing procedures [Theodor]
* Implement and document host OS new versioning scheme [Andrei]
* Set PreferredTechnologies to "wifi,ethernet" [Florin]
* Do not add nameserver routes in the kernel IP routing table [Florin]
* Add support for migration to docker engine 1.10 in resinhup [Andrei]
* Move resin-image sdcard file in the rootfs instead of the boot partition [Florin]
* Add compression mechanism for binaries, using upx [Theodor]
* Switch to docker 1.10.3 [Theodor]
* Remove deprecated mmcroot from flasher init script [Andrei]
* Deploy license.manifest [Andrei]

# v1.1.4 - 2016-04-20

* Add build information in the target rootfs [Florin]
* Don't bind mount /etc/resolv.conf anymore [Florin]
* Have dnsmasq listen on 127.0.0.2 instead of 127.0.0.1 [Florin]

# v1.1.3 - 2016-04-13

* Add resin-init-board as a runtime dependency to resin-init-flasher [Florin]

# v1.1.2 - 2016-04-13

* Execute resin-init-board from the flasher also [Florin]
* Use realpath from coreutils-native for generating SD images [Andrei]
* Add rsync to our image [Theodor]
* Add p2p to NetworkInterfaceBlacklist in connman main.conf file [Florin]
* Add dnsmasq and do changes to connman so dnsmasq is used according to our platform needs [Florin]
* Define "rce" as a provider for the "docker" package [Florin]

# v1.1.1 - 2016-03-03

* Make resin-supervisor-disk's PV variable not contain the ':' character [Florin]
* Workaround for "docker images" behavior - https://bugzilla.redhat.com/show_bug.cgi?id=1312934 [Florin]
* Have device registration provided by supervisor in resin-image and resin-device-register in resin-image-flasher [Andrei]
* Include crda in resin images [Andrei]
* Add support for hid-multitouch - available as kernel module [Andrei]
* Simplify os-release version and add some resin specific info [Andrei]
* Set IMAGE_ROOTFS_SIZE to zero as default [Florin]
* Update layer with the ability to use jethro [Theodor]

# v1.1.0 - 2016-02-16

* Migrate repositories to github [Florin]
* Add resinhup package for running hostOS updates [Andrei]
* Export deltaEndpoint as DELTA_ENDPOINT [Andrei]

# v1.0.6 - 2016-02-03

* Upgrade systemd to version 216 and add volatile-binds dependency [Florin]
* Fix racing issue on edison [Andrei]
* Add support ts7700 [Theodor]
* Remove obsolete pseudo patch. This patch is now in poky [Florin]
* Remove obsolete bash patches. These patches are now in poky [Florin]
* Ensure connman systemd service is enabled on boot [Florin]
* Change OOM Adjust Score of RCE to -900 [Praneeth]
* Change OOM Adjust Score of Connman to -1000 [Praneeth]
* Change OOM Adjust Score of OpenVPN to -1000 [Praneeth]

# v1.0.5 - 2016-01-20

# v1.0.4

* Add mechanism for user loading custom splash logo. [Theodor]
* Add splash screen for all our images. [Theodor]
* Make connman an optional network manager [Andrei]
* Always restart openvpn service [Andrei]
* Include distribution information file in rootfs [Andrei]
* Mechanism for generating resinhup-tar packages. [Andrei]
* Implement fingerprints for resin-boot and resin-root [Andrei]
* Explicitly configure kernel with config.gz built in support [Andrei]

# v1.0.3 - 2016-01-05

* Removed the global bblayers.conf.sample and local.conf.sample [Jon]
* Removed the append from the BBMASK declaration in meta-resin-toradex layer.conf [Jon]
* Fix ${S} and ${DEPLOY_DIR_IMAGE} variables for zc702-zynq7 [Jon]
* Make resin-supervisor.service restartable on failures [Jon]
* Fix supervisor preloading [Andrei]

# 2015-10-29 - apalis-imx6 colibri-imx6

* Added apalis-imx6 and colibri-imx6 support [Theodor]

# 2015-09

* Add firmware for Intel Wireless 7265 chipsets [Jon]
* Added support for specifying the supervisor tag to include. [Page]
* Changed flasher to shutdown instead of reboot [Jon]

# 2015-11-02

* Fix DNS issues with openvpn [Andrei]
* Add support for booting from internal device on vab820-quad [Jon]

# 2015-10-28 - beaglebone cubox-i edison nitrogen6x nuc odroid-c1 odroid-ux3 parallella-hdmi-resin raspberrypi raspberrypi2 ts4900 vab820-quad zc702-zynq7

* Update the supervisor.conf supervisor image when updating the supervisor so that switching image/registry can work. [Page]
* Use armv7hf-supervisor for rpi2 [Page]
* Change update-resin-supervisor.timer to run every 24 hours instead of 5 mins [Praneeth]
* Remove any service that might start getty on the production images [Theodor]
* Move to common code the resin-sdcard addition for flasher boards [Jon]
* Fixed supervisor update not running new image due to invalid comment. [Andrei]
* Change git repo used for VIA arm boards [Jon]
* Removed resolved. [Jon]

# 2015-10-08 - beaglebone cubox-i edison nitrogen6x nuc odroid-c1 odroid-ux3 parallella-hdmi-resin raspberrypi raspberrypi2 vab820-quad zc702-zynq7
# 2015-09-29 - ts4900

* Fix supervisor update missing dependencies [Andrei]
* Added ts4900 support [Andrei]

# 2015-09-13

* Add support for C1+ and XU4 ODROID boards [Andrei]
* Remove device registration in resin-image [Andrei]
* Add support for r8188eu [Andrei]
* Add support for Ralink RT5370 [Jon]
* Make openvpn report connected status by creating a file [Praneeth]
* Add support for ZC702 boards [Andrei]
* config.json doesn't change anymore on flasher images [Andrei]
* Add support for VIA VAB820 boards [Jon]
* Fetch resin instance variables from config.json (eg API endpoint) [Theodor]
* We don't load 1-wire driver at boot anymore [Andrei]
* WiFi can now be configured from config.json - at every boot connman configuration will be redone based on config.json [Andrei]
* Bring in support for capemgr on beaglebone black [Andrei]
* Add firmware files for iwlwifi wireless chipsets [Jon]
* Removed unused package management features [Andrei]
* Add support for multiple yocto versions [Andrei]

# 2015-07-26

* Add Intel NUC support - tested on model D34010WYKH [Jon]
* Switched supervisor caching to be package.json version + docker image id. [Page]
* Increased supervisor update poll interval to once per day (and on reboot)
* meta-resin switched to systemd now instead of sysvinit [Theodor]
* Edison unification. [Theodor]
* Moved parallella bitstreams and DTS into the image. [Theodor]
* Added support for edison phone flash tool. [Praneeth]
* Forcefully remove supervisor container to avoid some issues where a normal remove won't work even though the container is stopped [Page]
* Fixed fat config partition not mounting on mac. [Theodor]
* Cache supervisor based upon package.json version. [Theodor]
* Updated edison BSP. [Praneeth]
* Added hummingboard support. [Andrei]
* Some device registration fixes. [Page]
* Switched to fido. [Theodor]
* Beaglebone refactor. [Andrei]

# 2015-05-20

* Stop spawning getty in production builds [Theodor]
* Add iozone to staging build [Theodor]
* Add support for unprotected WiFi Tethering with Connman [Praneeth]
* Add support for Adafruit Touch Screen - Switches to using adafruits fork of fbtft [Praneeth]
* Add support for Parallella [Theodor]

# 2015-05-07

* Fix beaglebone connman not starting [Praneeth]

# 2015-05-05

* Fix the DNS bug occurring because of docker/rce copying resolv.conf before network connectivity. [Praneeth]
* Change Staging API url to api.staging.resin.io from staging.resin.io [Praneeth]

# 2015-04-27

* Fix resin-net-config to honour network.config and ethernet.config as per the changes in resin-image-maker. [Praneeth]
* Add tun to NetworkInterfaceBlacklist of connman. [Praneeth]
* Add --nodnsproxy to connmand startup in both systemd services and init scripts, This disables the internal dns proxy of connman. [Praneeth]
* Wait for docker to terminate before calling unmount in resin-supervisor-disk [Praneeth]

# 2015-04-19

* Allowed concurrent building on the resin-supervisor recipe.
* Fixed first boot connectivity.
* Added a script to balance the btrfs partition on boot and every 24 hours at midnight
