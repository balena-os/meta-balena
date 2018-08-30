Change log
-----------

# v2.15.1
## (2018-08-30)

* Disable PIE for go [Zubair Lutfullah Kakakhel]
* Disable PIE for balena [Zubair Lutfullah Kakakhel]

# v2.15.0
## (2018-08-28)

* Bump balena version to latest 17.12-resin [Zubair Lutfullah Kakakhel]
* Update NetworkManager to 1.12.2 [Andrei Gherzan]
* Avoid os-config-devicekey / uuid service race [Andrei Gherzan]
* Move the rw copy of config.json out of /tmp for flasher [Andrei Gherzan]
* Fix dashboard feedback on fast flashing devices [Andrei Gherzan]
* Fix ucl dependency in upx [Andrei Gherzan]
* Update kernel-modules-headers to v0.0.11 [Andrei Gherzan]

# v2.14.3
## (2018-08-13)

* Update resin supervisor to v7.16.6 [Cameron Diver]

# v2.14.2
## (2018-08-13)

* Update usb-modeswitch to version 2.5.0 [Florin Sarbu]
* Fix kernel-modules-headers compile missing bio.h [Florin Sarbu]
* Enable kernel config CONFIG_USB_SERIAL_CP210X as module [Andrei Gherzan]
* Update resin supervisor to v7.16.4 [Cameron Diver]

# v2.14.1
## (2018-08-02)

* Fix ModemManager journald logs [Andrei Gherzan]
* Fix openvpn journald logs [Andrei Gherzan]
* Set maximum openvpn reconnect timeout to 2 minutes [Andrei Gherzan]
* Resin-image: Handle absolute paths in RESIN_BOOT_PARTITION_FILES [Andrei Gherzan]
* Exclude writable files from image's fingerprints file [Andrei Gherzan]
* Update resin-supervisor to v7.16.2 [Andrei Gherzan]
* Use v4 API calls, move auth token into the request header [Gergely Imreh]
* Fix no-pie variable name in tini rocko [Andrei Gherzan]
* Fix alternative builds warnings in busybox [Andrei Gherzan]
* Don't compile mobynit in rocko with PIE [Andrei Gherzan]
* Fix key replace build warnings [Andrei Gherzan]
* Update go in krogoth to v1.9.4 [Andrei Gherzan]
* Update go in morty to v1.9.4 [Andrei Gherzan]
* Update go in pyro to v1.9.4 [Andrei Gherzan]
* Update balena to version 17.12 [Andrei Gherzan]
* Fix when ntp servers passed via config.json and dhcp [Zubair Lutfullah Kakakhel]
* Disable PIE for the aufs-util package for Rocko boards [Andrei Gherzan]
* Disable PIE for the aufs-util package for Sumo boards [Florin Sarbu]
* Update resin supervisor to v7.16.0 [Andrei Gherzan]
* Document supported modems [Andrei Gherzan]

# v2.14.0
## (2018-07-17)

* Allow re-run of useradd commands in docker-disk's entry.sh [Andrei Gherzan]
* Update rust to 1.20 and cargo to 0.21.0 in Morty [Andrei Gherzan]
* Update rust to 1.20 and cargo to 0.21.0 in Krogoth [Andrei Gherzan]
* Unify managed and unmanaged images and introduce os-config [Andrei Gherzan]

# v2.13.6
## (2018-07-13)

* Update resin-supervisor v 7.14.0 [Cameron Diver]
* Fix rootfs fingerprints on poky rocko or newer [Andrei Gherzan]
* Reboot device if there is a kernel panic [Zubair Lutfullah Kakakhel]

# v2.13.5
## (2018-07-09)

* Update resin-supervisor to v7.13.2 [Cameron Diver]

# v2.13.4
## (2018-07-09)

* Avoid overwriting SECURITY_CFLAGS for tini recipe [Andrei Gherzan]
* Fix tini segfault after sumo update [Andrei Gherzan]

# v2.13.3
## (2018-07-05)

* Update ModemManager to 1.8.0 [Andrei Gherzan]
* Switch NetworkManager to using the internal DHCP client [Andrei Gherzan]
* Update NetworkManager to 1.12.0 [Andrei Gherzan]
* Update resin-supervisor to 7.13.1 [Cameron Diver]

# v2.13.2
## (2018-06-28)

* Update balena to fix boot lag [Andrei Gherzan]
* Set DHCP timeout to infinity for IPv4 [Florin Sarbu]
* Add aufs support for kernels 4.15, 4.16 and 4.17 [Florin Sarbu]

# v2.13.1
## (2018-06-15)

