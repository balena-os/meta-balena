# `balenaOS` Secure Boot and Disk Encryption

This document describes how Secure Boot and Disk Encryption are implemented in `balenaOS`. Technically these are two distinct functionalities:
* Secure boot ensures only trusted operating system images can be booted on the device
* Disk encryption ensures data is stored on the disk encrypted, rather than in plain form

`balenaOS` ties these two together into a single feature in order to achieve operator-less unlocking of the encrypted data on trusted operating systems in a trusted state.

## System Requirements

In order to enable Secure Boot, the hardware needs to meet the following requirements:
* Can boot in UEFI mode
* Can configure secure boot in UEFI setup
* Has a Trusted Platform Module (TPM) version 2, both discrete and software TPMs (Intel PTT, AMD fTPM) are supported

`balenaOS` must use a device type that supports secure boot.

## Provisioning

The feature is opt-in, in order to enable it, the following section must be appended to your installer's `config.json`:
```json
"installer": {
  "secureboot": true
}
```

Additionally, UEFI must be configured properly prior to provisioning - at this moment the only supported way of provisioning is to set secure boot into "Setup Mode". This removes all the installed keys and leaves the storage accessible for programming from userspace. The installer may reboot the device during provisioning to ensure the keys were successfully installed.

Manually loading the keys is not possible at this moment as the installer is unsigned by default.

The system must be provisioned and booted at least once in a trusted environment - the full protection is only enabled on first boot, not immediately after the installer powers the device down.

## Chain of Trust

Multiple system components are involved in the validation of a "trusted operating system":
* The process starts in the UEFI firmware, which we consider trusted by default ("root of trust")
* UEFI verifies the EFI binary being booted (in the case of `balenaOS` this is GRUB) against signatures stored in the `db` UEFI variable
* GRUB verifies the linux kernel that it loads
* The linux kernel verifies the kernel modules that it loads

The above is commonly referred to as the "chain of trust". For `balenaOS`, the trust ends at kernel level - neither the userspace applications nor user containers are verified.

### `PK`

* **Used for:** Enabling secure boot, authenticating KEK updates, authenticating PK updates
* **Type:** UEFI variable
* **Format:** ESL - list of X.509 certificates, RSA2048+SHA256
* **Stored in:** UEFI NVRAM
* **Updated by:** UEFI setup utility (manually), `balenaOS` installer (when in setup mode), HUP (using the `.auth` format with signature from previous `PK`)
* **Verified by:** Not verified once programmed, runtime updates require a valid signature from previous `PK`
* **Verifies:** `PK` updates, `KEK` updates

### `KEK`

* **Used for:** Authenticating `db` updates
* **Type:** UEFI variable
* **Format:** ESL - list of X.509 certificates, RSA2048+SHA256
* **Stored in:** UEFI NVRAM
* **Updated by:** UEFI setup utility (manually), `balenaOS` installer (when in setup mode), HUP (using the `.auth` format with signature from `PK`)
* **Verified by:** Not verified once programmed, runtime updates require a valid signature from `PK`
* **Verifies:** `db` updates

### `db`

* **Used for:** Whitelisting the bootable operating systems
* **Type:** UEFI variable
* **Format:** ESL - list of SHA256 hashes of EFI binaries
* **Stored in:** UEFI NVRAM
* **Updated by:** UEFI setup utility (manually), `balenaOS` installer (when in setup mode), HUP (using the `.auth` format with signature from `KEK`)
* **Verified by:** Not verified once programmed. Runtime updates require a valid signature from `KEK`
* **Verifies:** UEFI binary being booted - in the case of `balenaOS`, this is GRUB

### `dbx`

* **Used for:** Blacklisting the bootable operating systems, has precedence over `db`
* **Type:** UEFI variable
* **Format:** ESL - list of SHA256 hashes of EFI binaries
* **Stored in:** UEFI NVRAM
* **Updated by:** HUP when it makes sure the OS update went through (using the `.auth` format with signature from `KEK` from the inactive partition)
* **Verified by:** Not verified once programmed. Runtime updates require a valid signature from `KEK`
* **Verifies:** UEFI binary being booted - in the case of `balenaOS`, this is GRUB

### GRUB GPG key

