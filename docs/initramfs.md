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

* Installer boot:

  When a `flasher` command is found in the kernel command line, the initramfs
  boots in installer mode.

  Two types of installations are possible:

  * Installation running from an external storage into internal storage (flasher).

     * This is the traditional balenaOS flasher and allows to register with
       balenaCloud and send progress reports, as well as allowing for remote
       cloudlink connections to the running installer.

     * This is the default if more than one storage disks are present.

  * Installation running from initramfs into internal storage (migrator).

     * This is the default if there is only one disk and we are booting from it,
       or the installer is configured with `installer.migrate.force` by adding
       the following section to `config.json`:

       ```json
       "installer": {
         "migrate": {
           "force": true
         }
       }
       ```

     * In this mode no registration with the cloud occurs, and remote connections
       are not possible. Debugging problems with the migration can only be done
       locally using the recovery mode explained above.

     * When the installation finishes, the new system is booted into and a log
       file from the migration can be found in the installed boot partition.