* Fix mobynit runtime crash when compiled with gcc 7.3.0 with static PIE support enabled [Florin Sarbu]
* Fix typo in balena systemd service [Andrei Gherzan]
* Various fixes for issues introduced by the switch to chrony [Andrei Gherzan]
* Fsck all partitions if resin-data isn't seen [Zubair Lutfullah Kakakhel]
* Remove jethro and fido yocto versions support [Andrei Gherzan]
* Update resin-supervisor to 7.11.0 [Cameron Diver]
* Replace systemd-timesyncd with chrony [Zubair Lutfullah Kakakhel]
* Set ModemManager to ignore STM32F407 devices [Andrei Gherzan]

# v2.13.0
## (2018-06-06)

* Update resin-supervisor to 7.10.0 [Cameron Diver]
* Add support for yocto sumo [Andrei Gherzan]
* Update Readme.md with more yocto versions [Zubair Lutfullah Kakakhel]
* Docker-resin-supverisor-disk: Update supervisor to version 7.9.0 [Akis Kesoglou]
* Docker-resin-supverisor-disk: Update supervisor to version 7.5.6 [Cameron Diver]

# v2.12.7
## (2018-05-04)

* Fix typo in timeinit-timestamp service [Andrei Gherzan]
* Use system clock at boot based on RTC when available [Andrei Gherzan]
* Update Network Manager to version 1.10.2 [Florin Sarbu]
* Adds Teensy udev rules [Henry Miskin]

# v2.12.6
## (2018-04-30)

* Initialize system clock using the build time [Andrei Gherzan]
* Fix typo in resin-mounts [Mans Zigher]
* Update supervisor to v7.4.3 [Pablo Carranza Velez]
* Update supervisor to v7.4.2 [Akis Kesoglou]
* Move to Supervisor v7.4.1. [Heds Simons]
* Pass self-signed CA data to the Supervisor and for Docker registry trust. [Heds Simons]
* Extract `balenaRootCA` property from `config.json` to allow interoperation with a self-signed service. [Heds Simons]
* Split resin specific changes in dnsmasq in a separate bbappend [Andrei Gherzan]
* Allow not existing supervisor.conf file [Bruno Binet]
* Remove remnants of 1.x updater, which is not needed anymore [Gergely Imreh]
* Allow update resin spervisor when API endpoint is not available [Andrei Gherzan]
* Apply upstream patch for redsocks to fix http-config regression [Gergely Imreh]
* Update supervisor to v7.1.20 [Akis Kesoglou]

# v2.12.5
## (2018-03-22)

* Fig slang configure build warning [Andrei Gherzan]
* Fix racing issue of state label existance in initramfs [Andrei Gherzan]
* Stop dependending on udev settle at boot [Andrei Gherzan]

# v2.12.4
## (2018-03-20)

* Fix persistent logging [Andrei Gherzan]
* USB Modem (CDC ACM) support enabled as kernel module [Andrei Gherzan]
* Update supervisor to v7.1.18 [Pablo Carranza Velez]
* Add support for persistent NetworkManager state directory [Andrei Gherzan]

# v2.12.3
## (2018-03-15)

* Update supervisor to v7.1.14 [Florin Sarbu]

# v2.12.2
## (2018-03-14)

* Update supervisor to v7.1.11 [Akis Kesoglou]
* Balena: Update package to include deadlock fix [Andrei Gherzan]
* Remove bashisms in resin-init-flasher recipe [Andrei Gherzan]

# v2.12.1
## (2018-03-12)

* Disable openvpn time-based tls key renegotiation [Will Boyce]

# v2.12.0
## (2018-03-09)

* Update supervisor to v7.1.7 [Theodor Gherzan]

# v2.11.2
## (2018-03-09)

* Update supervisor to v7.1.3 [Andrei Gherzan]

# v2.11.1
## (2018-03-08)

* Resin-vars: Assume VPN port 443 if 1723 is provided in config.json [Andrei Gherzan]
* Make update-resin-supervisor POSIX compliant [Andrei Gherzan]
* Add resin-openvpn.service alias for openvpn.service [Andrei Gherzan]

# v2.11.0
## (2018-03-08)

* Fix docker-disk when docker build fails to not leave root files behind [Andrei Gherzan]
* Update supervisor to v7.1.0 [Pablo Carranza Velez]
* Fix connectivity in flasher images [Andrei Gherzan]
* Add missing kernel config dependency for leds-gpio [Andrei Gherzan]

# v2.10.1
## (2018-02-28)

* Fix docker-disk when not including any docker image [Florin Sarbu]