* **Used for:** Validating files loaded by GRUB
* **Type:** GPG key
* **Format:** RSA2048
* **Stored in:** Bundled in GRUB binary during build
* **Updated by:** HUP (updates GRUB from a new OS image)
* **Verified by:** GRUB binary, which includes the key, is verified by UEFI against `db`
* **Verifies:** All the files that GRUB loads except for `grubenv` - this includes `grub.cfg` and the linux kernel being loaded

### Kernel Module Signing Keys

* **Used for:** Authenticating kernel modules being loaded; Authenticating the kernel binary itself for kexec to work
* **Type:** X.509 certificate
* **Format:** RSA4096+SHA256
* **Stored in:** Bundled in kernel binary during build
* **Updated by:** HUP (updates the kernel from a new OS image)
* **Verified by:** Kernel binary, which includes the keys, is verified by GRUB
* **Verifies:** Signature on kernel modules; Also used to verify the kernel binary itself during kexec

### LUKS Passphrase

* **Used for:** Unlocking the encrypted LUKS volumes
* **Type:** Bytes
* **Format:** 32 bytes long random string
* **Stored in:** Encrypted in the EFI partition (`balena-luks.enc`), encryption key in the TPM (TPM key slot is indicated by `balena-luks.ctx` in the EFI partition)
* **Updated by:** `balenaOS` installer during provisioning
* **Verified by:** `cryptsetup` initrd script (verified by GRUB as a part of kernel+initrd bundle), encryption key locked to PCRs 0,1,2,3
* **Verifies:** Nothing, only used for encryption

*Note:* When the installer exits, the TPM key is only protected using PCRs 0,2,3. PCR 1 contains UEFI configuration, which the installer tampers with (by changing the boot order). The system is only fully locked to PCRs 0,1,2,3 on first boot after provisioning.

## boot and EFI partition split

On regular `balenaOS` devices there is a single `resin-boot` or `balena-boot` partition mounted under `/mnt/boot`. This holds both the files necessary to boot the device (e.g. GRUB), as well as files necessary for setting up `balenaOS` (e.g. `config.json`, `system-connections`). With secure boot enabled the single boot partition is split in two:
* The `balena-efi` partition is the only one that stays unencrypted. It contains GRUB, 2nd stage linux kernel, the encrypted passphrase and the metadata necessary to talk to the TPM.
* The `balena-boot` partition is encrypted and contains everything else, as these files may contain secrets such as passwords or API keys which the encryption should protect.

The partitions are mounted under `/mnt/boot` and `/mnt/efi` respectively and `/mnt/boot/EFI` is symlinked to `../efi/EFI` to make sure all the paths are still valid.

## Using linux kernel as a 2nd stage bootloader

In order to avoid the need to make GRUB use the TPM to unlock the partitions when looking for the kernel, we keep an unencrypted copy of the linux kernel in the EFI partition whose sole purpose is to unlock the root partition using the TPM, find the actual kernel and kexec into it. This is a simple version of a completely different feature but it roughly works as follows:
1. During provisioning the installer copies an instance of its own/currently running kernel into the EFI partition.
2. When the newly provisioned OS boots, UEFI loads GRUB.
3. GRUB finds the unencrypted 2nd stage kernel in the EFI partition and executes it adding `balena_stage2` parameter to the kernel command line.
4. The attached initramfs uses the TPM to unlock the root partition.
5. Next the initramfs checks whether the `balena_stage2` parameter is present and if it is, loads the actual kernel from the root partition and kexec's into it, removing the `balena_stage2` parameter from the kernel command line and replacing the `root` parameter by the actual UUID (which is only available after unlocking LUKS).
6. The actual kernel from the root partition is executed, boot continues as usual.

## Updates

### OS updates (HUP)

Each OS build ships update files for `db` and `dbx` in the `/resin-boot` directory. These contain the hashes of GRUB to make them bootable. The files are in `.auth` format - they are signed by KEK and applicable from runtime. The OS update process is:
1. New hostapp is downloaded and unpacked to the inactive partition
2. Hashes from the new `db.auth` file are appended to the `db` variable. This makes both the current and new OS's bootable.
3. Device reboots, new OS boots up.
4. `rollback-health` checks whether the new OS is healthy.
5. If the update failed, rollback triggers and the old OS is booted up. Both OS's have valid signatures in `db` and both are still bootable so that the update can be retried.
6. If the update went through fine, `rollback-health` will look for `dbx.auth` in the inactive partition and append it to the `dbx` variable. Theoretically the old OS is no longer bootable, however this is only the case if the GRUB binary has actually changed, otherwise its hash in `db` will stay the same and both the old and the new OS's stay bootable.

