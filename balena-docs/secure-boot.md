# Secure boot and full disk encryption

> Available for the `Generic x86_64 (GPT)` device type.

Secure boot is a feature that ensures the integrity and authenticity of the operating system during the boot process. It is designed to protect against unauthorized and malicious software from being loaded and executed on a computer system. When secure boot is enabled, only digitally signed boot loaders and operating system kernels with trusted signatures are allowed to run, thereby preventing the execution of unauthorized or tampered code.

Disk encryption is used to protect data stored at rest on a computer’s storage devices by encrypting the data on the disk, making it unreadable without the correct decryption key. In the event of unauthorized access or theft of the storage device, the encrypted data remains secure and inaccessible. BalenaOS uses Linux Unified Key Setup (LUKS), a disk encryption specification that provides a standard format for storing encrypted data on disk partitions. It works by creating an encrypted LUKS partition, and assigning a keyfile to unlock and access the data within it.

By combining secure boot and disk encryption you can significantly enhance the security of your system. Secure boot ensures the integrity of the boot process, preventing unauthorized software from running, while disk encryption safeguards the data stored on the disk, protecting it from unauthorized access. These security measures provide a robust defense against potential threats and help ensure the confidentiality and integrity of your system and data.

## Secure boot in balenaOS
The secure boot implementation in balenaOS is unique in several ways. Most importantly, for x86 devices, it does not use the shim first stage bootloader that other Linux distributions do and is usually signed with Microsoft platform keys. BalenaOS is an embedded distribution, and when secure boot is enabled only Balena signed operating systems are allowed to boot.

Another balenaOS characteristic is that it provides unattended disk encryption – that is, there is no user interaction when mounting the encrypted disks as it is expected from an embedded device. In order to do this, the mounting of the encrypted disks happen on a trusted system that uses secure boot. Secure boot and disk encryption have been designed to work as a bundle in balenaOS and they cannot be configured separately.

BalenaOS distributes fully tested signed images and has taken care of the management of signing material. We maintain a secure signing server in Balena’s production infrastructure that is used to sign the build artifacts with Balena’s platform keys. These are programmed in the device by the balenaOS installer when first provisioning the device. The authentication of the different boot artifacts then uses the db and dbx UEFI variables to whitelist and blacklist elements of the chain of trust. This allows updates to a new balenaOS version and prevents older versions from being bootable.

It is important to understand that balenaOS’s secure boot chain of trust finishes with the Linux kernel, that is, user space content including container applications are not authenticated. However, these can only be installed by a supervisor running in a trusted system.

Finally, balenaOS encrypts only the system partitions, any extra storage that is present will not be encrypted.

## When to use secure boot?
However, as everything related to security, there is a trade off. A secure boot enabled system introduces a degradation in performance, is more difficult to debug, will not load unsigned modules, and also has a locked down bootloader configuration and kernel, which means no kernel boot parameters can be added and hardware cannot be changed, amongst other limitations.

Balena recommends only to use a secure boot and disk encrypted system when it is a product requirement, and to consider the limitations well.

# Secure boot and full disk encryption for Generic x86_64 (GPT)
Secure boot and full disk encryption is available for the `Generic x86_64 (GPT)` device type as of balenaOS v2.114.21. This feature was updated for wider device hardware compatibility as of balenaOS 5.3.15, and balena recommended that all customers use this updated release. Secure boot and full disk encryption is available for the `Generic x86_64 (GPT)` device type. It is not available for other x86 device types such as `Generic x86-64 (legacy MBR)` and `Intel NUC`. For clarity, one can use secure boot on Intel NUC hardware and x86 hardware in general, using the `Generic x86_64 (GPT)` device type.


As described above, the secure boot implementation in balenaOS is unique in several ways. Most importantly, for x86 devices, it does not use the shim first stage bootloader that other Linux distributions do and is usually signed with Microsoft platform keys. BalenaOS is an embedded distribution, and when secure boot is enabled only Balena signed operating systems are allowed to boot. In addition, for x86 devices, the authentication of the different boot artifacts then uses the db and dbx UEFI variables to whitelist and blacklist elements of the chain of trust. This allows updates to a new balenaOS version and prevents older versions from being bootable.

## System requirements for x86 devices
As of balenaOS 5.3.15, secure boot and full disk encryption is compatible with the vast majority of current x86 hardware models. But there are requirements:


* **Trusted Platform Module (TPM) 2.0.** The x86 device must have a TPM 2.0. The TPM can be a firmware TPM or a discrete TPM. It must have a secure boot setup mode that will enroll keys. All of this is true of almost all modern x86 devices. But there are some exceptions e.g. models that ship with secure boot locked to “Deployed” mode which does not allow new keys to be enrolled.


