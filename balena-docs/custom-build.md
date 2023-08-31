# Building Your Own Image

To build your own custom balenaOS image, refer to the README for respective device type repository hosted in the [balenaOS GitHub org](https://github.com/balena-os/) for more information.

Identifying the right repository is important. All device type repositories will start with `balena-*`, and all device types built by a repository define a device type coffee file named `machine-name.coffee` with device meta-data for the build pipeline and balenaCloud to injest. Find the correct coffee file for your machine name and read the `slug` field from it.
For example, to find the right repository for the device type Raspberry Pi 3.

1. Find the [Machine Name](https://docs.balena.io/reference/hardware/devices/) for the board you are looking for. In this case, Raspberry Pi 3's slug is `raspberrypi3`.
2. Next, search for the file `raspberrypi3.coffee` on the [GitHub Org search](https://github.com/search?q=org%3Abalena-os%20raspberrypi3.coffee&type=code)
3. From the results, we will find the repository called [balena-raspberrypi](https://github.com/balena-os/balena-raspberrypi) containing the file. 
4. Refer to [build information](https://github.com/balena-os/balena-raspberrypi/blob/master/README.md#build-information) section in the repository to find instructions to build your custom operating system. 

All coffeescript file are named based on [Device type slugs](https://docs.balena.io/reference/hardware/devices/). Similarly here are some examples for other popular devices. 

| Device Type     | GitHub Repository                                                                              |
| --------------- | ---------------------------------------------------------------------------------------------- |
| `jetson-nano`   | [https://github.com/balena-os/balena-jetson](https://github.com/balena-os/balena-jetson)       |
| `imx7-var-som`  | [https://github.com/balena-os/balena-variscite](https://github.com/balena-os/balena-variscite) |
| `nanopi-r2s`    | [https://github.com/balena-os/balena-nanopi-r2](https://github.com/balena-os/balena-nanopi-r2) |
| `generic-amd64` | [https://github.com/balena-os/balena-generic](https://github.com/balena-os/balena-generic)     |


To build your own image, refer to [Customer Board Support](https://www.balena.io/docs/reference/OS/customer-board-support/) section of docs. 