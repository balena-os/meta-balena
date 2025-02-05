Secure boot abstractions
========================

# Machine configuration

A secure boot enabled system contains a split boot partition, an unencrypted
boot partition that contains the files that are essential for booting, and
an encrypted partition with the rest of the boot files.

The name of the non encrypted partition is defined in the machine configuration
file in the `BALENA_NONENC_BOOT_LABEL` variable and must use the `balena-`
prefix. For example, the boot label for EFI device is set in meta-balena to
`balena-efi`.

Note that the partition name is limited by the FAT standard to 11 characters.

The format of this label is defined so that operations like the mounting of
the partition by the `resin-mounts` package is supported out of the box.

# Key management

BalenaOS deploys signed OS artifacts for device types that support secure
boot. As such, users do not need to perform any type of key management.

# Signing classes

OS artifacts like bootloaders and kernels used for secure boot need to be
signed by the balenaCloud signing server. The signing process happens in the
build pipeline.

The signing code is abstracted into different classes. The meta-balena layer
includes signing classes that are shared between different device types:

* `sign-efi`: Implements the signing process for EFI binaries so that they
              can be authenticated by EFI firmware.
* `sign-gpg`: Implements the signingn process for binaries that need to be
              authenticated with GPG, like grub.
* `sign-kmod`: Implements the signing process for binaries that need to be
               authenticated by the Linux kernel, like kernel modules.
* `sign-rsa`: Implements the signing process for binaries that need to be
               authenticated with an RSA key.

Device specific signing classes are kept in device repositories.

# Flashing process

A balenaOS secured device uses both secure boot and disk encryption - these
two functionalities are not provided separately.

As such, a secured device always uses a flasher image that performs the
installation, including the splitting of the boot partition and the encryption
of the partitions.

The `resin-init-flasher` scripts contains the following abstractions to
support provisioning of different device types:

* `balena-init-flasher-secureboot`: This file contains the following functions
   * `secureboot_setup`
     * Secure boot setup mode
     * Key enrollment
     * Secure boot mode checks
   * `bootpart_split`
     * Split boot partition into encrypted and non-encrypted partitions
   * `secureboot_bootloader_setup`
     * Hook for secureboot bootloader setup
   * `secureboot_bootloader_postsetup`
     * Hook for secureboot bootloader post-setup
* `balena-init-flasher-diskenc`: This file contains the following functions that
  abstract the disk encryption processes.
   * `diskenc_setup`
     * Generate and encrypt disk encryption keys

# Mounting encrypted drives

The partitions are encrypted with a per-device unique encrypted key that is
kept in the non encrypted boot partition. This key itself is protected by a
private key that is device specific:

* On devices with TPM, the TPM is used to protect the disk encryption key.
* Other devices might have secure elements or OTP to store keys that can be
  used for this purpose.

Once encrypted, the partitions are mounted on root by the `cryptsetup` script
in the initramfs. This script needs to be specialized for the device specific
way in which the private key is stored.

The `os-helpers-sb` script contains a `is_secured` function that is used
to identify secure boot enabled systems. This function also needs to be
specialized for the device type. For example, on EFI systems a secure boot
enabled system will be in user mode.

# Host OS updates

The hostOS update hook copies files to the encrypted boot partition when
called with its standard name `1-bootfiles`, but uses the non encrypted
boot partition when called with a different name.

This is then used by device integration layers to discriminate where boot
files are updated to, calling the hook twice with different names and using
the `do_skip` function to decide whether to install a file or not.

See examples in device integration layers like meta-balena-raspberrypi.

# Preloading

Preloading of secure boot enabled balenaOS images is currently not supported
