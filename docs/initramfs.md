# `balenaOS` initramfs

A `balenaOS` kernel embeds an initramfs image that runs from memory. This image
can be used in the following ways:

* Standard boot (non-flasher images):
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

* Internal flasher image:
 * On flasher images, when a `flasher` command is found in the kernel command
   line, if the initramfs is running from the same device that the flasher
   is targetting, the flashing will be carried out from the initramfs instead of
   booting into the flasher user space.
 * This allows the flasher to work not only when booting from an external
   device, but also when booting from the internal device as is the case
   when migrating from a different operating system into `balenaOS`, or
   installing into encrypted disks.
 * Note that when flashing from the initramfs, provisioning will not happen
   so no progress reports into the cloud are possible.
 * When the migration finishes, the new system is booted into and a log file
   from the migration can be found in the installed boot partition.
 * Debugging problems with the migration can only be done locally using the
   recovery mode explained above.
