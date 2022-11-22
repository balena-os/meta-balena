
# Unmanaged OS tests

Tests the basic functionality of balenaOS, in isolation from balena cloud.

## Setup

The test suite setup is contained in the `suite.js` file.

1. configure the balenaOS image to be tested
2. set up the networking environment for the DUT
3. provision the DUT
4. power on the DUT and establish a connection to it over the network

## Current tests

The following are a high level list of tests and sub-test suites that form the unmanaged balenaOS test suite. 
Various components that are used in the OS have their own extensive test suites, for example network manager or the balena engine. 
These tests do not aim to duplicate the coverage in those test suites, but rather test that all coponents are working once integrated into the OS.

- some device specific tests
- `fingerprint`: tests the OS image isn't corrupted 
- `fsck`: checks ext4 filesystems are checked on boot correctly and marked appropriately
- `os-release`: checks the `/etc/os-release` file has the correct contents regarding the OS version
- `issue`: checks the `issue` file has the correct distro and version in its contents 
- `chrony`: checks timekeeping services work correctly
- `kernel-overlap`: checks there are no overlapping overlay layers
- `bluetooth`: checks the DUT can detect and connect to a bluetooth device
- `container-healthcheck`: checks that the balena engine's `HEALTHCHECK` functionality works. Implicitly tests that containers can be pushed to the DUT over local-mode, and started
- `variables`: checks that `BALENA` env vars are visible from within a container on the DUT. Implicitly tests that containers can be pushed to the DUT over local-mode, and started
- `led`: checks the OS led blink functionality works
- `modem`: checks modems work
- `config-json`: checks that the OS correctly reacts to and makes the appropriate actions based on changes to the OS `config.json`
- `boot-splash`: checks that the balenaOS boot-splash screen appears on boot. Implicitly tests HDMI/display output of DUT
- `connectivity`: checks that wifi and ethernet interfaces work, as well as the balenaOS proxy features
- `engine-socket`: checks that the balena engine socket is exposed on development-mode images, and isn't on production-mode images
- `engine-healthcheck`: Tests if the Engine recovers after being killed by Systemd's watchdog, and tests engine performance regressions
- `under-voltage`: checks the DUT isn't undervolted
- `udev`: checks udev and state links
- `device-tree`: checks that changes to dtoverlays are affected
- `purge-data`: checks that purging the devices data or state partitions causes the DUT to recover. 
- `swap`: checks zram is enabled and onfigured as swap
