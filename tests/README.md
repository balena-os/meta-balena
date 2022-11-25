# BalenaOS automated testing

BalenaOS is tested on individual device types before being released to production. This directory contains these tests. 

The tests are split into 3 test suites:

- os: this test suite verifies that an unmanaged balenaOS works as intended. 
- cloud: this test suite verifies that a balenaOS version integrates correctly with balena cloud features
- hup: this test suite verifies that host app update (HUP) features of balenaOS work correctly

Each directory contains a readme with more details about each individual test suite

## How are the tests ran

On each PR in meta-balena, build jobs create a "draft" OS image from the contents of the branch in that PR. 
The test suites are then run against virtualised QEMU devices forv`aarch64` and `amd64` architectures.
Once a meta-balena PR is merged, a wave of PRs are automatically opened on the device repos, bumping the meta-balena version. 
The same test suites are then executed on the physical hardware corresponding to that device type. 
If the tests pass, and the PR is merged - then the new version of the OS is released to production.

## Testing framework

We use our testing framework to run these tests, called [Leviathan](https://github.com/balena-os/leviathan).
This framework allows us to run the same tests on all device types, and on both virtualised and physical environments.
It provides a common layer of abstraction that is shared by both the physical device setup, and the virtual.  

All tests in the `suites/<SUITE_NAME>` directories are executed by the Leviathan framework.

### Testing on virtualised devices

Leviathan simplifies the setup of a virtual device, running via QEMU. 

### Testing on physical devices

In order to run tests of new OS versions on real hardware, we needed a tool to automated the provisioning of these devices, and to be able to automatically interact with its interfaces. To this end, we developed a tool called the [AutoKit](https://github.com/balena-io-hardware/autokit).
It allows for:

- multiplexing SD cards between a USB host and the device under test (DUT)
- controlling the power to the DUT
- capturing video output
- providing a serial terminal
- providing a wifi AP or an ethernet connection to the DUT
- bluetooth
- a relay that can automate toggling of a jumper or switch

This tool is composed of entirely Commercial off-the-shelf (CotS) hardware, and all software is open source.

### Automated testing rigs

We have a [rig](https://github.com/balena-io-hardware/autokit-rig-sw) of autokit devices, connected to various DUT's representing device types we support, set up in multiple geographical locations, and are looking to expand this in the near future. 
We also plan to make these available for external users.

All autokits are balena devices, and are part of a fleet of tester devices. The leviathan framework handles finding available autokits in this fleet, sending them artifacts to be tested, running the tests, and collecting the logs. 
