# Managed OS tests

Tests the balenaOS integration with balena cloud

## Setup

The test suite setup is contained in the `suite.js` file.

1. Login to balena cloud
2. create a balena cloud fleet
3. push a release to that fleet
4. pre-register a device in the fleet
5. download the pre-registered device config.json
6. preload and configure the OS image for the fleet
7. set up the networking environment for the DUT
8. provision the DUT
9. power on the DUT and establish a connection to it over the network
10. confirm the device has appeared online in the fleet

## Current tests

The following are a high level list of tests and sub-test suites that form the managed balenaOS test suite. 

- `preload`: checks that preloading works. Including that the preloaded app started without api connectivity
- `multicontainer`: checks that the DUT can pull new releases, can be moved between apps, and balena cloud controlled env vars work as expected
- `supervisor`: checks that lockfiles, the override lockfile option, and disabling deltas works
- `ssh-auth`: checks all combinations of development and production mode and methods of gaining SSH access into a DUT work as expected
- `os-config`: checks that the os-config service configration is etched on boot, and fetched based on a random timer