* **Persist UEFI BIOS settings for the expected lifetime of the device.** As a necessary part of the provisioning process, customers will almost certainly change some BIOS settings to non-default values. The customer should test that these settings will persist for the expected lifetime of their device. For instance, customers should use an RTC / CMOS battery that will endure through the expected lifetime of the device. Note that extended periods without AC / mains power will shorten the life of an RTC battery.

Balena suggests starting your exploration with Intel NUC devices or ASUS NUC devices. These devices work easily with secure boot and full disk encryption. More specifically we recommend the Intel NUC 11 Essentials models and Intel NUC 13 Pro models. As noted above, please use the `Generic x86_64 (GPT)` device type with your hardware.

## Using secure boot and full disk encryption
There are two steps required to install a secure boot enabled and disk encrypted system:

* Opt-in secure boot mode in the balenaOS installer
* Configure the device’s Unified Extensible Firmware Interface (UEFI) firmware for secure boot and setup mode

Note that balenaOS currently does not support updating from a non-secure boot enabled system into a secure boot enabled one. The only way to install a secure boot and disk encrypted system at this moment is by using a balenaOS installer/flasher image.

### Configuring balenaOS installer to opt-in secure boot mode
Use the [configure](https://docs.balena.io/reference/balena-cli/#os-configure-image) command in balenaCLI (versions >= 16.2.0) to opt-in to secure boot:

```
balena os configure <image> --secureBoot --version <version> --fleet <fleetName> --device-type <deviceType>
```

This results in a change to config.json:

```
"installer": {
  "secureboot": true
}
```

### Configuring the device’s UEFI firmware
Once the balenaOS image is ready, the device needs to be configured in secure boot setup mode. This depends on the UEFI implementation, but in general there are the following steps to consider:

* Reset to the default UEFI configuration.
* Make sure the device is configured to boot in UEFI mode, for example by checking the Compatibility Support Module (CSM) used for Master Boot Record (MBR) booting is disabled.
* Change the boot options to allow booting only from the USB installer/flasher device and the main storage, and choose the USB as first boot option. The flasher will then set the UEFI configuration to boot from the main storage before rebooting.
* Disable restoring factory keys. Some systems default to restoring factory (Microsoft) keys rather than using the balena keys that will be installed during setup.
* Enable secure boot.
* Reset secure boot to setup mode

On booting in setup mode, the installer will enroll the keys into UEFI variables and encrypt the disks using the TPM device. Note that enrolling the keys manually via the UEFI setup application, while possible on some systems, is not currently supported by balenaOS as the installer’s bootloader is not signed.

If you are using balenaOS earlier than 5.3.15, an important note is that the first boot after programming is not fully secured yet as the UEFI settings (and the boot order in particular) will only be locked down during the first boot after installation. Make sure to also perform the initial boot after programming with the device in a secure controlled environment.

### System verification
A secure boot and encrypted system is indistinguishable from a standard one. It behaves in the same way as a standard system but one can still tell it is secured.

### Verifying the system boots in secure boot mode
Secure boot mode is reported in the kernel boot log that can be accessed in balenaOS from the hostOS prompt as follows:

```
~# dmesg | grep -i "secure boot"
[ 0.004752] Secure boot enabled
```

### Verify disks are encrypted
Encrypted disks appear as LUKS mounted devices in balenaOS:

```
~# mount | grep luks
/dev/mapper/luks-15b08828-36cf-4a4a-9c08-74eda88e1175 on /mnt/sysroot/active type ext4 (rw,relatime)
/dev/mapper/luks-785890e2-b7f5-4bc6-8536-471e4ec56cd0 on /mnt/state type ext4 (rw,relatime)
/dev/mapper/luks-785890e2-b7f5-4bc6-8536-471e4ec56cd0 on /etc/machine-id type ext4 (rw,relatime)
/dev/mapper/luks-0a2df5ae-194f-4f47-ac37-ce8a66084878 on /mnt/data type ext4 (rw,relatime)
/dev/mapper/luks-1ac7ec1d-85bb-4866-86ac-28648980eb80 on /mnt/boot type ext4 (rw,relatime)
```

## For more information
If you’d like a more in-depth explanation of the secure boot and full disk encryption implementation for x86, head for the [source](https://github.com/balena-os/meta-balena/blob/master/docs/uefi-secure-boot.md). For more information on the general approach to secure boot, see [Secure boot abstractions](https://github.com/balena-os/meta-balena/blob/master/docs/secure-boot-abstractions.md). 

# Road ahead
For information on future implementations for other device types such as Raspberry Pi CM4, please see the [balena roadmap](https://roadmap.balena.io/?query=secure+boot).
