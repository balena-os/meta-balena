# `balenaOS` internals

## File-system labels vs `UUIDs` (serials)

`balenaOS` historically uses file-system labels for defining mount targets. All these labels are important as there is a hard assumption in OS that they exist and they have certain values for each partition. On certain setup configurations this is not ideal because when such configurations have partitions with conflicting labels there will be racing issue on the existence of the labels. This can happen for example in use-cases where a `balena` device burns a `balenaOS` image to other storage devices (see [etcher](https://www.balena.io/etcher/) for example). Booting the OS with multiple storage devices which have conflicting labels would most probably cause runtime issues.

In order to address this class of issues, the OS now only assumes the existence of the labels and the fact that there are no conflicting ones at first boot by doing the following:

1. The bootloader is responsible of advertising the file-system `UUIDs` (or serials) as command line arguments from a known configuration file.
  * At first boot there will be no `UUIDs` available for the bootloader so command line will not include anything related.
2. The `init` process in `initramfs` will generate new set of `UUIDs` for each `balenaOS` file-system if the command line doesn't include any `UUIDs`. In other words, if the `UUIDs` were not already generated, we proceed with this action. Along with generating the new `UUIDs`, initramfs also handles storing them on the boot partition.

As from second boot, the bootloader will find the generated `UUIDs`, pass them as kernel arguments which deactivates the generation and storing routines leaving the OS able to use them when mounting various targets.

Be aware that when we say first boot we mean first boot of the main OS image. If your device uses a flasher prepare step, the flashing boot doesn't count.
