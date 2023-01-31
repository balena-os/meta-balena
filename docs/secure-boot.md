# `balenaOS` secure boot and disk encryption

## UEFI (Unified Extensible Firmware Interface) support

Systems that boot in UEFI mode and include a trusted platform module (TPM) can be configured to boot in secure boot mode.

Enabling secure boot also enables full disk encryption. Secure boot and disk encryption cannot be used separately as only booting in secure boot mode ensures the encrypted partitions cannot be mounted by untrusted software.

Only TPM version 2 devices are currently supported.

`balenaOS` images for selected device types are signed by Balena before being deployed.

### Manual key configuration

Public keys can be configured using the UEFI interface. `balenaOS` ships the public keys in DER format inside the `balena-keys` directory in the boot partition of the installer image. The PK, KEK and DB keys need to be manually setup, and other key slots ignored.

### Setup mode

If the system boots in setup mode the `balenaOS` installer image will perform the keys configuration without user intervention. Setup mode can usually be configured by resetting the manufacturing keys in the UEFI user interface. Some systems will boot in setup mode when secure boot is enabled but no keys are configured.

### Disk encryption

When booting the installer image, if secure boot is enabled and the keys are configured, the `balenaOS` partitions are encrypted before being programmed. The encryption key pair is created by the installer image, encrypted using the TPM and stored in disk. Note than TPM protection is only fully enabled after the first boot after secure boot setup.

### System boot

On boot, the configured keys are used to authenticate the boot chain, and the partitions are decrypted and mounted using the TPM encrypted key pair.