# v2.10.0
## (2018-02-27)

* Make sure rocko update doesn't add packages resinOS doesn't depend on [Andrei Gherzan]
* Run bluetoothd with --experimental flag [Andrei Gherzan]
* Resin-image-flasher fixes for rocko support [Andrei Gherzan]
* Use the correct, full yocto CC/CXX variables when using go [Andrei Gherzan]
* Fix 8000c in PACKAGES [Andrei Gherzan]
* Always have /lib/modules directory in rootfs as supervisor requires it [Andrei Gherzan]
* Fix console output when running resinOS with systemd >= 232 [Andrei Gherzan]
* Bring back the package which includes firmware for wilwifi 8000c [Andrei Gherzan]
* Update OpenVPN to 2.4.3 [Andrei Gherzan]
* Replace deprecated variable IMAGE_DEPENDS from image_types_resin.bbclass [Florin Sarbu]
* Replace deprecated variable IMAGE_DEPENDS from resin-image-flasher.bb [Florin Sarbu]
* Adapt sysroot services/units to be used with resinOS in container [Andrei Gherzan]
* Remove deprecated firmware: 8000c [Andrei Gherzan]
* Resin-state-reset: This service now only removes the root-overlay [Andrei Gherzan]
* Fix resin-provisioner 1.0.4 compile error on Poky Rocko [Florin Sarbu]
* Make resin-provisioner only package the resulted go binary [Florin Sarbu]
* Prepare the balena recipe for Poky Rocko [Florin Sarbu]
* Use update-alternatives for deploying resolv.conf through dnsmasq [Florin Sarbu]
* Make ModemManager depend on libxslt-native at build-time for Poky Rocko [Florin Sarbu]
* Add initial structure for supporting Poky Rocko [Florin Sarbu]
* Do not apply the use_atomic_key_generation_in_all_cases patch for dropbear 2017.75 or newer [Florin Sarbu]
* Make image-resin.bbclass depend on jq-native at buildtime [Florin Sarbu]
* Fix ucl-native ACC conformance test configure error on gcc6 [Florin Sarbu]
* Update ModemManager to version 1.7.990 [Florin Sarbu]
* Rename partition mount services to <label>.service and handle stopping services [Andrei Gherzan]
* Rename openvpn-resin service to openvpn [Andrei Gherzan]
* Kernel-resin: Fix warnings about CONFIG_DEVPTS_MULTIPLE_INSTANCES [Andrei Gherzan]
* Update supervisor to v6.6.3 [Pablo Carranza Velez]
* Let systemd handle openvpn run directory [Andrei Gherzan]
* Add support for running resinOS in a docker container [Andrei Gherzan]
* Add fs check for boot partition in initramfs [Andrei Gherzan]
* Fix kernel-modules-headers when building from sstate [Andrei Gherzan]
* Avoid mount warnings when using systemd mount units on files [Andrei Gherzan]
* Add support for private docker registry [Bruno Binet]
* Docker-disk: Various improvements [Andrei Gherzan]
* Networkmanager: Use bash-completion bbclass [Andrei Gherzan]
* Use VPN port from config.json (defaulting it to 443) [Andrei Gherzan]
* Housekeeping: adding PR template [Gergely Imreh]
* Replace busybox less by GNU less [Andrei Gherzan]
* Fix BALENA_STORAGE when machine specific definition is used [Andrei Gherzan]
* Coreutils: Set uptime to use procfs for accurate uptime [Andrei Gherzan]

# v2.9.7
## (2018-01-26)

* Install os-release file in the boot partition [Andrei Gherzan]
* Update balena to include locks fix [Andrei Gherzan]
* Healthdog: Fix RPATH on newer meta-rust [Andrei Gherzan]
* Update supervisor to v6.6.0 [Pablo Carranza Velez]

# v2.9.6
## (2018-01-12)

* Update supervisor to v6.5.9 [Pablo Carranza Velez]

# v2.9.5
## (2018-01-11)

* Update supervisor to v6.5.8 [Pablo Carranza Velez]

# v2.9.4
## (2018-01-10)

* Systemd: Backport patch to fix Remote DOS of systemd-resolve service [Andrei Gherzan]
* Hostapp-update: Bind mount /dev from host so we can resolv labels [Andrei Gherzan]
* NetworkManager: Allow managing "non-balena" bridge interfaces [Andrei Gherzan]

# v2.9.3
## (2018-01-09)

* Add lsof package [Florin Sarbu]
* Bring back resin-device-progress in resin-image [Andrei Gherzan]
* Update supervisor to v6.5.7 [Pablo Carranza Velez]
* Make hostapp-update-hooks rollback on failure optional [Gergely Imreh]

