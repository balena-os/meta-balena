Change log
-----------

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
