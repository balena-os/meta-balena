# `balenaOS` initramfs

A `balenaOS` kernel embeds an initramfs image that runs from memory. This image
can be used in the following ways:

* Direct boot:
  *  Assigns default UUIDs to the disks so they can be uniquely recognized
  *  Performs a filesystem check on all system partitions
  *  Expands the data partition if required
  *  Mounts the read-only hostapp
  *  Pivots root into it

* Recovery boot:
  * When a `recovery` command is found in the kernel command line, the
    initramfs will spawn an `adbd` (android debug bridge) service on a timeout
    and wait for it to exit before continuing.
  * Note that secure boot implementations will not boot when the kernel command
    line arguments are modified
  * There is also no mechanism to remotely modify kernel command line arguments
    from a user application, so this can only be used as a local recovery
    mechanism, replacing the use of `shell` for devices with no accesible
    serial console.