# v2.9.2
## (2017-12-18)

* Activate memory/swap cgroups in kernel [Andrei Gherzan]
* Make the grub hostapp update hook also work with non-EFI grub configs [Florin Sarbu]

# v2.9.1
## (2017-12-12)

* Update supervisor to v6.5.3 [Pablo Carranza Velez]
* Pass /mnt/root/var/lib/docker as DOCKER_ROOT to the supervisor [Florin Sarbu]

# v2.9.0
## (2017-12-11)

* Update supervisor to v6.5.1 [Pablo Carranza Velez]
* Use healthcheck with systemd and healthdog for supervisor [Andrei Gherzan]
* Update supervisor to v6.5.0 [Pablo Carranza Velez]
* Fix openvpn reporting when connectivity goes out, due to a filesystem permissions issue [Pablo Carranza Velez]
* Update balena cu include healthcheck support [Andrei Gherzan]
* Add healthdog monitoring of balena [Andrei Gherzan]
* Run the update container as privileged [Florin Sarbu]
* Fix 0-bootfiles when running hooks [Andrei Gherzan]
* Add the lsblk binary to the flasher rootfs [Florin Sarbu]
* Add boot partition space check for 0-bootfiles hostapp-update hook [Andrei Gherzan]
* Fix hostapp-update to run the hooks for the OS we update to [Andrei Gherzan]
* Switch to balena [Andrei Gherzan]

# v2.8.1
## (2017-12-01)

* Kernel-modules-headers: Include aarch64 fix [Theodor Gherzan]

# v2.8.0
## (2017-11-30)

* Support for legacy bootloaders [Theodor Gherzan]
* Update NetworkManager to version 1.10.0 [Florin Sarbu]
* Update aufs for kernel versions from 4.4 to 4.13 [Florin Sarbu]

# v2.7.8
## (2017-11-17)

* Do our best to ensure we copy to internal media the config.json after resin-device-register was able to register the board [Florin Sarbu]

# v2.7.7
## (2017-11-17)

* Delete the provisioning key after registering, to fix VPN authentication in flasher images [Pablo Carranza Velez]
* Resin-image-initramfs: Include ext4 filesystem check module in our initramfs [Florin Sarbu]
* Hostapp-update-hooks: fix typos in hook [Gergely Imreh]
* Image-resin.bbclass: Add build time dependency on coreutils-native [Florin Sarbu]
* Hostapp-update-hooks: Use boot files list from the 'next' OS [Andrei Gherzan]
* Add required kernel config dependency for being able to use redsocks [Florin Sarbu]
* Check for enough space in boot partition to support atomic copy operations [Andrei Gherzan]
* Update libmbim to version 1.14.2 [Florin Sarbu]
* Update libqmi to version 1.18.0 [Florin Sarbu]

# v2.7.6
## (2017-11-06)

* Add supervisor for the intel-quark family [Theodor Gherzan]
* Update ModemManager to version 1.6.10 [Florin Sarbu]
* Update supervisor to v6.4.2 [Pablo Carranza Velez]

# v2.7.5
## (2017-10-30)

* Ensure OpenVPN is restarted when config.json changes [Will Newton]
* Support grub boards with hostapp-update-hooks [Theodor Gherzan]

# v2.7.4
## (2017-10-24)

* Update supervisor to v6.3.6 [Pablo Carranza Velez]

# v2.7.3
## (2017-10-20)

* Update API call in update-resin-supervisor for pine 5 [Gergely Imreh]
* Fix start-resin-supervisor to start even when no supervisor image present [Gergely Imreh]
* Update supervisor to v6.3.5 [Akis Kesoglou]
* Fix fsck of boot partition with dosfstools [Will Newton]
* Backport ModemManager flow control patches [Will Newton]
* Update dnsmasq to 2.78 [Will Newton]

# v2.7.2
## (2017-10-05)

* Fix mkfs.hostapp-ext4 with pyro [Andrei Gherzan]
* Fix a syntax error in image_types_resin [Andrei Gherzan]
* Add a fixed goarch.bbclass for pyro [Will Newton]
* Docker: Improved pull progress reporting [Akis Kesoglou]
* Update supervisor to v6.3.1 [Akis Kesoglou]

# v2.7.1
## (2017-10-04)

* Update docker [Theodor Gherzan]
* Ensure docker links with systemd in pyro [Will Newton]

# v2.7.0
## (2017-10-04)