### BIOS/UEFI updates

To protect the encryption keys in the TPM we lock against PCRs 0, 1, 2 and 3. Namely PCR0 is the checksum of the UEFI image, which would change by a BIOS/UEFI update. PCR1 is the checksum of the UEFI configuration which would generally change by updating anything in the UEFI configuration (e.g. disabling secure boot or changing boot order). That said, if users updates BIOS/UEFI or changes settings, the device needs to be reprovisioned afterwards.

### Hardware updates

To protect the encryption keys in the TPM we lock against PCRs 0, 1, 2 and 3. Namely PCRs 2 and 3 contain checksums of the loaded UEFI drivers for devices plugged in, their firmware and configuration. These would change if e.g. a PCIe device is replaced, its firmware is updated or even the same card is moved into a different slot. That said if hardware changes are necessary, the device needs to be reprovisioned afterwards.

## Debugging

It is important to understand that due to the nature of the feature, not all debugging procedures are available. Some of the more common ones are:
* A device in production mode will not accept any input or produce any output (screen/keyboard/serial) unless the user application sets it up. This makes it nearly impossible to debug early boot process failures (GRUB/kernel). A device in development mode will still start getty but only after the system gets all the way to userspace.
* It is not possible to tamper with GRUB configuration, which includes changing kernel parameters.
* Since the encryption keys will only be released by the TPM on the device itself in the expected configuration, it is neither possible to remove the storage media and mount/inspect it on a different device nor boot off a temporary boot media on the same device.
* Some features of the kernel are not available due to it being in lockdown mode. See `man 7 kernel_lockdown` for details.

## FAQ

* **Why do you need to enroll custom keys instead of using a trusted shim like other linux distributions?** Because `balenaOS` is not a general-purpose operating system. Devices running `balenaOS` are usually single-purpose and it is not desirable to boot anything else but `balenaOS` for them.
* **Why is the feature opt-in? Would it not be enough to just enable it when secure boot or setup mode is configured?** We know at least one piece of hardware (SteamDeck), that is in Setup Mode by default but the UEFI setup utility does not allow to configure secure boot in any way. If `balenaOS` automatically enabled secure boot on such device, it would effectively lock the device to `balenaOS` forever.
* **Why are the keys only RSA2048+SHA256? Would RSA4096+SHA512 not be better?** RSA2048+SHA256 is the minimum required by the UEFI spec. We have tried bumping both the key length and the hash algorithm but ran into compatibility issues on a significant subset of (even relatively recent) tested hardware. RSA2048+SHA256 is the only configuration that reliably works on every system.
* **Why does `db` use hashes instead of certificates?** Because certificates expire. We want to support use-cases where the provisioned device has been lying on a shelf for multiple years without being turned on, or the RTC battery on the device died and the time got reset to 1970-01-01. Hashes ensure the trusted binary can be booted regardless of system time.
* **Why is `grubenv` not verified by grub?** That is where we keep the information necessary for rollback-altboot - bootcount and whether unfinished HUP was applied. It is safe to tamper with the file as long as the values of variables read from the file are not evaluated as code. In our case they are only compared to equality.
* **Is all the hardware that meets the requirements supported?** We have tested the feature with a variety of systems and tried to handle all the corner cases and non-standard behavior that we were able to find. That said we expect the feature to work on most off-the-shelf hardware, however we do not own all the hardware in the world and users should confirm their particular systems work before deploying to production.
* **Should I simply enable the feature on all my devices to improve security?** In general - probably not. The answer depends very much on your use-case, e.g. if you have a legal requirement to have secure boot, you have no other choice, however in other cases having full control over debugging might be more beneficial. We assume that by opting-in you understand both the risks and the benefits that the feature brings.
* **Is it possible to load out-of-tree kernel modules?** All the kernel modules need to be signed with a trusted key. At this moments we only sign the module at build time so only the out-of-tree modules that we build and ship as a part of `balenaOS` are properly signed. However we are already working towards adding support for loading user-built kernel modules.