* Add support for overaly2 in mobynit [Theodor Gherzan]
* GPT support [Theodor Gherzan]
* Update-resin-supervisor: device API key is substituted incorrectly [Gergely Imreh]
* Support kernel 4.13 [Will Newton]
* Update supervisor to v6.3.0 [Akis Kesoglou]

# v2.6.1
## (2017-09-27)

* Fixes for Pyro-based flasher images [Will Newton]
* Sort config.json keys [Will Newton]

# v2.6.0
## (2017-09-20)

* Provide generic hostapp update hooks [Andrei Gherzan]
* Deploy a list of boot files in root partition [Andrei Gherzan]
* Update supervisor to v6.2.9 [Pablo Carranza Velez]
* Add usbutils package [Will Newton]
* Switch docker to inherit from Go class [Will Newton]
* Enable zram kernel module by default [Will Newton]
* Make sure hci bluetooth interfaces are activated once booted [Florin Sarbu]
* Enable kernel stack protection [Will Newton]
* Enable Yocto security flags on all builds [Will Newton]
* Update gnutls to 3.5.9 in morty because of blocking NetworkManager [Robert Fritzsche]

# v2.5.1
## (2017-09-13)

* Force use of host's docker daemon for the docker-disk recipe [Florin Sarbu]
* Remove unused plymouth files to reduce size [Michal Mazurek]

# v2.5.0
## (2017-09-12)

* Remove obsolete Go recipes [Will Newton]
* Dynamically link docker [Petros Angelatos]
* Include connectivity firmwares in Pyro [Will Newton]
* Add glib-2.0-native dependencies for Pyro [Will Newton]
* Switch to hostapp enabled rootfs [Petros Angelatos]
* Update docker to 17.06 [Petros Angelatos]
* Update modem manager to 1.6.8 [Andrei Gherzan]
* Use poky go recipes for Pyro and above [Will Newton]
* Patch mtools directory creation [Will Newton]
* Enable building Docker on Yocto Pyro [Will Newton]
* Enable fsck for resin-state partition [Will Newton]
* Add host tool dependencies for Yocto Pyro [Will Newton]
* Move systemd sanity check to image recipes [Will Newton]
* Disable rarely used kernel configs for size [Will Newton]

# v2.4.2
## (2017-08-31)

* Update NetworkManager to 1.8.2 [Andrei Gherzan]
* Only install systemd-analyze in development images [Will Newton]
* Avoid removing the supervisor container when the supervisor exits [Pablo Carranza Velez]
* Update supervisor to v6.2.5 [Pablo Carranza Velez]

# v2.4.1
## (2017-08-24)

* Fix variable referencing in default variable substitution inside prepare-openvpn script [Florin Sarbu]

# v2.4.0
## (2017-08-23)

* Use separate line for version in changelog file [Andrei Gherzan]
* Run OpenVPN service as openvpn user [Andreas Fitzek]
* Update supervisor to v6.2.1 [Akis Kesoglou]
* Watch for VPN config changes in config.json [Pagan Gazzard]

# v2.3.0
## (2017-08-16)

* Resize the splash logo to full screen instead of half screen [Gergely Imreh]
* Set docker bridge subnet to 10.114.101.1/24 [Petros Angelatos]
* Re-enable UPX compression on AArch64 [Will Newton]
* Resin-device-progress: fix typos that broke script [Gergely Imreh]
* Upgrade upx to 3.94 [Will Newton]
* Set deviceType in config.json [Will Newton]
* Update supervisor to v6.1.3 [Pablo Carranza Velez]
* Fix typo in resin-persistent-logs [Will Newton]
* Use BBCLASSEXTEND rather than inherit native [Florin Sarbu]

# v2.2.0
## (2017-07-28)

* Update supervisor to v6.1.2 [Pablo Carranza Velez]
* Support building with Yocto Pyro [Will Newton]
* Disable resin-sample NetworkManager connection [Will Newton]
* Remove support for Yocto Daisy [Will Newton]

# v2.1.0
## (2017-07-19)

* Update supervisor to v6.0.1 [Pablo Carranza Velez]
* Add support for overlay2 as docker storage driver [Andrei Gherzan]
* Detect filesystem type automatically in resin mount systemd services [Michal Mazurek]
* Fix util-linux to work with ubifs [Michal Mazurek]
* Allow setting DNS servers in config.json [Will Newton]
* Make sure resin-state-reset doesn't end up in an inconsistent state [Andrei Gherzan]
* Remove latest supervisor tag as it is not used anymore [Andrei Gherzan]
* Add NTP configuration service [Will Newton]
* Use full list of resin NTP servers [Will Newton]
* Document config.json keys in README.md [Will Newton]
* Document Change-type and Changelog-entry git commit footers [Andrei Gherzan]
* Add systemd as a required distro feature [Will Newton]

# v2.0.9
## (2017-07-06)

* Fix splash image migration in flasher images [Andrei Gherzan]
* Add missing netfilter configs for our redsocks usage [Florin Sarbu]

# v2.0.8
## (2017-07-04)

* Resin-vars: Fetch all the vars in resin-vars [Pagan Gazzard]
* Add comment in supervisor.conf for clarity [Petros Angelatos]
* Prevent supervisor from killing itself [Pablo Carranza Velez]
* Store both image and tag in the temporary supervisor.conf [Pablo Carranza Velez]
* Use current changelog format with versionist [Andrei Gherzan]
* Update supervisor to v5.1.0 and use aarch64-supervisor for aarch64 [Pablo Carranza Velez]
* Validate docker config from disk to avoid panicing [Petros Angelatos]
* Versionist: add support for full versionist use [Gergely Imreh]

# v2.0.7
## (2017-06-28)

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

# v2.0.6
## (2017-06-06)

* Update supervisor to v4.2.4 [Pablo]

# v2.0.5
## (2017-06-02)

* Fix dependencies for mount service in /var/lib [Andrei]
* Various build fixes when using other package formats like ipk [Andrei]
* Define IMAGE_NAME_SUFFIX, needed for resinhup, for Yocto versions older than Morty [Florin]
* Add support for modifying the regulatory domain for wifi interfaces [Michal]
* Add support for qmi and mbim cell modems [Joshua]
* Disable all password logins on production images, rather than just root logins - this gets rid of the password prompt dialog that users have seen. [Page]

# v2.0.4
## (2017-05-16)

* Enable the resin-uboot implementation to also boot flasher images from USB media [Florin]
* Use supervisor tag as supervisor recipe PV [Andrei}

# v2.0.3
## (2017-05-10)

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

# v2.0.2
## (2017-04-24)

* Fix build of kernel-modules-headers on kernel 4.8+ [Andrei]
* Use ondemand as default governor [Andrei]
* Do not force fsck on the data partition [Theodor]
* Switch to the new device register endpoint which exchanges the provisioning key for a device api key [Page]
* Switch to using a device api key for api calls and vpn authentication if it is present [Page]

# v2.0.1
## (2017-04-19)

* Don't use getty generator even for development images [Andrei]
* Fix resinos-img image compression [Theodor]
* Revert 05288ce19781f9ab3b8c528f49537516b58db050 [Theodor]
* Update NetworkManager to version 1.6.2 [Florin]
* Update supervisor to v4.1.2 [Pablo]
* Add aufs hashes for more kernel versions [fboudra]
* Calculate IMAGE_ROOTFS_MAXSIZE dynamically [fboudra]
* Don't attempt UPX compression on aarch64 [fboudra]
* Tidy arch detection in kernel-modules-headers [fboudra]

# v2.0.0
## (2017-03-31)

# v2.0.0-rc6
## (2017-03-31)

* Update supervisor to v4.1.1 [Pablo]
* Replace echo with info in the resindataexpander initramfs script [Florin]
* Don't stop plymouth at boot [Andrei]

# v2.0.0-rc5
## (2017-03-24)

* Fix busybox switch_root when console=null [Andrei]
* Make the initrams framework also parse root=LABEL= params [Florin]
* Fix audit disable dependencies [Theodor]
* Properly implement the ro_rootfs script [Theodor]
* Make rootfs identical to resinhup packages [Andrei]

# v2.0.0-rc4
## (2017-03-17)

* Enable by-partuuid symlinks for our DOS partition scheme also for Poky Jethro and Poky Krogoth based boards [Florin]
* Ship with e2fsprogs-tune2fs [Michal]

# v2.0.0-rc3
## (2017-03-14)

* Fix flasher detection in initramfs scripts [Andrei]
* Fix initramfs-framework build on morty [Andrei]

# v2.0.0-rc2
## (2017-03-14)

* Fix initramfs-framework for non-morty boards [Theodor]
* Fix flasher when it might corrupt the internal device [Andrei]

# v2.0.0-rc1
## (2017-03-10)

* Use stateless flasher partitions [Andrei]
* Refactor persistent logging [Theodor]
* Add support for RDT promote [Andrei]
* Fix image flag files on non uboot boards [Andrei]
* Update supervisor to v4.0.0 [Pablo]
* Change "test -z" with "test -n" in the U-Boot MMC scanning procedure [Florin]
* Implement MMC scanning for U-Boot [Andrei]
* Resin-info should not be present in our production images [Theodor]
* Implement resin-uboot based on v2.0 specification [Andrei]

# v2.0.0-beta13
## (2017-02-27)

* Fix a compile error on krogoth boards [Andrei]

# v2.0.0-beta12
## (2017-02-27)

* Disable audit subsystem [Theodor]
* Run openvpn on flasher too [Andrei]
* Add VARIANT/VARIANT_ID in os-release [Andrei]
* Modify partitions label, define entire resinOS space used to 700MiB and other minor changes [Andrei]
* Update supervisor to v3.0.1 [Pablo]
* Configure an armv7ve repository for the Resin Supervisor [Michal]
* Fix the location where to create the resinhup bundles when using poky morty [Florin]
* Introduce debug tools package group add mkfs.ext4 in resin-image [Andrei]
* Halve the UUID length to 16 bytes [Michal]

# v2.0.0-beta11
## (2017-02-15)

* Fix sectors per track for targets smaller than 512 MB [Andrei]

# v2.0.0-beta10
## (2017-02-13)

* Introduce new host OS versioning scheme [Andrei]
* Add jethro support [Andrei]
* Fix missing quotes when testing for IMGDEPLOYDIR [Florin]

# v2.0-beta.9
## (2017-02-07)

* Use static resolv.conf [Andrei]
* Switch rootfs to ext4 [Andrei]
* Adapt resinhup for poky morty migration [Florin]
* Add support for multiple entries in INTERNAL_DEVICE_KERNEL [Andrei]
* Fix bug with the .docker mountpoint [Theodor]
* Remove the supervisor container in the update script [Pablo]
* Do not remove the supervisor container in every start [Pablo]
* Update supervisor to v3.0.0 [Pablo]

# v2.0-beta.8
## (2017-01-27)

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

# v2.0-beta.7
## (2016-12-05)

* Fix supervisor.conf's SUPERVISOR_TAG variable [Florin]

# v2.0-beta.6
## (2016-12-05)

* Deactivate CONFIG_WATCHDOG_NOWAYOUT to make sure we can shutdown [Andrei]

# v2.0-beta.5
## (2016-11-30)

* Add inode tuning (1 inode for 8192 bytes ) in mkfs.ext4 for the resin-data partition [Praneeth]
* Fix missing [Manager] section for systemd watchdog setting [Florin]
* Add missing dependency for the resin-supervisor.service [Theodor]
* Specify the supervisor tag with a local variable [Theodor]
* Update supervisor to v2.8.3 [Pablo]
* Activate kernel configs for supporting iptables REJECT, MASQUERADE targets [Florin]
* systemd: enable watchdog at 10 seconds [Florin]
* Allow resin-init-flasher to also flash both MLO and regular u-boot at the same time [Florin]
* Fix page size detection in go for arm64 boards [Andrei]

# v2.0-beta.4
## (2016-11-09)

* Update supervisor to v2.8.2 [Pablo]

# v2.0-beta.3
## (2016-11-04)

* Generate SUPERVISOR_REPOSITORY dynamically so no need to define it in `resin-<board>` anymore [Andrei]
* Fix container name conflict when creating a docker container [petrosagg]
* Don't compress docker binary anymore with UPX [Andrei]
* Fix /var/lib/docker corruption after power cut [petrosagg]
* Truncate hostname to 7 characters [Michal]
* Fix aufs patching on non git kernel sources [Andrei]
* Update supervisor to v2.8.1 [Pablo]

# v2.0-beta.2
## (2016-10-25)

* Update supervisor to v2.7.1 [Pablo]
* Move supervisor.conf from /etc to /etc/resin-supervisor [Theodor]
* Update supervisor to v2.7.0 [Pablo]
* Add guide for new board adoption [Florin]
* Update supervisor to v2.6.2 [Pablo]

# v2.0-beta.1
## (2016-10-11)

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

# v1.16
## (2016-09-27)

* Update supervisor to v2.3.0 [Pablo]

# v1.15
## (2016-09-24)

* Update supervisor to v2.2.1 [petrosagg]

# v1.14
## (2016-09-23)

* Update supervisor to v2.2.0 [Kostas]

# v1.13
## (2016-09-23)

# v1.12
## (2016-09-21)

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

# v1.11
## (2016-08-31)

* Backport STOPSIGNAL fix for docker [petrosagg]
* Make Docker log to journald [Michal]

# v1.10
## (2016-08-24)

# v1.9
## (2016-08-24)

* Provide custom splash logo for our flasher type [Theodor]
* Update supervisor to v1.14.0 [Pablo]
* Set the default supervisor tag in /etc/supervisor.conf to the bundled supervisor tag. [Page]
* Update firmware: iwlwifi-7265D-10 -> iwlwifi-7265D-13 [Michal]

# v1.8
## (2016-08-02)

* Fix plymouth output to tty1 [Theodor]
* Use FAT16 filesystems as we do for partitions [Andrei]
* Fix boltdb alignment issue for armv5 in docker, fixes docker 1.10.3 on armv5 devices [Lorenzo]
* Include firmware for iwlwifi-8000C-13 - 6th generation Intel NUC [Andrei]
* Disable DHCP server functionality from dnsmasq [Florin]
* Update supervisor to v1.13.0 [Andrei]
* Start dropbearkey.service at boot and don't wait for first connection [Andrei]
* Both remove systemd-serialgetty symlinks and disable systemd-getty-generator for non-debug builds [Florin]
* Disable ntp from connman and rely only on systemd-timesyncd with selected timeservers [Florin]

# v1.7
## (2016-07-14)

* Various meta-resin layer tweaks [Andrei]
* Add support for resinhup when running kernel modules operations [Andrei]
* Update supervisor to 1.12.1 [Pablo]

# v1.6
## (2016-07-06)

# v1.5
## (2016-07-04)

* Update resin supervisor to v1.11.6 [Florin]
* Refactor openvpn dependencies [Florin]

# v1.4
## (2016-06-27)

* Replace STAGING_BUILD by DEBUG_IMAGE and various refactorings [Andrei]
* Update to latest kernel-modules-headers [Florin]

# v1.3
## (2016-06-24)

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

# v1.2
## (2016-06-08)

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

# v1.1.4
## (2016-04-20)

* Add build information in the target rootfs [Florin]
* Don't bind mount /etc/resolv.conf anymore [Florin]
* Have dnsmasq listen on 127.0.0.2 instead of 127.0.0.1 [Florin]

# v1.1.3
## (2016-04-13)

* Add resin-init-board as a runtime dependency to resin-init-flasher [Florin]

# v1.1.2
## (2016-04-13)

* Execute resin-init-board from the flasher also [Florin]
* Use realpath from coreutils-native for generating SD images [Andrei]
* Add rsync to our image [Theodor]
* Add p2p to NetworkInterfaceBlacklist in connman main.conf file [Florin]
* Add dnsmasq and do changes to connman so dnsmasq is used according to our platform needs [Florin]
* Define "rce" as a provider for the "docker" package [Florin]

# v1.1.1
## (2016-03-03)

* Make resin-supervisor-disk's PV variable not contain the ':' character [Florin]
* Workaround for "docker images" behavior - https://bugzilla.redhat.com/show_bug.cgi?id=1312934 [Florin]
* Have device registration provided by supervisor in resin-image and resin-device-register in resin-image-flasher [Andrei]
* Include crda in resin images [Andrei]
* Add support for hid-multitouch - available as kernel module [Andrei]
* Simplify os-release version and add some resin specific info [Andrei]
* Set IMAGE_ROOTFS_SIZE to zero as default [Florin]
* Update layer with the ability to use jethro [Theodor]

# v1.1.0
## (2016-02-16)

* Migrate repositories to github [Florin]
* Add resinhup package for running hostOS updates [Andrei]
* Export deltaEndpoint as DELTA_ENDPOINT [Andrei]

# v1.0.6
## (2016-02-03)

* Upgrade systemd to version 216 and add volatile-binds dependency [Florin]
* Fix racing issue on edison [Andrei]
* Add support ts7700 [Theodor]
* Remove obsolete pseudo patch. This patch is now in poky [Florin]
* Remove obsolete bash patches. These patches are now in poky [Florin]
* Ensure connman systemd service is enabled on boot [Florin]
* Change OOM Adjust Score of RCE to -900 [Praneeth]
* Change OOM Adjust Score of Connman to -1000 [Praneeth]
* Change OOM Adjust Score of OpenVPN to -1000 [Praneeth]

# v1.0.5
## (2016-01-20)

# v1.0.4

* Add mechanism for user loading custom splash logo. [Theodor]
* Add splash screen for all our images. [Theodor]
* Make connman an optional network manager [Andrei]
* Always restart openvpn service [Andrei]
* Include distribution information file in rootfs [Andrei]
* Mechanism for generating resinhup-tar packages. [Andrei]
* Implement fingerprints for resin-boot and resin-root [Andrei]
* Explicitly configure kernel with config.gz built in support [Andrei]

# v1.0.3
## (2016-01-05)

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
