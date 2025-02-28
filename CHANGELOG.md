Change log
-----------

# v6.4.1
## (2025-02-28)

* tests/device-tree: Rework test to not use the sysfs gpio interface [Florin Sarbu]

# v6.4.0
## (2025-02-27)

* hup: hooks: silence tpm2_flushcontext trap while updating policy [Joseph Kogut]
* hup: hooks: update passphrase in TPM NVRAM [Joseph Kogut]
* os-helpers-tpm2: lowercase vars in print_pcr_val_bin [Joseph Kogut]
* hup: signed-update: store passphrase in TPM [Joseph Kogut]
* hostapp-update-hooks: use generate_pcr_digests [Joseph Kogut]
* balena-init-flasher-tpm: use generate_pcr_digests [Joseph Kogut]
* balena-init-flasher-tpm: write LUKS passphrase to TPM nvram [Joseph Kogut]
* os-helpers-tpm2: add generate_pcr_digests [Joseph Kogut]
* os-helpers-tpm2: add tpm_nvram_store_passphrase [Joseph Kogut]
* os-helpers-tpm2: add size param to hw_gen_passphrase [Joseph Kogut]
* cryptsetup-efi-tpm: retrieve passphrase from TPM [Joseph Kogut]
* os-helpers-tpm2: add tpm_nvram_retrieve_passphrase [Joseph Kogut]

# v6.3.23
## (2025-02-25)

* modemmanager: patch for Cinterion port types [Kirill Zabelin]

# v6.3.22
## (2025-02-24)

* kernel-devsrc.bb: Use recipe from Poky for 6.12+ kernels [Florin Sarbu]

# v6.3.21
## (2025-02-21)

* kernel-balena.bbclass: Add aufs patches for 6.12 kernels [Florin Sarbu]

# v6.3.20
## (2025-02-18)

* resin-mounts: only run non-encrypted mount if partition exists [Alex Gonzalez]

# v6.3.19
## (2025-02-13)

* wpa-supplicant: Update to recipe from Kirkstone [Florin Sarbu]

# v6.3.18
## (2025-02-07)

* Update actions/setup-python digest to 4237552 [balena-renovate[bot]]

# v6.3.17
## (2025-02-07)


<details>
<summary> Update tests/leviathan digest to ae96a7e [balena-renovate[bot]] </summary>

> ## leviathan-2.31.89
> ### (2025-02-06)
> 
> * Update balena-os/leviathan-worker to v2.9.57 [balena-renovate[bot]]
> 
> ## leviathan-2.31.88
> ### (2025-02-06)
> 
> * Fix running tests over local worker IP [Ryan Cooke]
> 

</details>

# v6.3.16
## (2025-02-06)

* tests: os: swap: increase wiggle room in swap check [Ryan Cooke]

# v6.3.15
## (2025-02-06)

* tests: cloud: env vars: restart supervisor to speed up tests [Ryan Cooke]

# v6.3.14
## (2025-02-05)

* tests: secureboot: remove preload test for secureboot enabled DUTs [Ryan Cooke]

# v6.3.13
## (2025-02-01)

* tests: secureboot: fix reference to unavailable kernel-module-headers [Ryan Cooke]

# v6.3.12
## (2025-01-30)

* kernel-balena.bbclass: silence regex escape warnings [Michal Toman]
* kernel-balena.bbclass: Add aufs patches for 6.6 kernels [Michal Toman]

# v6.3.11
## (2025-01-27)


<details>
<summary> Update balena-supervisor to v16.12.0 [balena-renovate[bot]] </summary>

> ## balena-supervisor-16.12.0
> ### (2025-01-20)
> 
> * Update contrato to v0.12.0 [Felipe Lalanne]
> * Update alpine base image to 3.21 [Felipe Lalanne]
> * Update Node support to v22 [Felipe Lalanne]
> 
> ## balena-supervisor-16.11.0
> ### (2025-01-14)
> 
> * Add support for `io.balena.update.requires-reboot` [Felipe Lalanne]
> * Move reboot breadcrumb check to device-state [Felipe Lalanne]
> * Refactor device-config as part of device-state [Felipe Lalanne]
> 

</details>

# v6.3.10
## (2025-01-27)


<details>
<summary> Update tests/leviathan digest to 25370da [balena-renovate[bot]] </summary>

> ## leviathan-2.31.87
> ### (2025-01-26)
> 
> * Update actions/upload-artifact digest to 65c4c4a [balena-renovate[bot]]
> 
> ## leviathan-2.31.86
> ### (2025-01-26)
> 
> * Fix extractVersion renovate template [Kyle Harding]
> 
> ## leviathan-2.31.85
> ### (2025-01-24)
> 
> * Update core/contracts digest to cde8b88 [balena-renovate[bot]]
> 
> ## leviathan-2.31.84
> ### (2025-01-23)
> 
> * lib/components: Add partition index for Jetson TX2 NX types [Alexandru Costache]
> 

</details>

# v6.3.9
## (2025-01-27)

* workflows: iot-gate-imx8plus: add custom template path [Alexandru Costache]

# v6.3.8
## (2025-01-22)

* resin-init-flasher: add openssl dependency [Alex Gonzalez]
* initrdscript: copy image signature to memory if required [Alex Gonzalez]

# v6.3.7
## (2025-01-20)


<details>
<summary> Update tests/leviathan digest to 03a7057 [balena-renovate[bot]] </summary>

> ## leviathan-2.31.83
> ### (2025-01-09)
> 
> * Update balena-io/balena-cli to v20.2.1 [balena-renovate[bot]]
> 
> ## leviathan-2.31.82
> ### (2025-01-09)
> 
> * patch: Add retention & compression to Leviathan action artifacts [Vipul Gupta]
> 

</details>

# v6.3.6
## (2025-01-17)

* images: balena-image*: Set balenaos-img.sig image type for signed builds [Alex Gonzalez]
* classes: balenaos-img.sig: Rename the sign image type to balenaos-img.sig [Alex Gonzalez]
* image_types_balena.bbclass: Move image signing code here [Florin Sarbu]

# v6.3.5
## (2025-01-16)

* classes/kernel-balena: Avoid re-building kernel modules when not signed [Alexandru Costache]

# v6.3.4
## (2025-01-16)

* workflows: iot-gate-imx8: add custom template path [Alex Gonzalez]

# v6.3.3
## (2025-01-15)

* tests: hup: rollback-altboot: replace while loop over SSH to speed up tests [Ryan Cooke]

# v6.3.2
## (2025-01-14)

* tests: secureboot: imx: refactor bootloader config integrity tests [Alex Gonzalez]
* tests: secureboot: imx: refactor bootloader integrity test [Alex Gonzalez]
* tests: secureboot: imx: support compressed files pattern replacement [Alex Gonzalez]
* tests: secureboot: fix function that confirms a failed boot [Alex Gonzalez]

# v6.3.1
## (2025-01-13)

* peak: Update to version 8.19.0 [Florin Sarbu]

# v6.3.0
## (2025-01-09)

* Update usb-modeswitch to version 2.6.1 [Florin Sarbu]

# v6.2.8
## (2025-01-08)


<details>
<summary> Update tests/leviathan digest to 6652ce0 [balena-renovate[bot]] </summary>

> ## leviathan-2.31.81
> ### (2025-01-07)
> 
> * Update core/contracts digest to b7d2bb8 [balena-renovate[bot]]
> 
> ## leviathan-2.31.80
> ### (2025-01-06)
> 
> * Update core/contracts digest to 44bbd40 [balena-renovate[bot]]
> 
> ## leviathan-2.31.79
> ### (2025-01-06)
> 
> * Update balena-io/balena-cli to v20.1.6 [balena-renovate[bot]]
> 
> ## leviathan-2.31.78
> ### (2025-01-06)
> 
> * core: ssh tunnels: fix auth errors when worker is in prod mode [rcooke-warwick]
> 

</details>

# v6.2.7
## (2025-01-08)

* balena-image-flasher: depend on balena-image:do_image_complete [Michal Toman]

# v6.2.6
## (2025-01-03)

* workflows/meta-balena-esr: fix version array bash [Ryan Cooke]

# v6.2.5
## (2024-12-30)


<details>
<summary> Update tests/leviathan digest to c4feff6 [balena-renovate[bot]] </summary>

> ## leviathan-2.31.77
> ### (Invalid date)
> 
> * Update core/contracts digest to 8bd5651 [balena-renovate[bot]]
> 

</details>

# v6.2.4
## (2024-12-26)


<details>
<summary> Update balena-supervisor to v16.10.3 [balena-renovate[bot]] </summary>

> ## balena-supervisor-16.10.3
> ### (2024-12-20)
> 
> * Update systeminformation to v5.23.8 [SECURITY] [balena-renovate[bot]]
> 
> ## balena-supervisor-16.10.2
> ### (2024-12-18)
> 
> * Wait for service dependencies to be running [Felipe Lalanne]
> 

</details>

# v6.2.3
## (2024-12-21)


<details>
<summary> Update tests/leviathan digest to 2a609bc [balena-renovate[bot]] </summary>

> ## leviathan-2.31.76
> ### (2024-12-19)
> 
> * lib/components/os: Add SRD3 JP4 and JP5 device type boot partition indexes [Alexandru Costache]
> 
> ## leviathan-2.31.75
> ### (2024-12-19)
> 
> * Update balena-io/balena-cli to v20.1.2 [balena-renovate[bot]]
> 
> ## leviathan-2.31.74
> ### (2024-12-19)
> 
> * Update docker/setup-buildx-action digest to 6524bf6 [balena-renovate[bot]]
> 
> ## leviathan-2.31.73
> ### (2024-12-18)
> 
> * Update core/contracts digest to 9383b36 [balena-renovate[bot]]
> 
> ## leviathan-2.31.72
> ### (2024-12-18)
> 
> * Update actions/upload-artifact digest to 6f51ac0 [balena-renovate[bot]]
> 
> ## leviathan-2.31.71
> ### (2024-12-17)
> 
> * Enable selection of workers with locked DUT in secureboot tests [Ryan Cooke]
> 

</details>

# v6.2.2
## (2024-12-20)

* hostapp-update-hooks: fix path for grub_extraenv in blacklist [Alex Gonzalez]

# v6.2.1
## (2024-12-19)

* classes: kernel-balena: configure reset on oops [Alex Gonzalez]

# v6.2.0
## (2024-12-16)

* resin-init-flasher: with secure boot, authenticate the inner image [Michal Toman]

# v6.1.27
## (2024-12-14)

* README: Add fan profile and power mode info to docs [Alexandru Costache]

# v6.1.26
## (2024-12-12)


<details>
<summary> Update tests/leviathan digest to f308947 [balena-renovate[bot]] </summary>

> ## leviathan-2.31.70
> ### (2024-12-12)
> 
> * Update balena-io/balena-cli to v20.1.0 [balena-renovate[bot]]
> 

</details>

# v6.1.25
## (2024-12-11)

* github/workflows: Add yocto label to runs_on [Alexandru Costache]

<details>
<summary> Update tests/leviathan digest to 3a37005 [balena-renovate[bot]] </summary>

> ## leviathan-2.31.69
> ### (2024-12-10)
> 
> * os/balenaos: Update Xavier and Xavier NX boot partitions for JP5 [Alexandru]
> 
> ## leviathan-2.31.68
> ### (2024-12-07)
> 
> * Update balena-io/balena-cli to v20.0.9 [balena-renovate[bot]]
> 
> ## leviathan-2.31.67
> ### (2024-12-06)
> 
> * Make leviathan worker ref configurable via env var [Ryan Cooke]
> 

</details>

# v6.1.24
## (2024-12-11)


<details>
<summary> Update balena-supervisor to v16.10.1 [balena-renovate[bot]] </summary>

> ## balena-supervisor-16.10.1
> ### (2024-12-11)
> 
> * Specify `/tmp/balena|resin` directories as necessary [Christina Ying Wang]
> 
> ## balena-supervisor-16.10.0
> ### (2024-12-10)
> 
> * Add PowerFanConfig config backend [Christina Ying Wang]
> 

</details>

# v6.1.23
## (2024-12-06)


<details>
<summary> Update balena-supervisor to v16.9.0 [balena-renovate[bot]] </summary>

> ## balena-supervisor-16.9.0
> ### (2024-12-06)
> 
> * Add ability to stream logs from host services to cloud [Christina Ying Wang]
> 
> ## balena-supervisor-16.8.0
> ### (2024-12-05)
> 
> * Take update locks for host-config changes [Felipe Lalanne]
> 
> ## balena-supervisor-16.7.8
> ### (2024-11-28)
> 
> * Clean up remaining locks on state settle [Felipe Lalanne]
> * Refactor update-locks implementation [Felipe Lalanne]
> * Refactor lockfile module [Felipe Lalanne]
> 

</details>

# v6.1.22
## (2024-12-05)

* os-helpers-fs: add function to erase disks [Alex Gonzalez]

# v6.1.21
## (2024-12-04)


<details>
<summary> Update tests/leviathan digest to 90d1685 [balena-renovate[bot]] </summary>

> ## leviathan-2.31.66
> ### (2024-12-04)
> 
> * Update core/contracts digest to 474ab2d [balena-renovate[bot]]
> 

</details>

# v6.1.20
## (2024-12-04)

* kernel-module-build: update to 3.0.1 [Alex Gonzalez]
* tests: secureboot: fix passing of kernel headers version [Alex Gonzalez]
* tests: secureboot: add dm devices support in FDE test [Alex Gonzalez]
* tests: secureboot: add imx specialization [Alex Gonzalez]

# v6.1.19
## (2024-12-03)

* balena-image-initramfs: add zram module [Alex Gonzalez]
* initrdscripts: add zram module [Alex Gonzalez]
* resin-init-flasher: search /tmp explicitly [Joseph Kogut]
* kernel-balena: enable CRYPTO_ZSTD for zram [Joseph Kogut]

# v6.1.18
## (2024-12-03)

* Explicitly set GITHUB_TOKEN permissions for yocto workflow [Ryan Cooke]

# v6.1.17
## (2024-12-02)

* resin-init-flasher: adapt EFI snippets to non-LUKS devices support [Alex Gonzalez]
* balena-config-vars: adapt to flasher non-LUKS device support [Alex Gonzalez]
* resin-init-flasher: add default LUKS configuration [Alex Gonzalez]
* hostapp-update-hooks: replace the identification of encrypted partitions [Alex Gonzalez]

# v6.1.16
## (2024-11-27)

* classes/kernel-balena: Add aufs patches for 6.1 kernels [Florin Sarbu]

# v6.1.15
## (2024-11-26)

* initrdscripts/migrate: Allow overriding of target internal devices [Alexandru Costache]

# v6.1.14
## (2024-11-23)


<details>
<summary> Update tests/leviathan digest to 64ba6a3 [balena-renovate[bot]] </summary>

> ## leviathan-2.31.65
> ### (2024-11-23)
> 
> * Update balena-os/leviathan-worker to v2.9.50 [balena-renovate[bot]]
> 
> ## leviathan-2.31.64
> ### (2024-11-23)
> 
> * Update core/contracts digest to 88fb8ad [balena-renovate[bot]]
> 
> ## leviathan-2.31.63
> ### (2024-11-23)
> 
> * Update balena-io/balena-cli to v20 [balena-renovate[bot]]
> 

</details>

# v6.1.13
## (2024-11-22)

* u-boot: env_resin: fix use of skip bootcount [Alex Gonzalez]
* initrdscripts: migrate: panic on installation failure [Alex Gonzalez]

# v6.1.12
## (2024-11-21)

* balena-os: allow to specify early console for OS development builds [Alex Gonzalez]

# v6.1.11
## (2024-11-20)


<details>
<summary> Update tests/leviathan digest to ae505eb [balena-renovate[bot]] </summary>

> ## leviathan-2.31.62
> ### (2024-11-20)
> 
> * Update actions/checkout digest to 11bd719 [balena-renovate[bot]]
> 
> ## leviathan-2.31.61
> ### (2024-11-20)
> 
> * Update balena-io/balena-cli to v19.16.0 [balena-renovate[bot]]
> 

</details>

# v6.1.10
## (2024-11-15)


<details>
<summary> Update balena-supervisor to v16.7.7 [balena-renovate[bot]] </summary>

> ## balena-supervisor-16.7.7
> ### (2024-11-11)
> 
> * Firewall: allow DNS requests from custom Docker bridge networks [Christina Ying Wang]
> 

</details>

# v6.1.9
## (2024-11-15)

* Update actions/setup-python digest to 0b93645 [balena-renovate[bot]]

# v6.1.8
## (2024-11-15)

* recipes-kernel/linux-firmware: Package Intel AX210 firmware [Alexandru Costache]

# v6.1.7
## (2024-11-13)

* Update actions/checkout digest to 11bd719 [balena-renovate[bot]]

# v6.1.6
## (2024-11-13)

* Update balena-os/balena-yocto-scripts action to v1.27.10 [balena-renovate[bot]]

# v6.1.5
## (2024-11-13)

* recipes-support/os-fan-profile: Don't print logs unless configured [Alexandru Costache]
* Update tests/leviathan digest to 8234f44 [balena-renovate[bot]]

# v6.1.4
## (2024-11-12)

* os: test for rootfs by-state link uniqueness [Joseph Kogut]
* common: fix udev helper by-state link creation [Joseph Kogut]

# v6.1.3
## (2024-11-11)


<details>
<summary> Update balena-supervisor to v16.7.6 [balena-renovate[bot]] </summary>

> ## balena-supervisor-16.7.6
> ### (2024-11-07)
> 
> * Update firewall documentation [Felipe Lalanne]
> 
> ## balena-supervisor-16.7.5
> ### (2024-11-07)
> 
> * Delete apps not in target from db by appUuid instead of appId [Christina Ying Wang]
> 
> ## balena-supervisor-16.7.4
> ### (2024-10-28)
> 
> * Update express to v4.20.0 [SECURITY] [balena-renovate[bot]]
> 
> ## balena-supervisor-16.7.3
> ### (2024-10-28)
> 
> * Add NXP support to balenaOS secure boot [Alex Gonzalez]
> 
> ## balena-supervisor-16.7.2
> ### (2024-10-18)
> 
> * Use bookworm image to source journalctl binaries [Felipe Lalanne]
> 
> ## balena-supervisor-16.7.1
> ### (2024-09-26)
> 
> * Add support for init field from compose [Christina Ying Wang]
> 
> ## balena-supervisor-16.7.0
> ### (2024-09-02)
> 
> * Store rejected apps in the database [Felipe Lalanne]
> * Set the app update status when reporting state [Felipe Lalanne]
> * Add update status to types [Felipe Lalanne]
> 

</details>

# v6.1.2
## (2024-11-11)

* modemmanager: Update outdated context of patches [Florin Sarbu]

# v6.1.1
## (2024-11-07)

* README: format the supported Yocto versions for legibility [Alex Gonzalez]
* Extend README to add balena bootloader [Alex Gonzalez]

# v6.1.0
## (2024-11-01)

* Add auth. header to /os/v1/config requests [Anton Belodedenko]

# v6.0.50
## (2024-10-26)

* tests: secureboot: add test to ensure partition integrity [Joseph Kogut]

# v6.0.49
## (2024-10-25)

* tests/os: Add Jetson Orin device-specific fan and power mode smoke tests [Alexandru Costache]

# v6.0.48
## (2024-10-24)

* os-helpers-fs: introduce a script to split boot partitions [Alex Gonzalez]
* os-helpers-fs: add a shared script to deploy non-encrypted boot file [Alex Gonzalez]
* systemd: disable systemd-gpt-generator [Alex Gonzalez]
* resin-mounts: generalize non-enc boot partition mounter [Alex Gonzalez]
* classes: kernel-balena: do not remove whole build directory [Alex Gonzalez]
* efitools: Fix syntax [Alex Gonzalez]

# v6.0.47
## (2024-10-21)

* hostapp-update-hooks: remove alternative bootloader environment files [Alex Gonzalez]

# v6.0.46
## (2024-10-19)

* balena-units-conf: Add os-fan-profile to units conf [Alexandru Costache]

# v6.0.45
## (2024-10-18)

* workflows/meta-balena-esr: fix version creation bash [Ryan Cooke]

# v6.0.44
## (2024-10-10)


<details>
<summary> Update tests/leviathan digest to cf58b57 [balena-renovate[bot]] </summary>

> ## leviathan-2.31.59
> ### (2024-10-10)
> 
> * add secureboot identifier into report name [Ryan Cooke]
> 
> ## leviathan-2.31.58
> ### (2024-10-10)
> 
> * Update core/contracts digest to 5ac053b [balena-renovate[bot]]
> 
> ## leviathan-2.31.57
> ### (2024-10-10)
> 
> * Update actions/upload-artifact digest to b4b15b8 [balena-renovate[bot]]
> 
> ## leviathan-2.31.56
> ### (2024-10-09)
> 
> * compose: map qemu volume into worker [Joseph Kogut]
> 
> ## leviathan-2.31.55
> ### (2024-10-08)
> 
> * Update actions/upload-artifact digest to 8448086 [balena-renovate[bot]]
> 
> ## leviathan-2.31.54
> ### (2024-10-08)
> 
> * Update balena-io/balena-cli to v19.0.18 [balena-renovate[bot]]
> 
> ## leviathan-2.31.53
> ### (2024-10-08)
> 
> * Update actions/checkout digest to eef6144 [balena-renovate[bot]]
> 
> ## leviathan-2.31.52
> ### (2024-10-08)
> 
> * Update balena-io/balena-cli to v19.0.17 [balena-renovate[bot]]
> 
> ## leviathan-2.31.51
> ### (2024-10-07)
> 
> * Update actions/upload-artifact digest to 604373d [balena-renovate[bot]]
> 

</details>

# v6.0.43
## (2024-10-10)

* initrdscripts: Wait for boot partition in the abroot script [Michal Toman]

# v6.0.42
## (2024-10-09)

* flasher: improve logging with secure boot [Joseph Kogut]

# v6.0.41
## (2024-10-09)

* Update balena-os/balena-yocto-scripts action to v1.25.59 [balena-renovate[bot]]

# v6.0.40
## (2024-10-08)

* os-helpers-efi: silence secure boot variable checks [Joseph Kogut]
* os-helpers-efi: silence od stderr [Joseph Kogut]

# v6.0.39
## (2024-10-07)

* tests: hup: login with sdk before fetching image [Ryan Cooke]

# v6.0.38
## (2024-10-04)

* tpm2: ensure auth session contexts are flushed after use [Joseph Kogut]

# v6.0.37
## (2024-10-04)


<details>
<summary> Update tests/leviathan digest to 3a1a989 [balena-renovate[bot]] </summary>

> ## leviathan-2.31.50
> ### (2024-10-04)
> 
> * Update ubuntu to v24 [balena-renovate[bot]]
> 
> ## leviathan-2.31.49
> ### (2024-10-04)
> 
> * Update docker/setup-buildx-action digest to c47758b [balena-renovate[bot]]
> 
> ## leviathan-2.31.48
> ### (2024-10-03)
> 
> * Update balena-io/balena-cli to v19.0.13 [balena-renovate[bot]]
> 
> ## leviathan-2.31.47
> ### (2024-10-03)
> 
> * Update docker/setup-buildx-action digest to 8026d2b [balena-renovate[bot]]
> 
> ## leviathan-2.31.46
> ### (2024-10-03)
> 
> * Update core/contracts digest to 1fb0b0c [balena-renovate[bot]]
> 
> ## leviathan-2.31.45
> ### (2024-10-03)
> 
> * add .git to dockerignore [rcooke-warwick]
> * remove pull request target trigger from workflows [rcooke-warwick]
> 

</details>

# v6.0.36
## (2024-10-01)

* Update balena-os/balena-yocto-scripts action to v1.25.49 [balena-renovate[bot]]

# v6.0.35
## (2024-09-30)

* tests: cloud: prevent hanging in cloud suite teardown [rcooke-warwick]

# v6.0.34
## (2024-09-27)

* CI: Update checkout settings [Pagan Gazzard]

# v6.0.33
## (2024-09-22)

* Override the default commit body for digest updates [Kyle Harding]

# v6.0.32
## (2024-09-21)

* kernel-headers-test: update dockerfile to bullseye [Alex Gonzalez]

# v6.0.31
## (2024-09-20)

* mkfs-hostapp-native: update Dockerfile to using trixie [Alex Gonzalez]
* meta-balena-rust: rust-llvm: backport a fix for build with gcc-13 [Alex Gonzalez]

# v6.0.30
## (2024-09-18)


<details>
<summary> Update tests/leviathan digest to 17c522f [balena-renovate[bot]] </summary>

> ## leviathan-2.31.44
> ### (2024-09-18)
> 
> * Update balena-io/balena-cli to v19.0.11 [balena-renovate[bot]]
> 

</details>

# v6.0.29
## (2024-09-18)

* modemmanager: Fix SIM7100E crash [Florin Sarbu]

# v6.0.28
## (2024-09-18)

* initrdscripts: replace cut by awk for parsing lsblk in cryptsetup hook [Michal Toman]

# v6.0.27
## (2024-09-17)

* tests:os: Use writeConfigJsonProp helper function [Kyle Harding]

# v6.0.26
## (2024-09-16)


<details>
<summary> Update tests/leviathan digest to 384eab3 [balena-renovate[bot]] </summary>

> ## leviathan-2.31.43
> ### (2024-09-16)
> 
> * Update balena-os/leviathan-worker to v2.9.47 [balena-renovate[bot]]
> 
> ## leviathan-2.31.42
> ### (2024-09-16)
> 
> * Update balena-os/leviathan-worker to v2.9.46 [balena-renovate[bot]]
> 
> ## leviathan-2.31.41
> ### (2024-09-13)
> 
> * Update balena-io/balena-cli to v19.0.10 [balena-renovate[bot]]
> 
> ## leviathan-2.31.40
> ### (2024-09-12)
> 
> * Update balena-io/balena-cli to v19.0.9 [balena-renovate[bot]]
> 
> ## leviathan-2.31.39
> ### (2024-09-12)
> 
> * Update balena-io/balena-cli to v19.0.8 [balena-renovate[bot]]
> 
> ## leviathan-2.31.38
> ### (2024-09-12)
> 
> * Update balena-io/balena-cli to v19.0.7 [balena-renovate[bot]]
> 
> ## leviathan-2.31.37
> ### (2024-09-12)
> 
> * Update balena-os/leviathan-worker to v2.9.45 [balena-renovate[bot]]
> 
> ## leviathan-2.31.36
> ### (2024-09-11)
> 
> * Update balena-os/leviathan-worker to v2.9.44 [balena-renovate[bot]]
> 
> ## leviathan-2.31.35
> ### (2024-09-10)
> 
> * Update balena-io/balena-cli to v19.0.5 [balena-renovate[bot]]
> 
> ## leviathan-2.31.34
> ### (2024-09-05)
> 
> * Always upload reports, especially when tests fail [Kyle Harding]
> 
> ## leviathan-2.31.33
> ### (2024-09-05)
> 
> * Update balena-io/balena-cli to v19.0.3 [balena-renovate[bot]]
> 
> ## leviathan-2.31.32
> ### (2024-09-03)
> 
> * Update balena-io/balena-cli to v19.0.2 [balena-renovate[bot]]
> 
> ## leviathan-2.31.31
> ### (2024-09-02)
> 
> * Update actions/upload-artifact digest to 5076954 [balena-renovate[bot]]
> 
> ## leviathan-2.31.30
> ### (2024-09-02)
> 
> * Update balena-io/balena-cli to v19.0.1 [balena-renovate[bot]]
> 

</details>

# v6.0.25
## (2024-09-13)

* initrdscripts: Make cryptsetup fail hard in unexpected conditions [Michal Toman]

# v6.0.24
## (2024-09-13)

* common: fix return in commit_apply-dbx HUP hook [Joseph Kogut]

# v6.0.23
## (2024-09-12)

* tests:os: Avoid setting apiEndpoint for unmanaged tests [Kyle Harding]

# v6.0.22
## (2024-09-12)

* Update balena-os/balena-yocto-scripts action to v1.25.39 [balena-renovate[bot]]

# v6.0.21
## (2024-09-01)

* Update balena-os/balena-yocto-scripts action to v1.25.30 [balena-renovate[bot]]

# v6.0.20
## (2024-08-31)

* tests: config: restore both network options to false [Kyle Harding]

# v6.0.19
## (2024-08-31)


<details>
<summary> Update balena-supervisor to v16.6.1 [balena-renovate[bot]] </summary>

> ## balena-supervisor-16.6.1
> ### (2024-08-29)
> 
> * Remove unused patchDevice function [Felipe Lalanne]
> 
> ## balena-supervisor-16.6.0
> ### (2024-08-28)
> 
> * Add support for redsocks dnsu2t config [Christina Ying Wang]
> 

</details>

# v6.0.18
## (2024-08-31)

* Update balena-os/balena-yocto-scripts action to v1.25.28 [balena-renovate[bot]]

# v6.0.17
## (2024-08-31)

* Update Pin balena-os/balena-yocto-scripts action to a3dfa26 [balena-renovate[bot]]

# v6.0.16
## (2024-08-29)


<details>
<summary> Update tests/leviathan digest to ff6a079 [balena-renovate[bot]] </summary>

> ## leviathan-2.31.29
> ### (2024-08-29)
> 
> * Update core/contracts digest to 59752b7 [balena-renovate[bot]]
> 
> ## leviathan-2.31.28
> ### (2024-08-29)
> 
> * Update balena-os/leviathan-worker to v2.9.43 [balena-renovate[bot]]
> 
> ## leviathan-2.31.27
> ### (2024-08-29)
> 
> * Update docker/setup-buildx-action digest to 988b5a0 [balena-renovate[bot]]
> 
> ## leviathan-2.31.26
> ### (2024-08-29)
> 
> * specify ipv4 localhost for balena tunnel [rcooke-warwick]
> * Move balena-cli download to a build stage with renovate management [Kyle Harding]
> * core: update CLI to 19.0.0 [rcooke-warwick]
> 

</details>

# v6.0.15
## (2024-08-29)

* remove up-board and cl-som-imx8 [rcooke-warwick]
* Add GHA workflows for additional device types [Kyle Harding]

# v6.0.14
## (2024-08-28)


<details>
<summary> Update balena-supervisor to v16.5.8 [balena-renovate[bot]] </summary>

> ## balena-supervisor-16.5.8
> ### (2024-08-27)
> 
> * Update webpack to v5.94.0 [SECURITY] [balena-renovate[bot]]
> 
> ## balena-supervisor-16.5.7
> ### (2024-08-27)
> 
> * Add unit test for usingInferStepsLock [Christina Ying Wang]
> 
> ## balena-supervisor-16.5.6
> ### (2024-08-23)
> 
> * Revert PR #2364 [Christina Ying Wang]
> 
> ## balena-supervisor-16.5.5
> ### (2024-08-21)
> 
> * Avoid unnecessary config calls during Supervisor init [Christina Ying Wang]
> 
> ## balena-supervisor-16.5.4
> ### (2024-08-16)
> 
> * Add kmod to runtime-base [Joseph Kogut]
> 
> ## balena-supervisor-16.5.3
> ### (2024-08-08)
> 
> * Do not write `noProxy` to redsocks.conf [Felipe Lalanne]
> 
> ## balena-supervisor-16.5.2
> ### (2024-08-07)
> 
> * Verify that LED_FILE exists on blinking setup [Felipe Lalanne]
> 
> ## balena-supervisor-16.5.1
> ### (2024-08-05)
> 
> * Avoid leaking memory on deep promise recursions [Felipe Lalanne]
> 
> ## balena-supervisor-16.5.0
> ### (Invalid date)
> 
> * Use promises for setup/writing for logging backend [Felipe Lalanne]
> * Improve the LogBackend interface [Felipe Lalanne]
> * Use stream pipeline instead of pipe [Felipe Lalanne]
> * Do not use DB to store container logs info [Felipe Lalanne]
> 

</details>

# v6.0.13
## (2024-08-26)

* classes/image_types_balena: Add support for device specific boot filesystem options [Alexandru Costache]

# v6.0.12
## (2024-08-23)

* Update balena-os/balena-yocto-scripts action to v1.25.25 [balena-renovate[bot]]

# v6.0.11
## (2024-08-21)

* Update balena-os/balena-yocto-scripts action to v1.25.24 [balena-renovate[bot]]

# v6.0.10
## (2024-08-14)


<details>
<summary> Update balena-supervisor to v16.4.6 [balena-renovate[bot]] </summary>

> ## balena-supervisor-16.4.6
> ### (Invalid date)
> 
> * Update semver to v7.6.3 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.4.5
> ### (2024-07-25)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.74 [Self-hosted Renovate Bot]
> 

</details>

# v6.0.9
## (2024-08-14)


<details>
<summary> Update tests/leviathan digest to f4e9332 [balena-renovate[bot]] </summary>

> ## leviathan-2.31.25
> ### (2024-08-06)
> 
> * Update actions/upload-artifact digest to 834a144 [balena-renovate[bot]]
> 
> ## leviathan-2.31.24
> ### (2024-08-06)
> 
> * Update core/contracts digest to 6d69a05 [balena-renovate[bot]]
> 
> ## leviathan-2.31.23
> ### (2024-07-23)
> 
> * core: remove nested retries in getDutIp function [rcooke-warwick]
> 
> ## leviathan-2.31.22
> ### (2024-07-23)
> 
> * patch: Add migration & secureboot options to e2e test suite [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.31.21
> ### (2024-07-22)
> 
> * Update docker/setup-buildx-action digest to aa33708 [Self-hosted Renovate Bot]
> 

</details>

# v6.0.8
## (2024-08-14)

* tests: os: add check for iptables rules [rcooke-warwick]

# v6.0.7
## (2024-08-09)

* modemmanager: Fix Quectel modems initialization bug [Florin Sarbu]

# v6.0.6
## (2024-07-25)

* patch: Fix broken links in CDS Docs [Vipul Gupta]

# v6.0.5
## (2024-07-22)


<details>
<summary> Update balena-supervisor to v16.4.4 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-16.4.4
> ### (2024-07-17)
> 
> * Improve log message typing [Pagan Gazzard]
> 
> ## balena-supervisor-16.4.3
> ### (2024-07-16)
> 
> * Logs: only truncate the message if it's possible it will need it [Pagan Gazzard]
> * Logs: skip setting default values if we're dropping as an invalid log [Pagan Gazzard]
> * Logs: only call `Date.now()` if a timestamp is not already present [Pagan Gazzard]
> 
> ## balena-supervisor-16.4.2
> ### (2024-07-16)
> 
> * Cleanup images after state-engine tests [Felipe Lalanne]
> 

</details>

# v6.0.4
## (2024-07-22)

* Update balena-os/balena-yocto-scripts action to v1.25.8 [Self-hosted Renovate Bot]

# v6.0.3
## (2024-07-22)

* Update docker API version to match the v20.10 engine version [Alex Gonzalez]
* conf: distro: set default docker API version [Alex Gonzalez]

# v6.0.2
## (2024-07-19)


<details>
<summary> Update tests/leviathan digest to 081cbeb [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.31.20
> ### (2024-07-15)
> 
> * Update core/contracts digest to 17b44ca [Self-hosted Renovate Bot]
> 
> ## leviathan-2.31.19
> ### (2024-07-12)
> 
> * Update core/contracts digest to 773c77c [Self-hosted Renovate Bot]
> 
> ## leviathan-2.31.18
> ### (2024-07-12)
> 
> * client: use /start endpoint of worker to reserve worker if IDLE immediately [rcooke-warwick]
> 

</details>

# v6.0.1
## (2024-07-19)

* NetworkManager: remove duplicate rules in shared dispatcher script [Michal Toman]

# v6.0.0
## (2024-07-19)

* common: remove module compression bbclass [Joseph Kogut]
* kernel-balena: enable zstd module compression [Joseph Kogut]
* image-balena: support zst compressed modules [Joseph Kogut]
* kmod: enable zstd [Joseph Kogut]

# v5.4.1
## (2024-07-17)

* Add build-only GHA workflows for missing devices [Kyle Harding]

# v5.4.0
## (2024-07-13)

* classes: kernel-balena: remove configuration warnings for 6.1 [Alex Gonzalez]
* classes: balena-bootloader: add USB configuration dependencies [Alex Gonzalez]
* initrscripts: migrate: use configuration file to specify post-install action [Alex Gonzalez]
* resin-init-flasher: use configuration file to specify post-install action [Alex Gonzalez]
* tests: secureboot: add RPI specialization [Alex Gonzalez]

# v5.3.28
## (2024-07-10)

* Add GHA yocto workflows for common device types [Kyle Harding]

# v5.3.27
## (2024-07-07)


<details>
<summary> Update tests/leviathan digest to 60b559c [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.31.17
> ### (2024-07-05)
> 
> * Update actions/upload-artifact digest to 0b2256b [Self-hosted Renovate Bot]
> 
> ## leviathan-2.31.16
> ### (2024-07-04)
> 
> * Update docker/setup-buildx-action digest to 4fd8129 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.31.15
> ### (2024-06-24)
> 
> * patch: Remove internal presentation link to testbot [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.31.14
> ### (2024-06-24)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.31.13
> ### (2024-06-19)
> 
> * Update balena-os/leviathan-worker to v2.9.41 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.31.12
> ### (2024-06-19)
> 
> * Docs: Fix endpoint name from s/status/state [Vipul Gupta]
> 
> ## leviathan-2.31.11
> ### (2024-06-17)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.31.10
> ### (2024-06-14)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.31.9
> ### (2024-06-14)
> 
> * Update core/contracts digest to 8adfb6d [Self-hosted Renovate Bot]
> 
> ## leviathan-2.31.8
> ### (2024-06-14)
> 
> * Update actions/checkout digest to 692973e [Self-hosted Renovate Bot]
> 
> ## leviathan-2.31.7
> ### (2024-06-14)
> 
> * Update balena-os/leviathan-worker to v2.9.40 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.31.6
> ### (2024-06-14)
> 
> * allow for secureboot flasher env var for non-qemu runs [rcooke-warwick]
> 
> ## leviathan-2.31.5
> ### (2024-06-02)
> 
> * Update core/contracts digest to 94c4f90 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.31.4
> ### (2024-05-27)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.31.3
> ### (2024-05-24)
> 
> * Update actions/upload-artifact digest to 6546280 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.31.2
> ### (2024-05-23)
> 
> * Update Pin docker/setup-buildx-action action to d70bba7 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.31.1
> ### (2024-05-23)
> 
> * Client: Update alpine packages before installing packages [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.31.0
> ### (2024-05-23)
> 
> * minor: Add leviathan GitHub Action [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.30.22
> ### (2024-05-20)
> 
> * Update actions/checkout digest to a5ac7e5 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.21
> ### (2024-05-20)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.20
> ### (2024-05-13)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.19
> ### (2024-05-08)
> 
> * Update actions/checkout digest to 44c2b7a [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.18
> ### (2024-05-07)
> 
> * Update balena-os/leviathan-worker to v2.9.39 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.17
> ### (2024-05-06)
> 
> * Update balena-os/leviathan-worker to v2.9.38 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.16
> ### (2024-05-06)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.15
> ### (2024-05-06)
> 
> * patch: Replace environment switcher in e2e config.js [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.30.14
> ### (2024-04-29)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.13
> ### (2024-04-25)
> 
> * Update actions/upload-artifact digest to 6546280 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.12
> ### (2024-04-25)
> 
> * Update actions/checkout digest to 0ad4b8f [Self-hosted Renovate Bot]
> 

</details>

# v5.3.26
## (2024-07-07)

* tests: secureboot: rename resetWorker() to resetDUT() [Alex Gonzalez]
* tests: secureboot: refactor to facilitate extension [Alex Gonzalez]

# v5.3.25
## (2024-07-06)


<details>
<summary> Update balena-supervisor to v16.4.1 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-16.4.1
> ### (2024-07-05)
> 
> * Remove custom typings for docker-delta [Felipe Lalanne]
> 
> ## balena-supervisor-16.4.0
> ### (2024-07-04)
> 
> * Refactor host-config to be its own module [Christina Ying Wang]
> * Add HostConfig.parse method [Christina Ying Wang]
> 

</details>

# v5.3.24
## (2024-07-04)

* workflows: fix linter errors [Alex Gonzalez]

# v5.3.23
## (2024-07-02)


<details>
<summary> Update balena-supervisor to v16.3.17 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-16.3.17
> ### (2024-06-25)
> 
> * Fix engine deadlock on network+service change [Felipe Lalanne]
> 
> ## balena-supervisor-16.3.16
> ### (2024-06-17)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.72 [Self-hosted Renovate Bot]
> 

</details>

# v5.3.22
## (2024-07-01)

* initrdscripts: make the kexec script fail hard in unexpected states [Michal Toman]

# v5.3.21
## (2024-06-13)

* initrdscripts: Allow passing extra kernel arguments to kexec [Michal Toman]

# v5.3.20
## (2024-06-11)

* hostapp-update-hooks: Re-add check for UEFI to signed-update hook [Michal Toman]

# v5.3.19
## (2024-06-10)

* kernel-balena: do not use cache for signed kernel modules [Alex Gonzalez]

# v5.3.18
## (2024-06-10)


<details>
<summary> Update balena-supervisor to v16.3.15 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-16.3.15
> ### (2024-06-10)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.71 [Self-hosted Renovate Bot]
> 

</details>

# v5.3.17
## (2024-06-09)


<details>
<summary> Update balena-supervisor to v16.3.14 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-16.3.14
> ### (2024-06-09)
> 
> * Update got to v14.4.1 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.3.13
> ### (2024-06-05)
> 
> * Split target state set/get into separate module [Felipe Lalanne]
> * Move device-state.ts into the device-state/index.ts [Felipe Lalanne]
> * Move device-state/target state to api-binder/poll [Felipe Lalanne]
> 
> ## balena-supervisor-16.3.12
> ### (2024-06-03)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.70 [Self-hosted Renovate Bot]
> 

</details>

# v5.3.16
## (2024-06-06)

* Work around uuid file corruption in balenaEngine health check [Leandro Motta Barros]

# v5.3.15
## (2024-06-05)

* os-helpers-tpm2: fix empty efivar reads [Joseph Kogut]
* rollback-health: bind mount EFI partition in old_rootfs [Joseph Kogut]
* rollback-health: mount securityfs in old_rootfs [Joseph Kogut]
* os-helpers-tpm2: compute_pcr7 w/ events post separator [Joseph Kogut]

# v5.3.14
## (2024-06-02)

* rtl8192cu: Remove this unmaintained out-of-tree kernel driver [Florin Sarbu]

# v5.3.13
## (2024-05-31)


<details>
<summary> Update balena-supervisor to v16.3.11 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-16.3.11
> ### (2024-05-27)
> 
> * Move OS variant retrieval to config module [Felipe Lalanne]
> * Do not export balenaApi on api-binder [Felipe Lalanne]
> * Move api-keys module to src/lib [Felipe Lalanne]
> * Do not re-export ContractObject on lib/contracts [Felipe Lalanne]
> * Move Compose(Network|Volume)Config to top level types [Felipe Lalanne]
> * Move composition types to compose/types [Felipe Lalanne]
> * Split compose types into interface and implementation [Felipe Lalanne]
> 

</details>

# v5.3.12
## (2024-05-31)

* patch: Add Test Suite specific config for GHA [Vipul Gupta (@vipulgupta2048)]

# v5.3.11
## (2024-05-27)


<details>
<summary> Update balena-supervisor to v16.3.10 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-16.3.10
> ### (2024-05-27)
> 
> * Update got to v14.3.0 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.3.9
> ### (2024-05-27)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.69 [Self-hosted Renovate Bot]
> 

</details>

# v5.3.10
## (2024-05-24)


<details>
<summary> Update balena-supervisor to v16.3.8 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-16.3.8
> ### (2024-05-24)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.68 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.3.7
> ### (2024-05-24)
> 
> * Update sinon to v18 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.3.6
> ### (2024-05-20)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.67 [Self-hosted Renovate Bot]
> 

</details>

# v5.3.9
## (2024-05-24)

* NetworkManager: do not use FW rule numbers in shared dispatcher script [Michal Toman]

# v5.3.8
## (2024-05-23)

* tests: safe-reboot: fetch and modify target state [rcooke-warwick]

# v5.3.7
## (2024-05-22)

* tests: os: modem: fix curl command [rcooke-warwick]

# v5.3.6
## (2024-05-20)

* peak: Update to version 8.17.0 [Florin Sarbu]

# v5.3.5
## (2024-05-16)


<details>
<summary> Update balena-supervisor to v16.3.5 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-16.3.5
> ### (2024-05-13)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.66 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.3.4
> ### (2024-05-12)
> 
> * Update semver to v7.6.2 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.3.3
> ### (2024-05-10)
> 
> * Update semver to v7.6.1 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.3.2
> ### (2024-05-06)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.65 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.3.1
> ### (2024-05-01)
> 
> * Update @balena/contrato to 0.9.4 [Christina Ying Wang]
> 
> ## balena-supervisor-16.3.0
> ### (Invalid date)
> 
> * Add rpi support to balenaOS secure boot [Christina Ying Wang]
> 
> ## balena-supervisor-16.2.37
> ### (2024-04-29)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.63 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.36
> ### (2024-04-29)
> 
> * Remove unused event-stream dependency [Christina Ying Wang]
> * Update io-ts to 2.2.20, io-ts-reporters to 2.0.1, fp-ts to 2.16.5 [Christina Ying Wang]
> 
> ## balena-supervisor-16.2.35
> ### (2024-04-29)
> 
> * Update @types dependencies [Pagan Gazzard]
> 
> ## balena-supervisor-16.2.34
> ### (2024-04-29)
> 
> * Dev: update husky to v9 [Pagan Gazzard]
> 
> ## balena-supervisor-16.2.33
> ### (2024-04-26)
> 
> * Update docker related dependencies [Felipe Lalanne]
> 
> ## balena-supervisor-16.2.32
> ### (2024-04-26)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.62 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.31
> ### (2024-04-26)
> 
> * Move lib/fs-utils tests to testfs [Christina Ying Wang]
> 
> ## balena-supervisor-16.2.30
> ### (2024-04-24)
> 
> * Update supertest to v7 [Christina Ying Wang]
> * Update fork-ts-checker-webpack-plugin to v9 [Christina Ying Wang]
> * Update yargs to v17, tar-stream to v3 [Christina Ying Wang]
> 
> ## balena-supervisor-16.2.29
> ### (2024-04-24)
> 
> * Refactor MDNS resolver into a module [Felipe Lalanne]
> * Fix mdnsResolver import [Felipe Lalanne]
> 
> ## balena-supervisor-16.2.28
> ### (2024-04-23)
> 
> * Gracefully handle multiple reboot/shutdown requests [Christina Ying Wang]
> 
> ## balena-supervisor-16.2.27
> ### (2024-04-23)
> 
> * Update ts-node to v10 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.26
> ### (2024-04-23)
> 
> * Remove unnecessary @types packages [Christina Ying Wang]
> * Update knex to 3.1.0 [Christina Ying Wang]
> * Update json-mask to 2.0.0 [Christina Ying Wang]
> * Update lint-staged to 15.2.2 [Christina Ying Wang]
> * Update mocha-pod to 2.0.5 [Christina Ying Wang]
> * Update mocha to 10.4.0 [Christina Ying Wang]
> * Update rewire to 7, @balena/lint to 8 [Christina Ying Wang]
> * Update nodemon to 3.1.0 [Christina Ying Wang]
> * Update sinon to 17 [Christina Ying Wang]
> * Update systeminformation to 5.22.7 [Christina Ying Wang]
> 
> ## balena-supervisor-16.2.25
> ### (2024-04-19)
> 
> * Update copy-webpack-plugin to v12 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.24
> ### (2024-04-19)
> 
> * Update webpack-cli to v5 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.23
> ### (2024-04-19)
> 
> * Update got to v14 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.22
> ### (2024-04-19)
> 
> * Update @types/supertest to v6 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.21
> ### (2024-04-18)
> 
> * Remove unused `tmp` dependency [Pagan Gazzard]
> 
> ## balena-supervisor-16.2.20
> ### (2024-04-17)
> 
> * Update rimraf [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.19
> ### (2024-04-17)
> 
> * Update semver to v7.6.0 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.18
> ### (2024-04-15)
> 
> * Update event-stream to v3.3.5 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.17
> ### (2024-04-15)
> 
> * Add additional update lock tests for lockOverride & force [Christina Ying Wang]
> 
> ## balena-supervisor-16.2.16
> ### (2024-04-15)
> 
> * Update @types/chai-things to v0.0.38 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.15
> ### (2024-04-15)
> 
> * Update webpack to v5.76.0 [SECURITY] [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.14
> ### (2024-04-15)
> 
> * Disable automerge for major npm devDependencies [Kyle Harding]
> 
> ## balena-supervisor-16.2.13
> ### (2024-04-15)
> 
> * Update shell-quote to v1.7.3 [SECURITY] [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.12
> ### (2024-04-15)
> 
> * Update express to v4.19.2 [SECURITY] [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.11
> ### (2024-04-15)
> 
> * Enable npm package management via Renovate [Kyle Harding]
> 
> ## balena-supervisor-16.2.10
> ### (2024-04-15)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.58 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.9
> ### (2024-04-12)
> 
> * Don't follow symlinks when checking for lockfiles [Christina Ying Wang]
> 
> ## balena-supervisor-16.2.8
> ### (2024-04-12)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.57 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.7
> ### (2024-04-12)
> 
> * Add memory usage healthcheck [Christina Ying Wang]
> 
> ## balena-supervisor-16.2.6
> ### (2024-04-10)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.55 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.5
> ### (2024-04-09)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.54 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.4
> ### (2024-04-09)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.53 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.3
> ### (2024-04-09)
> 
> * Update balena-io/deploy-to-balena-action action to v2.0.52 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.2.2
> ### (2024-04-08)
> 
> * Inherit Renovate settings from balena-io [Kyle Harding]
> 
> ## balena-supervisor-16.2.1
> ### (2024-04-06)
> 
> * Fix some RegEx io-ts types [Christina Ying Wang]
> 
> ## balena-supervisor-16.2.0
> ### (2024-04-05)
> 
> * Take lock before updating service metadata [Christina Ying Wang]
> 

</details>

# v5.3.4
## (2024-05-12)

* hostapp-update-hooks: 99-balena-bootloader: Adapt to secure boot [Alex Gonzalez]
* hostapp-update-hooks: fix linter warnings [Alex Gonzalez]
* classes: image-balena: use relative path to generate boot fingerprint [Alex Gonzalez]
* os-helpers: add a helper function to generate fingerprint files [Alex Gonzalez]
* classes: sign-rsa: add dependencies [Alex Gonzalez]
* initrdscripts: migrate: allow command line argument configuration [Alex Gonzalez]
* classes: image-balena: provide board configuration hook [Alex Gonzalez]
* initrdscripts: abroot: add missing dependency [Alex Gonzalez]
* classes: kernel-balena: selectively include dmcrypt for signed images [Alex Gonzalez]
* hostapp-update-hooks: only include os-helpers-sb for signed builds [Alex Gonzalez]
* hostapp-update-hooks: 1-bootfiles: Check for os-helpers-sb before including [Alex Gonzalez]
* docs: add secure boot abstractions details [Alex Gonzalez]
* initrdscripts: fsuuidinit: use file based mutex to avoid race condition [Alex Gonzalez]
* systemd: update_state_probe: Use a file mutex to avoid race condition [Alex Gonzalez]
* os-helpers: extend filesystem helper with wait4rm [Alex Gonzalez]
* os-helpers-fs: regenerate_uuid: skip remounting [Joseph Kogut]
* resin-init-flasher: replace fatal with fail [Alex Gonzalez]
* balena-image-bootloader-initramfs: add modules needed for secure boot [Alex Gonzalez]
* classes: balena-bootloader: add support for encrypted disks mount and kexec [Alex Gonzalez]
* classes: balena-bootloader: specify a deployment subfolder [Alex Gonzalez]
* classes: kernel-balena: add secureboot configuration dependencies [Alex Gonzalez]
* classes: kernel-balena: non-efi device types also use EFI signing for kexec [Alex Gonzalez]
* classes: sign-efi: allow to configure deployment directory [Alex Gonzalez]
* classes: sign-efi: support compressed payloads [Alex Gonzalez]

# v5.3.3
## (2024-05-01)

* docs: elaborate automated testing requirement in board support guide [rcooke-warwick]

# v5.3.2
## (2024-04-25)

* contributing-device-support.md: Rework repo transfer and autokit requirement steps [Florin Sarbu]

# v5.3.1
## (2024-04-24)

* tests: os: address race in internet con. sharing tests [rcooke-warwick]

# v5.3.0
## (2024-04-24)

* hup: signed-update: silence tpm2-tools output [Joseph Kogut]
* hup: silence mountpoint [Joseph Kogut]
* hup: signed-update: print predicted PCR values after creating a policy [Joseph Kogut]
* os-helpers-tpm2: firmware_measures_efibins: silence grep [Joseph Kogut]
* os-helpers-tpm2: specify TCTI backend [Joseph Kogut]
* os-helpers-sb: silence 'command -v' [Joseph Kogut]
* hup: signed-update: update boot files as needed [Joseph Kogut]
* hup: signed-update: always remove policy directory [Joseph Kogut]
* os-helpers-tpm2: append event log digests before separator [Joseph Kogut]
* hostapp-update-hooks: signed-update: fix exit code conditional [Joseph Kogut]
* os-helpers-tpm2: fix awk syntax error causing unbootable machines [Joseph Kogut]

# v5.2.10
## (2024-04-23)

* hostapp-update-hooks: check for logging helper [Alex Gonzalez]

# v5.2.9
## (2024-04-22)


<details>
<summary> Update tests/leviathan digest to 5984adc [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.30.11
> ### (2024-04-22)
> 
> * Update actions/upload-artifact digest to 1746f4a [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.10
> ### (2024-04-22)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 

</details>

# v5.2.8
## (2024-04-17)

* Test: Unmanaged: Replace ping command in tests with curl [Vipul Gupta (@vipulgupta2048)]

# v5.2.7
## (2024-04-16)

* packagegroup-resin: Install ldd script in balenaOS images [Alexandru]

# v5.2.6
## (2024-04-16)


<details>
<summary> Update tests/leviathan digest to 0c2f44d [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.30.9
> ### (2024-04-15)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.8
> ### (2024-04-11)
> 
> * Update core/contracts digest to d06ad25 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.7
> ### (2024-04-11)
> 
> * Update core/contracts digest to bdc5ec8 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.6
> ### (2024-04-10)
> 
> * Update core/contracts digest to 619554d [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.5
> ### (2024-04-08)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.4
> ### (2024-04-08)
> 
> * Update core/contracts digest to cb7b222 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.3
> ### (2024-04-04)
> 
> * Update balena-os/leviathan-worker to v2.9.37 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.2
> ### (2024-04-04)
> 
> * core/lib/components: Specify Jetson Xavier boot partition indexes [Alexandru Costache]
> 
> ## leviathan-2.30.1
> ### (2024-04-01)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.30.0
> ### (2024-03-26)
> 
> * minor: Add general FAQ to Leviathan [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.29.67
> ### (2024-03-26)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.66
> ### (2024-03-26)
> 
> * Update core/contracts digest to 8631765 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.65
> ### (2024-03-21)
> 
> * Update core/contracts digest to 2de3526 [Self-hosted Renovate Bot]
> 

</details>

# v5.2.5
## (2024-04-12)

* classes: sign-rsa: add class for RSA artifact signing [Alex Gonzalez]

# v5.2.4
## (2024-04-03)


<details>
<summary> Update balena-supervisor to v16.1.10 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-16.1.10
> ### (2024-03-28)
> 
> * Add revpi-connect-4 to RPi variants We need the supervisor to be able to manage config.txt changes for the RevPi Connect 4. [Shreya Patel]
> 
> ## balena-supervisor-16.1.9
> ### (2024-03-25)
> 
> * Log the full error on device state report failure as it is more useful [Pagan Gazzard]
> 
> ## balena-supervisor-16.1.8
> ### (2024-03-25)
> 
> * Set @balena/es-version to es2022 to match tsconfig.json [Pagan Gazzard]
> 
> ## balena-supervisor-16.1.7
> ### (2024-03-25)
> 
> * Increase the timeout for auto select family to 5000ms to avoid issues [Pagan Gazzard]
> 
> ## balena-supervisor-16.1.6
> ### (2024-03-18)
> 
> * Pin iptables to 1.8.9 (legacy) [Christina Ying Wang]
> 

</details>

# v5.2.3
## (2024-03-22)

* mv docs/{,uefi-}secure-boot.md [Joseph Kogut]
* docs: secure-boot: update for PCR7 sealing [Joseph Kogut]
* os-helpers: compute_pcr7: merge event log digests [Joseph Kogut]
* Update policy's PCR7 value in hostapp-update hook [Joseph Kogut]
* os-helpers-tpm2: compute_pcr7: allow overriding efivars [Joseph Kogut]
* Move policy update to HUP commit hook [Joseph Kogut]
* rollback-health: move apply-dbx to HUP commit hook [Joseph Kogut]
* hostapp-hooks: include 0-signed-update only for efi [Joseph Kogut]
* secure boot: seal luks passphrase w/ PCR7 [Joseph Kogut]
* os-helpers-tpm2: separate authentication from crypto [Joseph Kogut]
* tcgtool: new recipe [Joseph Kogut]
* recipes-bsp: add recipe for GRUB 2.12 [Joseph Kogut]
* tests: skip bootloader config integrity check [Joseph Kogut]
* secureboot: enroll kernel hash in db for EFISTUB [Joseph Kogut]

# v5.2.2
## (2024-03-20)

* Update contributing-device-support with balena-info documentation [Alexandru]

# v5.2.1
## (2024-03-18)

* networkmanager: Wait for iptables lock in shared dispatcher script [Michal Toman]

# v5.2.0
## (2024-03-16)

* Update NetworkManager to version 1.46.0 [Florin Sarbu]

# v5.1.54
## (2024-03-13)

* mkfs-hostapp-native: Disable iptables features in yocto balena daemon [Kyle Harding]

# v5.1.53
## (2024-03-12)


<details>
<summary> Update balena-supervisor to v16.1.5 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-16.1.5
> ### (2024-03-12)
> 
> * Update fatrw to v0.2.21 [Felipe Lalanne]
> 

</details>

# v5.1.52
## (2024-03-11)

* images: balena-image-initramfs: remove uneeded kernel image [Alex Gonzalez]
* classes: kernel-balena-noimage: add extra space [Alex Gonzalez]

# v5.1.51
## (2024-03-08)


<details>
<summary> Update balena-supervisor to v16.1.4 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-16.1.4
> ### (2024-03-08)
> 
> * Update balena-register-device and its deps [Felipe Lalanne]
> 
> ## balena-supervisor-16.1.3
> ### (2024-03-07)
> 
> * Remove dependency on @balena/happy-eyeballs [Felipe Lalanne]
> * Update Node to v20 [Felipe Lalanne]
> 
> ## balena-supervisor-16.1.2
> ### (2024-03-06)
> 
> * Update typescript to v5 [Felipe Lalanne]
> 
> ## balena-supervisor-16.1.1
> ### (2024-03-04)
> 
> * Update @balena/lint to v7 [Felipe Lalanne]
> 

</details>

# v5.1.50
## (2024-03-07)

* tests/device-tree: Rework to account for new form of setting dtoverlay in config.txt by the supervisor [Florin Sarbu]

# v5.1.49
## (2024-03-06)


<details>
<summary> Update tests/leviathan digest to a677d89 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.64
> ### (2024-03-04)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 

</details>

# v5.1.48
## (2024-03-06)

* hostapp-update-hooks: Soft include balena-config-defaults [Michal Toman]

# v5.1.47
## (2024-03-03)

* classes: kernel-balena: fix secureboot append [Alex Gonzalez]
* classes: kernel-balena: correct dmcrypt dependencies [Alex Gonzalez]
* classes: kernel-balena: separate kexec configuration [Alex Gonzalez]
* kernel-balena: remove EFI specific settings [Alex Gonzalez]
* kernel-balena: separate EFI specific secure boot configurations [Alex Gonzalez]
* kernel-balena: remove deprecated kernel configuration [Alex Gonzalez]
* kernel-balena: add nfsd kernel setting [Alex Gonzalez]

# v5.1.46
## (2024-03-02)

* resin_update_state_probe: ignore RAID members when looking for root [Michal Toman]

# v5.1.45
## (2024-02-29)


<details>
<summary> Update tests/leviathan digest to 2b34fec [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.63
> ### (2024-02-27)
> 
> * Update core/contracts digest to f3ba2ee [Self-hosted Renovate Bot]
> 

</details>

# v5.1.44
## (2024-02-29)

* resin-init-flasher: Allow building images for non-flasher devices that have internal storage [Alexandru]

# v5.1.43
## (2024-02-28)

* Start os-config service after extracting CA [jaomaloy]

# v5.1.42
## (2024-02-28)


<details>
<summary> Update balena-supervisor to v16 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-16.1.0
> ### (2024-02-27)
> 
> * Add support for repeated overlays [Felipe Lalanne]
> 
> ## balena-supervisor-16.0.4
> ### (2024-02-27)
> 
> * Fix support for rsync deltas [Felipe Lalanne]
> 
> ## balena-supervisor-16.0.3
> ### (2024-02-21)
> 
> * Patch default dtparam handling in config.txt [Christina Ying Wang]
> 
> ## balena-supervisor-16.0.2
> ### (2024-02-17)
> 
> * Patch config.txt backend to return array configs correctly [Christina Ying Wang]
> 
> ## balena-supervisor-16.0.1
> ### (2024-02-12)
> 
> * Update balena-io/deploy-to-balena-action to v2.0.27 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-16.0.0
> ### (2024-02-08)
> 
> * Add special case for base DTO params on RPI config [Felipe Lalanne]
> * Fix processing of dtoverlay/dtparams on config.txt [Felipe Lalanne]
> 

</details>

# v5.1.41
## (2024-02-27)

* tests: hup: use secondary antenna for revpi4 [rcooke-warwick]
* tests: cloud : use secondary antenna for revpi4 [rcooke-warwick]
* tests: os: use secondary antenna for revpi4 [rcooke-warwick]

# v5.1.40
## (2024-02-26)


<details>
<summary> Update tests/leviathan digest to d71ce8f [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.62
> ### (2024-02-26)
> 
> * ad extra autokit setup information, and basic troubleshooting [rcooke-warwick]
> 

</details>

# v5.1.39
## (2024-02-26)


<details>
<summary> Update tests/leviathan digest to ef8cbac [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.61
> ### (2024-02-26)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.60
> ### (2024-02-26)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 

</details>

# v5.1.38
## (2024-02-23)

* balena-rollback: adapt to secure boot support [Alex Gonzalez]
* hostapp-update-hooks: Adapt resin-uboot hook to secure boot [Alex Gonzalez]
* classes: u-boot: use global secure boot kernel command line instead of hardcoding [Alex Gonzalez]
* grub: use global secure boot kernel command line instead of hardcoding [Alex Gonzalez]
* conf: distro: define kernel command line for secure boot [Alex Gonzalez]
* resindataexpander: encrypted partitions will auto-expand on unlock [Alex Gonzalez]
* initrdscripts: migrate: replace hardcoded kernel image names [Alex Gonzalez]
* resin-mounts: generalize secure boot mounts [Alex Gonzalez]
* initrdscripts: abroot: Use the global label for non-encrypted boot partitions [Alex Gonzalez]
* initrdscripts: allow for cryptsetup to support different secure boot implementations [Alex Gonzalez]
* os-helpers-fs: add shared wait4udev function [Alex Gonzalez]
* balena-image-flasher: fix appended variable with a leading space [Alex Gonzalez]
* balena-config-vars: customize for secure boot support [Alex Gonzalez]
* os-helpers: add dummy os-helpers-sb [Alex Gonzalez]
* resin-init-flasher: allow flasher image use in devices without internal storage [Alex Gonzalez]
* resin-init-flasher: flag non-encrypted boot partition as bootable [Alex Gonzalez]
* resin-init-flasher: replace hardcoded kernel image names [Alex Gonzalez]
* resin-init-flasher: split secureboot and disk encryption interfaces [Alex Gonzalez]
* distro: balena-os: define the boot labels as global [Alex Gonzalez]
* distro: balena-os: Specify full GO version [Alex Gonzalez]

# v5.1.37
## (2024-02-22)

* tests/device-tree: Minor spelling fixes [Alexandru]
* test/device-tree: Send vcdbg to DUT [Alexandru Costache]
* patch: Add vcdbg binary to tests [Vipul Gupta (@vipulgupta2048)]

# v5.1.36
## (2024-02-21)

* tests: hup: test breadcrumbs after rollback services [Joseph Kogut]

# v5.1.35
## (2024-02-19)


<details>
<summary> Update tests/leviathan digest to 95a9d72 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.59
> ### (2024-02-19)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.58
> ### (2024-02-14)
> 
> * Update core/contracts digest to 0c54ce2 [Self-hosted Renovate Bot]
> 

</details>

# v5.1.34
## (2024-02-14)

* resin-init-flasher: add jq dependency [Alex Gonzalez]

# v5.1.33
## (2024-02-14)

* tests: cloud: if no existing release, create generic fleet [rcooke-warwick]

# v5.1.32
## (2024-02-13)


<details>
<summary> Update tests/leviathan digest to 4b9de7e [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.57
> ### (2024-02-13)
> 
> * patch: Authenticate the validator before validation [Vipul Gupta (@vipulgupta2048)]
> 

</details>

# v5.1.31
## (2024-02-13)


<details>
<summary> Update tests/leviathan digest to 00ee51c [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.56
> ### (2024-02-12)
> 
> * Update balena-os/leviathan-worker to v2.9.36 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.55
> ### (2024-02-12)
> 
> * Update balena-os/leviathan-worker to v2.9.35 [Self-hosted Renovate Bot]
> 

</details>

# v5.1.30
## (2024-02-12)

* balena-image-bootloader-initramfs.bb: Add fsck module [Florin Sarbu]

# v5.1.29
## (2024-02-12)


<details>
<summary> Update tests/leviathan digest to f6a3391 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.54
> ### (2024-02-12)
> 
> * Update core/contracts digest to 4f7dba1 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.53
> ### (2024-02-12)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.52
> ### (2024-02-08)
> 
> * Update balena-os/leviathan-worker to v2.9.34 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.51
> ### (2024-02-06)
> 
> * Update balena-os/leviathan-worker to v2.9.33 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.50
> ### (2024-02-06)
> 
> * patch: Add config.js validator [Vipul Gupta (@vipulgupta2048)]
> 

</details>

# v5.1.28
## (2024-02-11)


<details>
<summary> Update balena-engine to v20.10.43 [Self-hosted Renovate Bot] </summary>

> ## balena-engine-20.10.43
> ### (2024-02-06)
> 
> * Update runc component to v1.1.12 from balena-runc repo [Ken Bannister]
> 

</details>

# v5.1.27
## (2024-02-09)

* patch: upgrade recipes/devtools/go to 1.17.13 [JOASSART Edwin]
* patch: removes recipes/devtools/go to 1.16 [JOASSART Edwin]

# v5.1.26
## (2024-02-06)


<details>
<summary> Update balena-supervisor to v15.3.1 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-15.3.1
> ### (2024-02-01)
> 
> * Respect update strategies app-wide instead of at the service level [Christina Ying Wang]
> 

</details>

# v5.1.25
## (2024-02-06)


<details>
<summary> Update tests/leviathan digest to a708a7f [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.49
> ### (2024-02-05)
> 
> * Update actions/upload-artifact digest to 5d5d22a [Self-hosted Renovate Bot]
> 

</details>

# v5.1.24
## (2024-02-05)


<details>
<summary> Update tests/leviathan digest to 57ba19b [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.48
> ### (2024-02-05)
> 
> * Update balena-os/leviathan-worker to v2.9.32 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.47
> ### (2024-02-05)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 

</details>

# v5.1.23
## (2024-02-05)

* tests: cloud: disable dut internet after flashing [rcooke-warwick]

# v5.1.22
## (2024-02-02)

* balena-rollback/rollback-health: Allow old OS hooks to access efivars [Alexandru Costache]

# v5.1.21
## (2024-02-01)


<details>
<summary> Update tests/leviathan digest to dd2285a [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.46
> ### (2024-02-01)
> 
> * Update core/contracts digest to 75a9764 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.45
> ### (2024-02-01)
> 
> * Update core/contracts digest to 8dfe06b [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.44
> ### (Invalid date)
> 
> * Update balena-os/leviathan-worker to v2.9.30 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.43
> ### (2024-01-29)
> 
> * Update balena-os/leviathan-worker to v2.9.29 [Self-hosted Renovate Bot]
> 

</details>

# v5.1.20
## (2024-02-01)


<details>
<summary> Update balena-supervisor to v15.3.0 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-15.3.0
> ### (2024-01-26)
> 
> * Pin docker version to v24 for tests [Felipe Lalanne]
> * Fix docker utils tests for docker v25 [Felipe Lalanne]
> * Enable nodemon when using test:env [Felipe Lalanne]
> * Improve test:compose and test:env commands [Felipe Lalanne]
> * Add prettierrc for editor compatibility [Felipe Lalanne]
> 

</details>

# v5.1.19
## (2024-01-31)

* Add balena bootloader class [Michal Toman]
* initrdscripts: remove nr_cpus kernel arg before kexec [Michal Toman]

# v5.1.18
## (2024-01-29)

* classes: kernel-balena: expose watchdog in sysfs [Alex Gonzalez]

# v5.1.17
## (2024-01-29)


<details>
<summary> Update tests/leviathan digest to 01e65ec [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.42
> ### (2024-01-29)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 

</details>

# v5.1.16
## (2024-01-27)


<details>
<summary> Update tests/leviathan digest to 7c94243 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.41
> ### (2024-01-26)
> 
> * Update balena-os/leviathan-worker to v2.9.28 [Self-hosted Renovate Bot]
> 

</details>

# v5.1.15
## (2024-01-26)

* networkmanager: make FORWARD rules for shared interfaces last in chain [Michal Toman]

# v5.1.14
## (2024-01-24)


<details>
<summary> Update tests/leviathan digest to e618772 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.40
> ### (2024-01-23)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.39
> ### (2024-01-23)
> 
> * Update actions/upload-artifact digest to 26f96df [Self-hosted Renovate Bot]
> 

</details>

# v5.1.13
## (2024-01-23)

* Start extract-balena-ca before os-config update [jaomaloy]

# v5.1.12
## (2024-01-19)


<details>
<summary> Update tests/leviathan digest to 6be4049 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.38
> ### (2024-01-18)
> 
> * Update actions/upload-artifact digest to 694cdab [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.37
> ### (2024-01-15)
> 
> * Update actions/upload-artifact digest to 1eb3cb2 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.36
> ### (2024-01-15)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 

</details>

# v5.1.11
## (2024-01-18)

* kernel-balena: Only sign initramfs for EFI machines [Alex Gonzalez]
* balena-image: Add TPM tools conditionally on tpm machine feature [Alex Gonzalez]
* initrdscripts: Add TPM/EFI tools conditionally on tpm machine feature [Alex Gonzalez]
* os-helpers: rename os-helpers-secureboot to os-helpers-efi [Alex Gonzalez]
* image-balena: extract hup boot partition checks into a function [Alex Gonzalez]
* balena-keys: Distinguish EFI devices [Alex Gonzalez]
* balena-image-flasher: only add grub configuration for EFI devices [Alex Gonzalez]
* balena-image: only add grub configuration for EFI machines [Alex Gonzalez]

# v5.1.10
## (2024-01-12)

* tests/bluetooth: Leave Autokit host discoverable on BT for a longer period of time [Alexandru Costache]

# v5.1.9
## (2024-01-11)


<details>
<summary> Update tests/leviathan digest to 0210c02 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.35
> ### (2024-01-11)
> 
> * change to ssh tunnel [rcooke-warwick]
> 
> ## leviathan-2.29.34
> ### (2024-01-10)
> 
> * Update core/contracts digest to 14a10d9 [Self-hosted Renovate Bot]
> 

</details>

# v5.1.8
## (2024-01-09)


<details>
<summary> Update tests/leviathan digest to dbcacdb [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.33
> ### (2024-01-09)
> 
> * timeout netcat process [rcooke-warwick]
> 

</details>

# v5.1.7
## (2024-01-09)


<details>
<summary> Update balena-supervisor to v15.2.0 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-15.2.0
> ### (2024-01-08)
> 
> * Try MDNS lookup only if regular DNS lookup fails [Felipe Lalanne]
> * Refactor mdns lookup code in app entry [Felipe Lalanne]
> 
> ## balena-supervisor-15.1.1
> ### (2024-01-02)
> 
> * docs: api: start-service: specify this endpoint affects the device [Alex Gonzalez]
> 
> ## balena-supervisor-15.1.0
> ### (2023-11-22)
> 
> * Force remove container if updateMetadata fails [Felipe Lalanne]
> 

</details>

# v5.1.6
## (2024-01-08)


<details>
<summary> Update tests/leviathan digest to 5163c31 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.32
> ### (2024-01-08)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.31
> ### (2024-01-05)
> 
> * Update core/contracts digest to b469f31 [Self-hosted Renovate Bot]
> 

</details>

# v5.1.5
## (2024-01-01)


<details>
<summary> Update tests/leviathan digest to 70db044 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.30
> ### (2024-01-01)
> 
> * Update core/contracts digest to dd3614e [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.29
> ### (2024-01-01)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 

</details>

# v5.1.4
## (2023-12-25)


<details>
<summary> Update tests/leviathan digest to 5068028 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.28
> ### (2023-12-25)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 

</details>

# v5.1.3
## (2023-12-22)


<details>
<summary> Update tests/leviathan digest to 57546f9 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.27
> ### (2023-12-22)
> 
> * Update balena-os/leviathan-worker to v2.9.27 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.26
> ### (2023-12-21)
> 
> * Update core/contracts digest to 31188f5 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.25
> ### (2023-12-18)
> 
> * Update actions/upload-artifact action to v4 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.24
> ### (2023-12-18)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.23
> ### (2023-12-13)
> 
> * Update core/contracts digest to 591fda9 [Self-hosted Renovate Bot]
> 

</details>

# v5.1.2
## (2023-12-21)

* balena-config-vars: increase config.json parsing resilience [Alex Gonzalez]

# v5.1.1
## (2023-12-20)


<details>
<summary> Update balena-engine to v20.10.42 [Self-hosted Renovate Bot] </summary>

> ## balena-engine-20.10.42
> ### (2023-12-19)
> 
> * Update actions/upload-artifact to v4 and generate unique artifacts [Kyle Harding]
> 

</details>

# v5.1.0
## (2023-12-19)

* migrate: check for mount point before umounting [Alex Gonzalez]
* initrdscripts: move mounting of log mounts to finish module [Alex Gonzalez]

# v5.0.11
## (2023-12-14)

* update-balena-supervisor: fix supervisor.conf when image already downloaded [Alex Gonzalez]

# v5.0.10
## (2023-12-13)

* hostapp-update-hooks: add debug mode [Alex Gonzalez]

# v5.0.9
## (2023-12-12)

* timesync-https: increase default connection max time to 10s [Alex Gonzalez]

# v5.0.8
## (2023-12-11)


<details>
<summary> Update tests/leviathan digest to c681ee1 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.22
> ### (2023-12-11)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.21
> ### (2023-12-04)
> 
> * Update balena-os/leviathan-worker to v2.9.26 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.20
> ### (2023-12-04)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 

</details>

# v5.0.7
## (2023-12-06)

* Update actions/setup-python action to v5 [Self-hosted Renovate Bot]

# v5.0.6
## (2023-12-05)

* os-helpers-logging: replace broken container check [Alex Gonzalez]

# v5.0.5
## (2023-12-02)


<details>
<summary> Update tests/leviathan digest to eaf8774 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.19
> ### (2023-12-01)
> 
> * add jetson-agx-orin-devkit resin-boot index [rcooke-warwick]
> 

</details>

# v5.0.4
## (2023-12-01)


<details>
<summary> Update balena-engine to v20.10.41 [Self-hosted Renovate Bot] </summary>

> ## balena-engine-20.10.41
> ### (2023-12-01)
> 
> * Simplified development doc 'Build and run' instructions [Ken Bannister]
> 

</details>

# v5.0.3
## (2023-11-30)


<details>
<summary> Update balena-supervisor to v15.0.4 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-15.0.4
> ### (2023-11-22)
> 
> * Only build sqlite3 from source [Felipe Lalanne]
> * Update @balena/systemd to 0.5.0 [Christina Ying Wang]
> 
> ## balena-supervisor-15.0.3
> ### (2023-11-22)
> 
> * Cache last reported current state to /mnt/root/tmp [Christina Ying Wang]
> 

</details>

# v5.0.2
## (2023-11-30)

* balena-rollback: If applicable, run device specific healthchecks [Alexandru Costache]

# v5.0.1
## (2023-11-29)

* Make Engine healthcheck performance test aware of device type [Leandro Motta Barros]

# v5.0.0
## (2023-11-28)


<details>
<summary> Update balena-supervisor to v15 [Felipe Lalanne] </summary>

> ## balena-supervisor-15.0.1
> ### (2023-10-25)
> 
> * Expose ports from port mappings on services [Felipe Lalanne]
> 
> ## balena-supervisor-15.0.0
> ### (2023-10-23)
> 
> * Ignore `expose` service compose configuration [Felipe Lalanne]
> 
> ## balena-supervisor-14.13.14
> ### (2023-10-23)
> 
> * Add note regading API jitter on target state poll [Felipe Lalanne]
> 

</details>

# v4.1.11
## (2023-11-27)

* tests: os: safe-reboot: wait for SV to start [rcooke-warwick]

# v4.1.10
## (2023-11-27)


<details>
<summary> Update tests/leviathan digest to c8d2f66 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.18
> ### (2023-11-27)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.17
> ### (2023-11-24)
> 
> * Update core/contracts digest to 9a88055 [Self-hosted Renovate Bot]
> 

</details>

# v4.1.9
## (2023-11-24)

* tests: allow for multiple worker fleets [rcooke-warwick]

# v4.1.8
## (2023-11-22)


<details>
<summary> Update tests/leviathan digest to 935f8ef [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.16
> ### (2023-11-22)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.15
> ### (2023-11-22)
> 
> * Update core/contracts digest to c45079c [Self-hosted Renovate Bot]
> 

</details>

# v4.1.7
## (2023-11-17)

* meta-balena-common: Move code from meta-balena-kirkstone [Florin Sarbu]

# v4.1.6
## (2023-11-17)


<details>
<summary> Update tests/leviathan digest to 30c115d [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.14
> ### (2023-11-15)
> 
> * patch: Add support for local autokit support [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.29.13
> ### (2023-11-13)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.12
> ### (2023-11-13)
> 
> * Update balena-os/leviathan-worker to v2.9.25 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.11
> ### (2023-11-13)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 

</details>

# v4.1.5
## (2023-11-10)

* update-balena-supervisor: ensure target supervisor is running [Alex Gonzalez]
* update-balena-supervisor: use os-helpers logging [Alex Gonzalez]
* hostapp-update: surface logs to journal [Alex Gonzalez]
* hostapp-update-hooks: surface logs to journal [Alex Gonzalez]
* os-helpers-logging: skip logging to journal from a container [Alex Gonzalez]

# v4.1.4
## (2023-11-10)


<details>
<summary> Update tests/leviathan digest to af50e8d [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.10
> ### (2023-11-08)
> 
> * core: remove request timeout on flashing [rcooke-warwick]
> 

</details>

# v4.1.3
## (2023-11-06)


<details>
<summary> Update tests/leviathan digest to 2a64939 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.9
> ### (2023-11-06)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.8
> ### (Invalid date)
> 
> * patch: Update Learn More docs content [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.29.7
> ### (Invalid date)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.6
> ### (2023-10-26)
> 
> * Update core/contracts digest to 1091793 [Self-hosted Renovate Bot]
> 

</details>

# v4.1.2
## (2023-11-01)

* flasher: remove user mode check after programming keys [Joseph Kogut]
* initrdscripts: unlock LUKS partitions only in user mode [Joseph Kogut]
* os-helpers: add secure boot helpers [Joseph Kogut]

# v4.1.1
## (2023-10-25)

* plymouth: Remove --retain-splash flag from plymouth quit [Kyle Harding]

# v4.1.0
## (2023-10-25)

* tests: add safe reboot checks [Alex Gonzalez]
* hostapp-update: move lock checking to helper function [Alex Gonzalez]
* os-helpers-logging: output script logging to journald [Alex Gonzalez]
* os-helpers: add safe_reboot function [Alex Gonzalez]

# v4.0.31
## (2023-10-24)

* Revert "kernel-balena: Remove apparmor support" [Alex Gonzalez]

# v4.0.30
## (2023-10-23)


<details>
<summary> Update tests/leviathan digest to 5a3ce72 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.5
> ### (2023-10-23)
> 
> * Update Lock file maintenance [Self-hosted Renovate Bot]
> 

</details>

# v4.0.29
## (2023-10-23)

* resin-device-progress: Add status code check and error reporting [Alex Gonzalez]

# v4.0.28
## (2023-10-20)


<details>
<summary> Update tests/leviathan digest to cd38f4a [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.4
> ### (2023-10-20)
> 
> * Update core/contracts digest to 42e712d [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.3
> ### (2023-10-19)
> 
> * Update core/contracts digest to 2d44c9c [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.2
> ### (2023-10-19)
> 
> * Update actions/checkout digest to b4ffde6 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.29.1
> ### (2023-10-19)
> 
> * Update core/contracts digest to 97f176d [Self-hosted Renovate Bot]
> 

</details>

# v4.0.27
## (2023-10-18)


<details>
<summary> Update balena-supervisor to v14.13.13 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-14.13.13
> ### (2023-10-16)
> 
> * Switch some _.includes usage to native versions [Pagan Gazzard]
> * Switch _.assign usage to native versions [Pagan Gazzard]
> * Switch _.isNaN usage to native versions [Pagan Gazzard]
> * Switch _.isFunction usage to native versions [Pagan Gazzard]
> * Switch _.isUndefined usage to native versions [Pagan Gazzard]
> * Switch _.isNull usage to native versions [Pagan Gazzard]
> * Switch _.isNumber usage to native versions [Pagan Gazzard]
> * Switch _.isArray usage to native versions [Pagan Gazzard]
> * Switch _.isString usage to native versions [Pagan Gazzard]
> 
> ## balena-supervisor-14.13.12
> ### (2023-10-16)
> 
> * Revert "Do not expose ports from image if service network mode" [Felipe Lalanne]
> 
> ## balena-supervisor-14.13.11
> ### (2023-10-16)
> 
> * Fix husky config for automatic linting on commit [Pagan Gazzard]
> 
> ## balena-supervisor-14.13.10
> ### (2023-10-16)
> 
> * Convert multiple bluebird uses to native promises [Pagan Gazzard]
> 
> ## balena-supervisor-14.13.9
> ### (2023-10-16)
> 
> * Do not expose ports from image if service network mode [Felipe Lalanne]
> 
> ## balena-supervisor-14.13.8
> ### (2023-10-12)
> 
> * Move mdns-resolver to devDependencies [Felipe Lalanne]
> * Move got to devDependencies [Felipe Lalanne]
> * Move semver to dev-dependencies [Felipe Lalanne]
> * Move happy-eyeballs to dev-dependencies [Felipe Lalanne]
> * Move systeminformation to devDependencies [Felipe Lalanne]
> 
> ## balena-supervisor-14.13.7
> ### (2023-10-12)
> 
> * Use mutation for adding service/image ids to logs to reduce allocations [Pagan Gazzard]
> * Keep the container lock for the entire duration of attaching logs [Pagan Gazzard]
> * Remove unnecessary async on handling journald stderr entries [Pagan Gazzard]
> * Avoid unnecessary work in systemd log row handling for invalid logs [Pagan Gazzard]
> 
> ## balena-supervisor-14.13.6
> ### (2023-10-11)
> 
> * Remove unused docker logs logging code [Pagan Gazzard]
> 
> ## balena-supervisor-14.13.5
> ### (2023-10-10)
> 
> * Revert os-release path to /mnt/root [Christina Ying Wang]
> 

</details>

# v4.0.26
## (2023-10-17)


<details>
<summary> Update tests/leviathan digest to 62974d9 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.29.0
> ### (2023-10-16)
> 
> * minor: Add Zip Compression support [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.28.35
> ### (2023-10-16)
> 
> * client: enable searching multiple apps for worker [rcooke-warwick]
> 
> ## leviathan-2.28.34
> ### (2023-10-13)
> 
> * Update core/contracts digest to a06c0cc [Self-hosted Renovate Bot]
> 
> ## leviathan-2.28.33
> ### (2023-10-13)
> 
> * Update balena-os/leviathan-worker to v2.9.24 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.28.32
> ### (2023-10-02)
> 
> * Update core/contracts digest to d68265e [Self-hosted Renovate Bot]
> 

</details>

# v4.0.25
## (2023-10-11)

* Update Pin dependencies [Self-hosted Renovate Bot]

# v4.0.24
## (2023-10-11)

* classes: image_types_balena: do not hardcode path to data image [Alex Gonzalez]

# v4.0.23
## (2023-10-10)

* os-helpers-fs: fix returning multiple matching devices [Joseph Kogut]

# v4.0.22
## (2023-10-09)

* Update tibdex/github-app-token action to v2.1.0 [Self-hosted Renovate Bot]

# v4.0.21
## (2023-10-09)

* Update backports with current 2.112.x [BalenaCI github workflow]

# v4.0.20
## (2023-10-05)

* balena-net-config: Ensure NM dispatcher scripts are executable [Alexandru Costache]

# v4.0.19
## (2023-10-03)

* flowzone: meta-balena-esr: add weekly run to keep workflow enabled [Alex Gonzalez]

# v4.0.18
## (2023-10-03)


<details>
<summary> Update balena-supervisor to v14.13.4 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-14.13.4
> ### (2023-10-02)
> 
> * Add tmpfs for /mnt/root/tmp in test env [Christina Ying Wang]
> 
> ## balena-supervisor-14.13.3
> ### (2023-10-02)
> 
> * Use `~=` to specify alpine package versions [Felipe Lalanne]
> 
> ## balena-supervisor-14.13.2
> ### (Invalid date)
> 
> * Use native structuredClone instead of _.cloneDeep [Christina Ying Wang]
> 
> ## balena-supervisor-14.13.1
> ### (2023-09-28)
> 
> * Update balena-io/deploy-to-balena-action to v1.0.3 [Self-hosted Renovate Bot]
> 
> ## balena-supervisor-14.13.0
> ### (2023-09-28)
> 
> * Update runtime-base image to alpine:3.18 [Christina Ying Wang]
> 

</details>

# v4.0.17
## (2023-10-02)

* workflows: Switch to balenaOS ESR [bot] for authentication [Kyle Harding]

# v4.0.16
## (2023-09-28)


<details>
<summary> Update tests/leviathan digest to 04a53d3 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.28.31
> ### (2023-09-28)
> 
> * Update core/contracts digest to 27ea28b [Self-hosted Renovate Bot]
> 

</details>

# v4.0.15
## (2023-09-27)


<details>
<summary> Update tests/leviathan digest to b4e68c8 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.28.30
> ### (2023-09-25)
> 
> * Update actions/checkout action to v4 [Self-hosted Renovate Bot]
> 

</details>

# v4.0.14
## (2023-09-27)

* patch: Add custom build docs [Vipul Gupta (@vipulgupta2048)]

# v4.0.13
## (2023-09-26)

* balena-rollback: Add support for balena bootloader [Michal Toman]
* hostapp-update-hooks: Add hook for balena bootloader [Michal Toman]
* initrdscripts: add a script that switches between rootA and rootB [Michal Toman]
* initrdscripts: make kexec script more robust [Michal Toman]
* initrdscripts: add missing dependencies to rootfs script [Michal Toman]
* balena-image-bootloader-initramfs: Add balena bootloader [Alex Gonzalez]

# v4.0.12
## (2023-09-25)

* Check if SUPERVISOR_OVERRIDE_LOCK is set [jaomaloy]
* Check and get service lockfiles on HUP reboot [jaomaloy]

# v4.0.11
## (2023-09-21)


<details>
<summary> Update balena-engine to v20.10.40 [Leandro Motta Barros] </summary>

> ## balena-engine-20.10.40
> ### (2023-09-11)
> 
> * Re-vendor to get the containerd-shim-runc-v2 sources [Leandro Motta Barros]
> * Default to io.containerd.runc.v2 [Robert Günzler]
> 

</details>

# v4.0.10
## (2023-09-20)


<details>
<summary> Update balena-supervisor to v14.12.2 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-14.12.2
> ### (2023-09-15)
> 
> * Dump target-state to hostOS tmp dir [jaomaloy]
> 

</details>

# v4.0.9
## (2023-09-15)


<details>
<summary> Update tests/leviathan digest to 397a10f [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.28.29
> ### (2023-09-14)
> 
> * Update balena-os/leviathan-worker to v2.9.23 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.28.28
> ### (2023-09-12)
> 
> * Update balena-os/leviathan-worker to v2.9.22 [Self-hosted Renovate Bot]
> 

</details>

# v4.0.8
## (2023-09-15)

* Enable back ModemManager AT commands through D-Bus and	mmcli [Zahari Petkov]

# v4.0.7
## (2023-09-14)

* Update tibdex/github-app-token action to v2 [Self-hosted Renovate Bot]

# v4.0.6
## (2023-09-13)


<details>
<summary> Update balena-supervisor to v14.12.1 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-14.12.1
> ### (2023-08-21)
> 
> * Bump sqlite3 to 5.1.6 [Felipe Lalanne]
> * Bump knex to v2.5.1 [Felipe Lalanne]
> 

</details>

# v4.0.5
## (2023-09-13)

* tests: os: retry healthcheck disable [rcooke-warwick]

# v4.0.4
## (2023-09-11)

* renovate updates patch only [ab77]

# v4.0.3
## (2023-09-09)


<details>
<summary> Update tests/leviathan digest to 0acfe61 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.28.27
> ### (2023-09-06)
> 
> * Update actions/upload-artifact digest to a8a3f3a [Self-hosted Renovate Bot]
> 
> ## leviathan-2.28.26
> ### (2023-09-04)
> 
> * Update core/contracts digest to 518a1d4 [Self-hosted Renovate Bot]
> 

</details>

# v4.0.2
## (2023-09-08)


<details>
<summary> Update balena-engine to v20.10.39 [Self-hosted Renovate Bot] </summary>

> ## balena-engine-20.10.39
> ### (Invalid date)
> 
> * Don't enable AppArmor if `apparmor_parser` is not present [Leandro Motta Barros]
> 

</details>

# v4.0.1
## (2023-09-08)

* classes: sign: add a retry to the signing call [Alex Gonzalez]

# v4.0.0
## (2023-09-06)

* Update actions/checkout action to v4 [Self-hosted Renovate Bot]

# v3.2.12
## (2023-09-06)

* timesync-https: skip time sync if connectivity URI is null [Alex Gonzalez]
* README: update time in the OS section [Alex Gonzalez]

# v3.2.11
## (2023-09-01)

* Update tibdex/github-app-token action to v1.8.2 [Self-hosted Renovate Bot]

# v3.2.10
## (2023-09-01)

* meta-resin-pyro: do not apply further modemmanager updates [Alex Gonzalez]

# v3.2.9
## (2023-08-31)


<details>
<summary> Update tests/leviathan digest to b353754 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.28.25
> ### (Invalid date)
> 
> * Update balena-os/leviathan-worker to v2.9.21 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.28.24
> ### (Invalid date)
> 
> * Update balena-os/leviathan-worker to v2.9.20 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.28.23
> ### (Invalid date)
> 
> * Update balena-os/leviathan-worker to v2.9.19 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.28.22
> ### (Invalid date)
> 
> * add nocache flash to balena push [rcooke-warwick]
> 
> ## leviathan-2.28.21
> ### (Invalid date)
> 
> * patch: Update client dependencies [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.28.20
> ### (Invalid date)
> 
> * patch: Clarify env variables in Documentation [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.28.19
> ### (Invalid date)
> 
> * patch: Add .nojekyll file to docs [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.28.18
> ### (2023-08-29)
> 
> * patch: Resolve dead links in README [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.28.17
> ### (2023-08-29)
> 
> * Update core/contracts digest to ca46c34 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.28.16
> ### (2023-08-25)
> 
> * Update core/contracts digest to d61d911 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.28.15
> ### (2023-08-25)
> 
> * Update actions/checkout digest to f43a0e5 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.28.14
> ### (2023-08-25)
> 
> * Remove custom automerge rules and use the inherited rules [Kyle Harding]
> 
> ## leviathan-2.28.13
> ### (2023-08-25)
> 
> * patch: Exit GH job if tests fails [Vipul Gupta (@vipulgupta2048)]
> 

</details>

# v3.2.8
## (2023-08-24)

* meta-balena-warrior: modemmanager: use v 1.18.4 [Alex Gonzalez]
* meta-balena-warrior: libmqmi: use v 1.30.2 [Alex Gonzalez]
* meta-balena-warrior: libmbim: use v 1.26.2 [Alex Gonzalez]

# v3.2.7
## (2023-08-24)


<details>
<summary> Update tests/leviathan digest to e7622aa [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.28.12
> ### (2023-08-23)
> 
> * Update balena-os/leviathan-worker to v2.9.18 [Self-hosted Renovate Bot]
> 

</details>

# v3.2.6
## (2023-08-23)

* resin-u-boot.class: Fix for older u-boot versions [Alex Gonzalez]

# v3.2.5
## (2023-08-22)

* contributing-device-support.md: Clarify repo set-up in balenaOS org for private device types [Florin Sarbu]

# v3.2.4
## (2023-08-21)

* tests: cloud: lockfile: change test order [rcooke-warwick]

# v3.2.3
## (2023-08-21)


<details>
<summary> Update tests/leviathan digest to 26e6cea [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.28.11
> ### (2023-08-18)
> 
> * improve autokit quickstart [rcooke-warwick]
> 
> ## leviathan-2.28.10
> ### (2023-08-18)
> 
> * patch: Update suites dependencies to latest [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.28.9
> ### (2023-08-18)
> 
> * patch: Add balenaCloud configurable environments to e2e [Vipul Gupta (@vipulgupta2048)]
> 

</details>

# v3.2.2
## (2023-08-18)

* modemmanager: hold ModemManager 1.14.2 on Thud [Alex Gonzalez]
* meta-balena-thud: libqmi: Use v1.26.0 [Alex Gonzalez]
* meta-balena-thud: libmbim: use v 1.24.2 [Alex Gonzalez]

# v3.2.1
## (2023-08-17)

* meta-balena-thud: adapt migrate module dependencies [Alex Gonzalez]

# v3.2.0
## (2023-08-17)


<details>
<summary> Update balena-supervisor to v14.12.0 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-14.12.0
> ### (2023-08-17)
> 
> * Update README [Felipe Lalanne]
> * Replace node-dbus with @balena/systemd [Felipe Lalanne]
> * Replace dbus test service with mock-systemd-bus [Felipe Lalanne]
> * Update to nodejs 18 [Pagan Gazzard]
> 

</details>

# v3.1.13
## (2023-08-16)

* Integration layers: mobile-broadband-provider: fix fetch failure [Alex Gonzalez]

# v3.1.12
## (2023-08-15)


<details>
<summary> Update balena-supervisor to v14.11.14 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-14.11.14
> ### (2023-08-14)
> 
> * Update balena-io/deploy-to-balena-action to v0.28.0 [Self-hosted Renovate Bot]
> 

</details>

# v3.1.11
## (2023-08-12)


<details>
<summary> Update balena-supervisor to v14.11.13 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-14.11.13
> ### (2023-08-10)
> 
> * patch: Remove reference of override_lock variable [Vipul Gupta]
> 

</details>

# v3.1.10
## (2023-08-12)

* hostapp-update: bind-mount /sys for Jetson efivars [Alexandru Costache]

# v3.1.9
## (2023-08-10)

* tests: secureboot: add test for module signing [Joseph Kogut]

# v3.1.8
## (2023-08-09)

* tests: hup: retry sending image if fails [rcooke-warwick]

# v3.1.7
## (2023-08-08)

* tests: os: eng. healthcheck: retry timeout change [rcooke-warwick]

# v3.1.6
## (2023-08-02)

* resin-init-flasher: Allow background device registration [Michal Toman]

# v3.1.5
## (2023-08-01)

* Reduce scope of app token used for backports and ESR [Kyle Harding]

# v3.1.4
## (2023-07-30)

* kernel-balena: remove mispelled config setting [Alex Gonzalez]

# v3.1.3
## (2023-07-28)

* resin-init-flasher: Install the dispatcher scripts to installation media [Alex Gonzalez]
* balena-net-config: populate the dispatcher bind mount [Alex Gonzalez]
* resin-mounts: add dispatcher.d bind mount [Alex Gonzalez]

# v3.1.2
## (2023-07-27)

* grub-conf: Do not hardcode the path for grub_extraenv [Michal Toman]

# v3.1.1
## (2023-07-26)

* linux/kernel-devsrc: Fix aarch64 kernel-headers-test build [Alexandru Costache]

# v3.1.0
## (2023-07-25)

* linux-firmware: upgrade 20210511 -> 20230404 [Joseph Kogut]
* common: firmware: repackage iwlwifi-quz-a0-hr-b0 [Joseph Kogut]
* common: firmware: repackage iwlwifi-cc-a0 [Joseph Kogut]
* compat: connectivity: drop deprecated iwlwifi files [Joseph Kogut]
* compat: install linux-firmware-iwlwifi-3160 [Joseph Kogut]

# v3.0.17
## (2023-07-25)

* balena-image: Install extra_uEnv for all boards that use u-boot [Alexandru Costache]

# v3.0.16
## (2023-07-22)

* modemmanager: increase qmi port open timeout [Alexandru Costache]
* Update ModemManager to v1.20.6 [Zahari Petkov]

# v3.0.15
## (2023-07-20)

* tests: cloud: sv-timer: account for conn. error [rcooke-warwick]
* tests: cloud: use local ssh for sv timer test [rcooke-warwick]
* tests: cloud: remove preload log check [rcooke-warwick]
* tests: allow for configurable BC env [rcooke-warwick]

# v3.0.14
## (2023-07-20)


<details>
<summary> Update balena-supervisor to v14.11.12 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-14.11.12
> ### (2023-07-19)
> 
> * mount-partitions: do not hardcode partition types [Alex Gonzalez]
> 
> ## balena-supervisor-14.11.11
> ### (2023-07-12)
> 
> * backends: Add Jetson Orin NANO custom device-tree support [Alexandru Costache]
> 

</details>

# v3.0.13
## (2023-07-19)


<details>
<summary> Update tests/leviathan digest to 4e4c1bb [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.28.8
> ### (2023-07-19)
> 
> * Update balena-os/leviathan-worker to v2.9.13 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.28.7
> ### (2023-07-18)
> 
> * update e2e tests to use sshconfig [rcooke-warwick]
> * core: allow configurable ssh target [rcooke-warwick]
> 

</details>

# v3.0.12
## (2023-07-16)

* tests/os: skip boot switch during provisioning [Alexandru Costache]

# v3.0.11
## (2023-07-14)

* .github/workflows: Replace GitHub PAT with ephemeral app tokens [Kyle Harding]

# v3.0.10
## (2023-07-14)

* initrdscripts: make initramfs-module-cryptsetup pull libgcc in [Michal Toman]

# v3.0.9
## (2023-07-13)


<details>
<summary> Update tests/leviathan digest to b1581a2 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.28.6
> ### (2023-07-13)
> 
> * Update balena-os/leviathan-worker to v2.9.12 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.28.5
> ### (2023-07-13)
> 
> * Update balena-os/leviathan-worker to v2.9.11 [Self-hosted Renovate Bot]
> 

</details>

# v3.0.8
## (2023-07-10)


<details>
<summary> Update tests/leviathan digest to e081190 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.28.4
> ### (2023-07-07)
> 
> * Update balena-os/leviathan-worker to v2.9.10 [Self-hosted Renovate Bot]
> 

</details>

# v3.0.7
## (2023-07-06)

* bail out in kexec initramfs hook on failure [Joseph Kogut]

# v3.0.6
## (2023-07-06)

* kernel-devsrc: fix for v6.1+ [Alex Gonzalez]

# v3.0.5
## (2023-07-06)


<details>
<summary> Update balena-supervisor to v14.11.10 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-14.11.10
> ### (2023-07-05)
> 
> * Add revpi-connect-s to Raspberry Pi variants [Florin Sarbu]
> 

</details>

# v3.0.4
## (2023-07-05)


<details>
<summary> Update balena-engine to v20.10.38 [Self-hosted Renovate Bot] </summary>

> ## balena-engine-20.10.38
> ### (2023-07-03)
> 
> * Document a couple of troubleshooting tips [Leandro Motta Barros]
> 

</details>

# v3.0.3
## (2023-07-05)


<details>
<summary> Update balena-supervisor to v14.11.9 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-14.11.9
> ### (2023-06-28)
> 
> * Remove the 'Stopped' status for services [Christina Ying Wang]
> 

</details>

# v3.0.2
## (2023-07-05)


<details>
<summary> Update tests/leviathan digest to 498d4cb [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.28.3
> ### (2023-07-05)
> 
> * Update balena-os/leviathan-worker to v2.9.9 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.28.2
> ### (2023-07-05)
> 
> * Update core/contracts digest to 6e3d563 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.28.1
> ### (2023-07-05)
> 
> * patch: Pass env variables to client [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.28.0
> ### (Invalid date)
> 
> * minor: Make client work with different balenaCloud environments [Vipul Gupta (@vipulgupta2048)]
> 

</details>

# v3.0.1
## (2023-07-04)

* docs: Explain TPM ownership and possible TPM fill-up with secure boot [Michal Toman]
* docs: Recommend BIOS password and no F-key shortcuts with secure boot [Michal Toman]

# v3.0.0
## (2023-07-04)

* mkfs-hostapp-native: Allow the compile task to access the network [Alex Gonzalez]
* mkfs-hostapp-native: Use image tags instead of parsing docker output [Alex Gonzalez]
* kernel-headers-test: Use image tags instead of parsing docker output [Alex Gonzalez]
* kernel-headers-test: Allow network access for compile task [Alex Gonzalez]
* kernel-modules-headers: use kernel-devsrc to provide kernel headers [Alex Gonzalez]

# v2.115.18
## (2023-06-29)

* resin-init-flasher: Increase size of LUKS header to 16MB [Michal Toman]

# v2.115.17
## (2023-06-28)

* balena-keys: add SIGN_KMOD_KEY_APPEND [Joseph Kogut]

# v2.115.16
## (2023-06-28)


<details>
<summary> Update balena-supervisor to v14.11.8 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-14.11.8
> ### (2023-06-23)
> 
> * Parse container exit error message instead of status [Christina W]
> 

</details>

# v2.115.15
## (2023-06-28)


<details>
<summary> Update balena-engine to v20.10.37 [Self-hosted Renovate Bot] </summary>

> ## balena-engine-20.10.37
> ### (2023-06-26)
> 
> * Bugfix: concatReadSeekCloser.Read() with buffers of any size [Leandro Motta Barros]
> * Minor code and comments tweaks [Leandro Motta Barros]
> 

</details>

# v2.115.14
## (2023-06-27)


<details>
<summary> Update tests/leviathan digest to a19d6ef [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.27.9
> ### (2023-06-27)
> 
> * Update balena-os/leviathan-worker to v2.9.8 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.27.8
> ### (2023-06-27)
> 
> * Update core/contracts digest to 6c4386a [Self-hosted Renovate Bot]
> 
> ## leviathan-2.27.7
> ### (2023-06-22)
> 
> * patch: Update QEMU getting started guide [Vipul Gupta (@vipulgupta2048)]
> 

</details>

# v2.115.13
## (2023-06-26)

* os-helpers: Fix os-helpers-api build warnings [Alex Gonzalez]

# v2.115.12
## (2023-06-23)


<details>
<summary> Update balena-supervisor to v14.11.7 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-14.11.7
> ### (2023-06-19)
> 
> * Fix /v2/applications/state endpoint [Felipe Lalanne]
> 
> ## balena-supervisor-14.11.6
> ### (2023-06-19)
> 
> * Add fail-safe to test the image architecture [Felipe Lalanne]
> * Use multi-arch in dockerfile [Felipe Lalanne]
> 
> ## balena-supervisor-14.11.5
> ### (2023-06-19)
> 
> * Improve tests surrounding Engine-host race patch [Christina Ying Wang]
> 
> ## balena-supervisor-14.11.4
> ### (2023-06-19)
> 
> * Specify fs type when mounting partitions to prevent "Can't open blockdev" warnings [Christina Ying Wang]
> 

</details>

# v2.115.11
## (2023-06-21)


<details>
<summary> Update tests/leviathan digest to 09eff9c [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.27.6
> ### (2023-06-19)
> 
> * Update balena-os/leviathan-worker to v2.9.7 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.27.5
> ### (2023-06-19)
> 
> * tests: only do serial file read with testbot [rcooke-warwick]
> * core: enable serial executeCommandinHostOS [rcooke-warwick]
> 
> ## leviathan-2.27.4
> ### (2023-06-16)
> 
> * Update alpine Docker tag to v3.18.2 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.27.3
> ### (2023-06-16)
> 
> * Update core/contracts digest to c777910 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.27.2
> ### (2023-06-16)
> 
> * patch: Revert "minor: Add Leviathan Test Helpers" [Vipul Gupta]
> 
> ## leviathan-2.27.1
> ### (2023-06-09)
> 
> * Update Pin dependencies [Self-hosted Renovate Bot]
> 

</details>

# v2.115.10
## (2023-06-21)

* resin-init-flasher: Format encrypted partitions as LUKS2 [Michal Toman]

# v2.115.9
## (2023-06-15)


<details>
<summary> Update balena-supervisor to v14.11.3 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-14.11.3
> ### (2023-06-15)
> 
> * Update balena-io/deploy-to-balena-action to v0.27.0 [Self-hosted Renovate Bot]
> 

</details>

# v2.115.8
## (2023-06-14)

* balena_check_crc: Add helper u-boot command for crc manipulation [Alexandru Costache]

# v2.115.7
## (2023-06-09)

* README: Add bootloader section [Alexandru Costache]

# v2.115.6
## (2023-06-08)


<details>
<summary> Update tests/leviathan digest to 62e4099 [Self-hosted Renovate Bot] </summary>

> ## leviathan-2.27.0
> ### (2023-05-29)
> 
> * Update alpine Docker tag to v3.18.0 [Self-hosted Renovate Bot]
> 
> ## leviathan-2.26.1
> ### (2023-05-29)
> 
> * Update core/contracts digest to fd4af4e [Self-hosted Renovate Bot]
> 
> ## leviathan-2.26.0
> ### (2023-05-29)
> 
> * Update balena-cli to v16.1.0 with arm64 binaries [Kyle Harding]
> 

</details>

# v2.115.5
## (2023-06-08)


<details>
<summary> Update balena-supervisor to v14.11.2 [Self-hosted Renovate Bot] </summary>

> ## balena-supervisor-14.11.2
> ### (2023-06-05)
> 
> * Handle Engine-host race condition for "always" and "unless-stopped" restart policy [Christina Ying Wang]
> 

</details>

# v2.115.4
## (2023-06-01)

* docs: Make secure boot docs more detailed [Michal Toman]

# v2.115.3
## (2023-05-29)

* resin-init-flasher: check that commands exist before calling [Alex Gonzalez]

# v2.115.2
## (2023-05-28)

* os-helpers: do not fail build if API tests fail [Alex Gonzalez]

# v2.115.1
## (2023-05-17)

* tests: config: set both network options to false [rcooke-warwick]
* tests: hup: use contract to configure network [rcooke-warwick]
* tests: cloud: use contract to configure network [rcooke-warwick]
* tests: os: use contract to configure network [rcooke-warwick]

# v2.115.0
## (2023-05-12)


<details>
<summary> Update balena-supervisor to v14.11.1 [Renovate Bot] </summary>

> ## balena-supervisor-14.11.1
> ### (2023-05-11)
> 
> * Fix `sw.arch` typo when testing contracts [Felipe Lalanne]
> 
> ## balena-supervisor-14.11.0
> ### (2023-05-10)
> 
> * Add `arch.sw` to the valid container requirements [Felipe Lalanne]
> * Allow using slug to validate hw.device-type contract [Felipe Lalanne]
> * Simplify and move lib/contract.spec.ts to tests/unit [Felipe Lalanne]
> 
> ## balena-supervisor-14.10.11
> ### (2023-05-08)
> 
> * Add information about hdmi port 2 config vars [Felipe Lalanne]
> * Update table formatting on configurations.md [Felipe Lalanne]
> 

</details>

# v2.114.25
## (2023-05-12)

* tests: hup: enable boot-switch skip [rcooke-warwick]
* tests: cloud: enable boot-switch skip Commit body [rcooke-warwick]
* tests: os: enable boot-switch skip [rcooke-warwick]

# v2.114.24
## (2023-05-11)

* resin-init-flasher: add more comments around efi/boot partition split [Michal Toman]
* resin-init-flasher: reboot into signed flasher when provisioning secure boot [Michal Toman]
* resin-init-flasher: Fill db EFI variable from esl file instead of auth [Michal Toman]

# v2.114.23
## (2023-05-06)

* tests: suites: remove default migration force configuration [Alex Gonzalez]
* resin-init-flasher: avoid partition labels clashes [Alex Gonzalez]
* initrdscripts: recovery: set adb default timeouts in minutes [Alex Gonzalez]
* tests: move installerForceMigration suite configuration to balenaOS section [Alex Gonzalez]
* tests: simplify accessing config.json data [Alex Gonzalez]

# v2.114.22
## (2023-05-05)


<details>
<summary> Update balena-engine to v20.10.36 [Renovate Bot] </summary>

> ## balena-engine-20.10.36
> ### (2023-05-04)
> 
> * Further improve resilience of image pulls [Leandro Motta Barros]
> 

</details>

# v2.114.21
## (2023-05-05)


<details>
<summary> Update tests/leviathan digest to 256b844 [Renovate Bot] </summary>

> ## leviathan-2.25.6
> ### (2023-05-04)
> 
> * suite: move installer configuration to balenaOS configuration section [Alex Gonzalez]
> 

</details>

# v2.114.20
## (2023-05-04)

* Updated the CDS link [Ryan]

# v2.114.19
## (2023-05-04)


<details>
<summary> Update tests/leviathan digest to e6180e9 [Renovate Bot] </summary>

> ## leviathan-2.25.5
> ### (2023-05-03)
> 
> * Update core/contracts digest to 75cd5e9 [Renovate Bot]
> 
> ## leviathan-2.25.4
> ### (2023-05-01)
> 
> * Update balena-os/leviathan-worker to v2.9.6 [Renovate Bot]
> 
> ## leviathan-2.25.3
> ### (2023-05-01)
> 
> * Update core/contracts digest to 6c6ed28 [Renovate Bot]
> 
> ## leviathan-2.25.2
> ### (2023-04-26)
> 
> * suite: add installerForceMigration configuration [Alex Gonzalez]
> 
> ## leviathan-2.25.1
> ### (2023-04-25)
> 
> * Update balena-os/leviathan-worker to v2.9.4 [Renovate Bot]
> 
> ## leviathan-2.25.0
> ### (2023-04-20)
> 
> * Update Node.js to v18.16.0 [Renovate Bot]
> 
> ## leviathan-2.24.5
> ### (2023-04-20)
> 
> * Update alpine Docker tag to v3.17.3 [Renovate Bot]
> 
> ## leviathan-2.24.4
> ### (2023-04-20)
> 
> * Update core/contracts digest to 777cd35 [Renovate Bot]
> 
> ## leviathan-2.24.3
> ### (2023-04-17)
> 
> * Update balena-os/leviathan-worker to v2.9.2 [Renovate Bot]
> 
> ## leviathan-2.24.2
> ### (2023-04-15)
> 
> * docker-compose-qemu: allow to configure internal disk [Alex Gonzalez]
> 

</details>

# v2.114.18
## (2023-05-03)


<details>
<summary> Update balena-supervisor to v14.10.10 [Renovate Bot] </summary>

> ## balena-supervisor-14.10.10
> ### (2023-05-03)
> 
> * mount-partitions.sh: Add support for encrypted partitions [Michal Toman]
> 
> ## balena-supervisor-14.10.9
> ### (2023-05-03)
> 
> * Run test supervisor under a different service name [Kyle Harding]
> 

</details>

# v2.114.17
## (2023-05-03)

* test: append installer configuration instead of replacing it [Alex Gonzalez]
* test: os: use boolean for installer migration flag [Alex Gonzalez]

# v2.114.16
## (2023-05-02)

* initrdscripts: give the root device a chance to come up before cryptsetup [Michal Toman]

# v2.114.15
## (2023-04-28)

* patch: Add additional logs when logging in using balenaSDK [Vipul Gupta (@vipulgupta2048)]

# v2.114.14
## (2023-04-27)


<details>
<summary> Update balena-supervisor to v14.10.8 [Renovate Bot] </summary>

> ## balena-supervisor-14.10.8
> ### (2023-04-26)
> 
> * Fix service comparison when creating component steps [Felipe Lalanne]
> * Create tests with recovery from #1576 [Felipe Lalanne]
> * Skip updateMetadata step if there are network changes [Felipe Lalanne]
> * Add replication of issue using unit tests [Felipe Lalanne]
> * Add integration tests for state-engine [Felipe Lalanne]
> * Do not pass auth to images with no registry [Felipe Lalanne]
> 

</details>

# v2.114.13
## (2023-04-27)

* hostapp-update-hooks: use unsafe fatrw copy for bootfiles [Alex Gonzalez]
* balena-config-vars: introduce unsafe fatrw copy [Alex Gonzalez]

# v2.114.12
## (2023-04-26)

* classes: kernel-balena: force recompilation if signing variables change [Alex Gonzalez]
* balena-keys: make tasks depends on signing variables [Alex Gonzalez]
* classes: sign: make signing task depends on signing variables [Alex Gonzalez]

# v2.114.11
## (2023-04-24)


<details>
<summary> Update balena-engine to v20.10.35 [Renovate Bot] </summary>

> ## balena-engine-20.10.35
> ### (2023-04-24)
> 
> * Update libnetwork to fix port binding issue [Leandro Motta Barros]
> 

</details>

# v2.114.10
## (2023-04-24)

* mkfs-hostapp-native: Update base image in Dockerfile [Alexandru Costache]

# v2.114.9
## (2023-04-22)

* tests: os: configure to use installer's migrator [Alex Gonzalez]
* test: os: add installer migration test [Alex Gonzalez]

# v2.114.8
## (2023-04-22)


<details>
<summary> Update balena-supervisor to v14.10.7 [Renovate Bot] </summary>

> ## balena-supervisor-14.10.7
> ### (2023-04-21)
> 
> * Remove safeStateClone function [Felipe Lalanne]
> * Get rid of targetVolatile in app manager [Felipe Lalanne]
> * Make pausingApply a private member of device-state [Felipe Lalanne]
> * Simplify doRestart and doPurge actions [Felipe Lalanne]
> * Fix network appUuid inference in local mode [Felipe Lalanne]
> * Get image name from DB when getting the app current state [Felipe Lalanne]
> * Improve net alias comparison to prevent unwanted restarts [Felipe Lalanne]
> * Exclude containerId from service network aliases [Felipe Lalanne]
> * Skip image delete when applying intermediate state [Felipe Lalanne]
> * Make local mode image management work as in cloud mode [Felipe Lalanne]
> * Remove ignoreImages argument from getRequiredSteps [Felipe Lalanne]
> 

</details>

# v2.114.7
## (2023-04-20)


<details>
<summary> Update balena-supervisor to v14.10.6 [Renovate Bot] </summary>

> ## balena-supervisor-14.10.6
> ### (2023-04-20)
> 
> * Do not restart balena-hostname on rename [Felipe Lalanne]
> 
> ## balena-supervisor-14.10.5
> ### (2023-04-13)
> 
> * Remove anonymous build volume from Dockerfile [Christina Ying Wang]
> 

</details>

# v2.114.6
## (2023-04-20)

* Update db and dbx hashes during HUP when secure boot is enabled [Michal Toman]
* balena-db-hashes: ship both db and dbx updates [Michal Toman]
* Use hashes instead of certificates for secure boot image validation [Michal Toman]

# v2.114.5
## (2023-04-19)

* Ship separate GRUB images for secure boot [Michal Toman]

# v2.114.4
## (2023-04-18)

* initedscripts: recovery: do not use strings for timeout [Alex Gonzalez]
* resin-init-flasher: limit boot device identification to booting disk [Alex Gonzalez]
* resin-init-flasher: add verbose copy of migration log [Alex Gonzalez]
* resin-init-flasher: fix EFI installation for multiple disks [Alex Gonzalez]
* initrdscripts: migrate: correctly identify boot device [Alex Gonzalez]
* distro: balena-os: update GRUB key id for signature [Alex Gonzalez]

# v2.114.3
## (2023-04-12)


<details>
<summary> Update balena-supervisor to v14.10.4 [Renovate Bot] </summary>

> ## balena-supervisor-14.10.4
> ### (2023-04-10)
> 
> * Log uncaught promise exceptions on the app entry [Felipe Lalanne]
> 
> ## balena-supervisor-14.10.3
> ### (2023-04-10)
> 
> * Fix assertion error in restart-service [Christina Ying Wang]
> 

</details>

# v2.114.2
## (2023-04-12)

* tests: cloud: convert ssh tunneling to test [rcooke-warwick]
* tests: hup: convert ssh tunneling to test [rcooke-warwick]
* tests: os: convert ssh tunneling to test [rcooke-warwick]
* tests: cloud: check engine+sv ok in suite [rcooke-warwick]
* tests: os: check engine+sv ok in suite [rcooke-warwick]
* tests:cloud: convert initial SSH attempt into test [rcooke-warwick]
* tests: hup: convert initial SSH attempt into test [rcooke-warwick]
* tests: os: convert initial SSH attempt into test [rcooke-warwick]

# v2.114.1
## (2023-04-07)


<details>
<summary> Update balena-supervisor to v14.10.2 [Renovate Bot] </summary>

> ## balena-supervisor-14.10.2
> ### (2023-04-07)
> 
> * backends: Add Jetson Orin NX custom device-tree support [Alexandru Costache]
> 

</details>

# v2.114.0
## (2023-04-07)


<details>
<summary> Update balena-supervisor to v14.10.1 [Renovate Bot] </summary>

> ## balena-supervisor-14.10.1
> ### (2023-04-07)
> 
> * Use dbus-send to get current boot block device instead of fdisk [Christina Ying Wang]
> 
> ## balena-supervisor-14.10.0
> ### (2023-03-28)
> 
> * Mount boot partition into container on Supervisor start [Christina Ying Wang]
> 

</details>

# v2.113.35
## (2023-04-05)


<details>
<summary> Update balena-engine to v20.10.34 [Renovate Bot] </summary>

> ## balena-engine-20.10.34
> ### (2023-04-05)
> 
> * Update librsync-go to v0.8.5, circbuf to v0.1.3 [Leandro Motta Barros]
> 

</details>

# v2.113.34
## (2023-04-04)


<details>
<summary> Update tests/leviathan digest to 5785e44 [Renovate Bot] </summary>

> ## leviathan-2.24.1
> ### (2023-04-04)
> 
> * Deprecate worker release env var (again) [Kyle Harding]
> 
> ## leviathan-2.24.0
> ### (2023-04-03)
> 
> * minor: Add Leviathan Test Helpers [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.23.6
> ### (2023-04-01)
> 
> * patch: Output final-result in the end [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.23.5
> ### (2023-04-01)
> 
> * update default worker version [rcooke-warwick]
> 
> ## leviathan-2.23.4
> ### (2023-03-29)
> 
> * swtpm: store state in tmpfs [Joseph Kogut]
> 
> ## leviathan-2.23.3
> ### (2023-03-29)
> 
> * Update core/contracts digest to fa51fae [Renovate Bot]
> 

</details>

# v2.113.33
## (2023-03-28)


<details>
<summary> Update tests/leviathan digest to e5dcbae [Renovate Bot] </summary>

> ## leviathan-2.23.2
> ### (2023-03-28)
> 
> * patch: Update path to balena-io/renovate-config [Kyle Harding]
> 

</details>

# v2.113.32
## (2023-03-28)

* renovate: Inherit automerge settings from org [Kyle Harding]

# v2.113.31
## (2023-03-28)

* Don't create core dumps in containers by default [Leandro Motta Barros]
* Make sure balenaEngine owns the container cgroups [Leandro Motta Barros]

# v2.113.30
## (2023-03-27)


<details>
<summary> Update balena-engine to v20.10.33 [Renovate Bot] </summary>

> ## balena-engine-20.10.33
> ### (2023-03-27)
> 
> * Add integration tests for balena's "delta on load" [Leandro Motta Barros]
> * Simplify and improve delta error handling [Leandro Motta Barros]
> * Refactor the xfer portions of delta [Leandro Motta Barros]
> * Refactor the distribution portions of delta [Leandro Motta Barros]
> 

</details>

# v2.113.29
## (2023-03-27)


<details>
<summary> Update balena-supervisor to v14.9.8 [Renovate Bot] </summary>

> ## balena-supervisor-14.9.8
> ### (2023-03-27)
> 
> * Revert "Use multi-arch in dockerfile" [Felipe Lalanne]
> 

</details>

# v2.113.28
## (2023-03-27)

* README: modify migration documentation to match module [Alex Gonzalez]

# v2.113.27
## (2023-03-24)


<details>
<summary> Update balena-supervisor to v14.9.7 [Renovate Bot] </summary>

> ## balena-supervisor-14.9.7
> ### (2023-03-23)
> 
> * Add missing log backend field assignment in logger init [Christina Ying Wang]
> 
> ## balena-supervisor-14.9.6
> ### (2023-03-23)
> 
> * Update deploy-to-balena action to 0.26.2 [Felipe Lalanne]
> * Use multi-arch in dockerfile [Felipe Lalanne]
> 
> ## balena-supervisor-14.9.5
> ### (2023-03-20)
> 
> * Use log endpoint subdomain if it exists in config.json [Christina Ying Wang]
> 

</details>

# v2.113.26
## (2023-03-23)


<details>
<summary> Update balena-engine to v20.10.32 [Renovate Bot] </summary>

> ## balena-engine-20.10.32
> ### (2023-03-21)
> 
> * Installer: Make the script POSIX-compliant [Leandro Motta Barros]
> * Installer: Improve handling of su/sudo [Leandro Motta Barros]
> * Installer: Improve checking for dependencies [Leandro Motta Barros]
> * Installer: remove support for the 386 architecture [Leandro Motta Barros]
> * Remove the installation script from docs/ [Leandro Motta Barros]
> 
> ## balena-engine-20.10.31
> ### (2023-03-20)
> 
> * Remove references to deprecated build targets [Kyle Harding]
> * Revert "Cross-build the dynbinary target" [Kyle Harding]
> 
> ## balena-engine-20.10.30
> ### (2023-03-13)
> 
> * Fix typos in the masterclass docs [Leandro Motta Barros]
> * patch: Migrate balenaEngine Debugging docs from masterclass [Vipul Gupta (@vipulgupta2048)]
> 
> ## balena-engine-20.10.29
> ### (2023-02-20)
> 
> * Rename test functions for better clarity [Leandro Motta Barros]
> * Add test case for the delta image store [Leandro Motta Barros]
> * Add dev-focused docs on some balenaEngine features [Leandro Motta Barros]
> * Simplify test code by using new std lib function [Leandro Motta Barros]
> * Set the delta image store, fix delta-based HUPs [Leandro Motta Barros]
> 
> ## balena-engine-20.10.28
> ### (2023-02-20)
> 
> * Disable builds for linux/386 [Leandro Motta Barros]
> 
> ## balena-engine-20.10.27
> ### (2023-02-07)
> 
> * Merge upstream v20.10.17 [Leandro Motta Barros]
> 

</details>

# v2.113.25
## (2023-03-23)

* kernel-balena: Include NFS V2, V3 and V4 client and server modules [Alexandru Costache]

# v2.113.24
## (2023-03-22)

* dunfell+: remove obsolete systemd patch [Joseph Kogut]
* plymouth: replace duplicated patches w/ shared drop-ins [Joseph Kogut]
* systemd: mask systemd-getty-generator instead of patching [Joseph Kogut]
* systemd: replace duplicated patch w/ shared drop-ins [Joseph Kogut]

# v2.113.23
## (2023-03-22)

* pyro/sumo: initrdscripts: fix migrate module for older Yocto versions [Alex Gonzalez]
* networkmanager: do not update to latest version in sumo [Alex Gonzalez]

# v2.113.22
## (2023-03-21)


<details>
<summary> Update tests/leviathan digest to ad4f908 [Renovate Bot] </summary>

> ## leviathan-2.23.1
> ### (2023-03-14)
> 
> * compose: qemu: add FLASHER_SECUREBOOT var [Joseph Kogut]
> * swtpm: fix abort on exit [Joseph Kogut]
> 

</details>

# v2.113.21
## (2023-03-20)

* tests: os: secureboot: add integrity checks [Joseph Kogut]
* tests: configure flasher secure boot opt-in [Joseph Kogut]

# v2.113.20
## (2023-03-20)

* tests: os: disable unwrapping [Joseph Kogut]
* tests: hup: disable unwrapping [Joseph Kogut]
* tests: cloud: disable unwrapping [Joseph Kogut]

# v2.113.19
## (2023-03-20)

* resin-u-boot.bbclass: Default to u-boot Kconfig support [Florin Sarbu]

# v2.113.18
## (2023-03-16)

* Enable CI for external contributions from forks [Kyle Harding]

# v2.113.17
## (2023-03-16)

* Removed links to hub [Ryan H]

# v2.113.16
## (2023-03-16)

* balena-image-flasher: Default image type to balenaos-img [Florin Sarbu]

# v2.113.15
## (2023-03-16)

* resin-u-boot.bbclass: Replace static patch resin-specific-env-integration-kconfig.patch [Florin Sarbu]

# v2.113.14
## (2023-03-15)


<details>
<summary> Update balena-supervisor to v14.9.4 [Renovate Bot] </summary>

> ## balena-supervisor-14.9.4
> ### (2023-03-13)
> 
> * Skip pin device step if release was deleted [Felipe Lalanne]
> 
> ## balena-supervisor-14.9.3
> ### (2023-03-10)
> 
> * Use single-arch in dockerfile [Felipe Lalanne]
> 
> ## balena-supervisor-14.9.2
> ### (2023-03-02)
> 
> * Replace BALENA-FIREWALL rule in INPUT chain instead of flushing [Christina Ying Wang]
> 

</details>

# v2.113.13
## (2023-03-15)

* update-balena-supervisor: use API request helper [Alex Gonzalez]
* os-helpers: add test for os-helpers-api [Alex Gonzalez]
* os-helpers: add os-helpers-api [Alex Gonzalez]

# v2.113.12
## (2023-03-14)

* Remove a bad check in Internet connection sharing test [Zahari Petkov]

# v2.113.11
## (2023-03-14)

* peak: Ship signed module when signing is enabled [Michal Toman]

# v2.113.10
## (2023-03-09)

* patch: Add balenaOS debugging docs [Vipul Gupta (@vipulgupta2048)]

# v2.113.9
## (2023-03-09)

* flasher: fix installation when in user mode w/ sb disabled [Joseph Kogut]

# v2.113.8
## (2023-03-08)

* fix ip for dummy interface to avoid ip conflicts [rcooke-warwick]
* tests: os: NetworkManager iptables rules test for Internet sharing [Zahari Petkov]

# v2.113.7
## (2023-03-07)

* conf: distro: balena-os: use lower case for signing key names [Alex Gonzalez]

# v2.113.6
## (2023-03-07)

* recipes-core/images: Ensure redsocks sample files are deployed [Alexandru Costache]

# v2.113.5
## (2023-03-07)

* image-balena.bbclass: deploy grub-conf before building the boot partition [Michal Toman]

# v2.113.4
## (2023-03-03)

* balena-keys: do not ship certificates in DER format [Michal Toman]

# v2.113.3
## (2023-03-02)

* balena-units-conf: launch os-config on config changes [Alex Gonzalez]

# v2.113.2
## (2023-03-02)

* Refer to balenaEngine by its full name [Leandro Motta Barros]

# v2.113.1
## (2023-02-28)

* os-helpers-fs: formatting and fixing lint warning [Alex Gonzalez]
* os-helpers-fs: fix check for media attached [Alex Gonzalez]
* initrdscripts: migrate: use du instead of wc to calculate byte sizes [Alex Gonzalez]

# v2.113.0
## (2023-02-25)

* resin-init-flasher: use logging helper [Alex Gonzalez]
* resin-init-flasher: replace shutdown for reboot in case of migration [Alex Gonzalez]
* README: add installer section [Alex Gonzalez]
* initrdscripts: Add migration module [Alex Gonzalez]
* integration layers: use `android-tools` from Yocto Dunfell and before [Alex Gonzalez]
* resin-init-flasher: comply with recovery mode [Alex Gonzalez]
* initrdscritps: Move moving /run mountpoint from rootfs to migrate module [Alex Gonzalez]
* initrdscripts: add recovery module [Alex Gonzalez]

# v2.112.15
## (2023-02-24)

* os-helpers-fs: add dependency on util-linux fdisk [Alex Gonzalez]

# v2.112.14
## (2023-02-22)

* balena-config-vars: Remove dependency on fatrw [Alex Gonzalez]
* balena-config-vars: split in two packages [Alex Gonzalez]
* Add raid support based on machine features [Alex Gonzalez]
* packagegroup-resin: add resin-device-progress dependency [Alex Gonzalez]
* resin-init-flasher: remove device-register and device-progress dependencies [Alex Gonzalez]
* resin-init-flasher: reduce dependencies [Alex Gonzalez]
* os-helpers-fs: replace inform with info helper [Alex Gonzalez]
* resin-init-flasher: Build time check on INTERNAL_DEVICE_KERNEL only for flasher device types [Alex Gonzalez]
* resin-init-flasher: wait for the by-label links to be created [Alex Gonzalez]

# v2.112.13
## (2023-02-22)

* recipes-bsp/u-boot: Disable saveenv shell command [Alexandru Costache]
* Update tests/leviathan digest to 771bac8 [Renovate Bot]

# v2.112.12
## (2023-02-20)

* os-helpers-fs: get_internal_device() skip disks w/out media [Joseph Kogut]

# v2.112.11
## (2023-02-20)


<details>
<summary> Update tests/leviathan digest to 84c2b96 [Renovate Bot] </summary>

> ## leviathan-2.22.0
> ### (2023-02-20)
> 
> * Update core/contracts digest to 93ba80c [Renovate Bot]
> 

</details>

# v2.112.10
## (2023-02-20)

* tests: os: secureboot: skip if system is not locked down [Joseph Kogut]

# v2.112.9
## (2023-02-20)


<details>
<summary> Update tests/leviathan digest to 8a7bdcc [Renovate Bot] </summary>

> ## leviathan-2.21.0
> ### (2023-02-20)
> 
> * Update core/contracts digest to 103037c [Renovate Bot]
> 
> ## leviathan-2.20.1
> ### (2023-02-20)
> 
> * client: throw errors instead of blanket handling [Joseph Kogut]
> 

</details>

# v2.112.8
## (2023-02-17)


<details>
<summary> Update balena-supervisor to v14.9.1 [Renovate Bot] </summary>

> ## balena-supervisor-14.9.1
> ### (2023-02-15)
> 
> * Always lower case the cpu id to avoid bouncing between casing when reporting [Pagan Gazzard]
> 

</details>

# v2.112.7
## (2023-02-16)

* renovate: Only consider github releases when bumping engine [Kyle Harding]

# v2.112.6
## (2023-02-16)


<details>
<summary> Update tests/leviathan digest to 92cb71a [Renovate Bot] </summary>

> ## leviathan-2.20.0
> ### (2023-02-16)
> 
> * Update core/contracts digest to 9b8811f [Renovate Bot]
> 
> ## leviathan-2.19.2
> ### (2023-02-15)
> 
> * patch: Improve Getting Started instructions [Vipul Gupta (@vipulgupta2048)]
> 

</details>

# v2.112.5
## (2023-02-16)

* grub: Add chain module to support multiboot [Alex Gonzalez]

# v2.112.4
## (2023-02-15)

* Update backports with current 2.102.x [BalenaCI github workflow]

# v2.112.3
## (2023-02-15)

* workflows: update-backports: remove skipping tests [Alex Gonzalez]

# v2.112.2
## (2023-02-15)

* workflows: add update-backports [Alex Gonzalez]

# v2.112.1
## (2023-02-15)

* Update aufs5 kernel patches for 5.10 versions [Florin Sarbu]

# v2.112.0
## (2023-02-14)


<details>
<summary> Update balena-supervisor to v14.9.0 [Renovate Bot] </summary>

> ## balena-supervisor-14.9.0
> ### (2023-02-14)
> 
> * Find and remove duplicate networks [Felipe Lalanne]
> * Reference networks by Id instead of by name [Felipe Lalanne]
> 

</details>

# v2.111.4
## (2023-02-14)

* tests: hup: fix flashing for tx2 [rcooke-warwick]

# v2.111.3
## (2023-02-14)


<details>
<summary> Update tests/leviathan digest to 975e8ca [Renovate Bot] </summary>

> ## leviathan-2.19.1
> ### (2023-02-14)
> 
> * docker-compose: qemu: remove dep on swtpm [Joseph Kogut]
> 

</details>

# v2.111.2
## (2023-02-13)

* docs: add section for sb/fde opt-in [Joseph Kogut]

# v2.111.1
## (2023-02-13)

* resin-init-flasher: do not report progress if unprovisioned [Alex Gonzalez]
* resin-init-flasher: check splash configuration exists before copying [Alex Gonzalez]
* resin-init-flasher: Move configuration data definitions to config file [Alex Gonzalez]

# v2.111.0
## (2023-02-11)


<details>
<summary> Update balena-supervisor to v14.8.0 [Renovate Bot] </summary>

> ## balena-supervisor-14.8.0
> ### (2023-02-10)
> 
> * Remove dependent devices content in codebase [Christina Ying Wang]
> 

</details>

# v2.110.4
## (2023-02-10)


<details>
<summary> Update tests/leviathan digest to 589449d [Renovate Bot] </summary>

> ## leviathan-2.19.0
> ### (2023-02-10)
> 
> * Update core/contracts digest to 35f4223 [Renovate Bot]
> 

</details>

# v2.110.3
## (2023-02-09)

* os-helpers: remove shebangs as these are not meant to be executed [Alex Gonzalez]
* resindataexpander: Fix formatting [Alex Gonzalez]
* resin-init-flasher: Extract code that resolved internal device [Alex Gonzalez]
* os-helpers-fs: Add shared code from resin-init-flasher [Alex Gonzalez]
* resin-init-flasher: remove unused variable [Alex Gonzalez]
* resin-init-flasher: Use the default for the external boot partition mount [Alex Gonzalez]
* resin-init-flasher: search for images to copy instead of hardcoding paths [Alex Gonzalez]
* resin-init-flasher: Do not  hardcode the path to the internal boot device [Alex Gonzalez]
* resin-init-flasher: remove systemd dependency [Alex Gonzalez]
* resin-init-flasher: Do not hardcode path to the raw image [Alex Gonzalez]
* initrdscript: prepare: expose path to initramfs logs [Alex Gonzalez]
* initrdscript: resindataexpander: skip for flasher images [Alex Gonzalez]
* docs: add initramfs overview [Alex Gonzalez]

# v2.110.2
## (2023-02-07)


<details>
<summary> Update tests/leviathan digest to 4f63a2d [Renovate Bot] </summary>

> ## leviathan-2.18.1
> ### (2023-02-07)
> 
> * patch: Automate docs deployment with Flowzone [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.18.0
> ### (2023-02-07)
> 
> * Update core/contracts digest to 7797750 [Renovate Bot]
> 
> ## leviathan-2.17.6
> ### (2023-02-07)
> 
> * patch: Update client lockfile [Vipul Gupta (@vipulgupta2048)]
> * patch: Update core lockfile [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.17.5
> ### (2023-02-06)
> 
> * patch: Update core dependencies [Vipul Gupta (@vipulgupta2048)]
> 

</details>

# v2.110.1
## (2023-02-07)

* renovate: Include to and from versions for supervisor and engine [Kyle Harding]

# v2.110.0
## (2023-02-07)

* Update balena-supervisor to v14.7.1 [Renovate Bot]

# v2.109.2
## (2023-02-07)

* efitools: backport patch to fix build failure [Joseph Kogut]
* efitools: fix cross-compilation on arm [Joseph Kogut]
* Only include EFI tools if the machine feature is defined [Alex Gonzalez]

# v2.109.1
## (2023-02-06)

* resin-extra-udev-rules: Remove after all device types have been updated [Alex Gonzalez]

# v2.109.0
## (2023-02-05)

* kernel-balena: Remove apparmor support [Alex Gonzalez]

# v2.108.39
## (2023-02-03)

* flasher: handle user mode system w/out secure boot [Joseph Kogut]
* flasher: fix keys not enrolling with secure boot enabled [Joseph Kogut]
* flasher: fix secure boot setup with enrolled keys [Joseph Kogut]

# v2.108.38
## (2023-02-03)


<details>
<summary> Update leviathan to v2.17.4 [Kyle Harding] </summary>

> ## leviathan-2.17.4
> ### (2023-01-28)
> 
> * patch: Upgrade client to v18 [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.17.3
> ### (2023-01-26)
> 
> * patch: Update client dependencies [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.17.2
> ### (2023-01-19)
> 
> * chore(deps): update alpine docker tag to v3.17.1 [renovate[bot]]
> 
> ## leviathan-2.17.1
> ### (2023-01-19)
> 
> * patch: Convert balenaCloudInteractor to JS [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.17.0
> ### (2023-01-19)
> 
> * chore(deps): update dependency json5 [security] [renovate[bot]]
> 
> ## leviathan-2.16.1
> ### (2023-01-19)
> 
> * split swtpm service into separate compose file [Joseph Kogut]
> 
> ## leviathan-2.16.0
> ### (2023-01-18)
> 
> * chore(deps): update core/contracts digest to 8392bb2 [renovate[bot]]
> 
> ## leviathan-2.15.1
> ### (2023-01-17)
> 
> * patch: Drop config NPM package [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.15.0
> ### (2023-01-14)
> 
> * chore(deps): update dependency ansi-regex [security] [renovate[bot]]
> 
> ## leviathan-2.14.9
> ### (2023-01-05)
> 
> * compose: qemu: add swtpm service [Joseph Kogut]
> 

</details>

# v2.108.37
## (2023-02-02)

* Update balena-engine to v20.10.26 [Renovate Bot]

# v2.108.36
## (2023-02-02)

* flasher: remove duplicate EFI boot entries [Joseph Kogut]
* flasher: create EFI boot entry [Joseph Kogut]
* common: os-helpers-fs: fix get_dev_path_from_label w/ luks [Joseph Kogut]
* flasher: make secure boot opt-in [Joseph Kogut]
* flasher: ensure image is signed before enrollment [Joseph Kogut]
* flasher: refactor secure boot block [Joseph Kogut]

# v2.108.35
## (2023-02-01)

* renovate: Add regex manager for balena-engine [Kyle Harding]

# v2.108.34
## (2023-02-01)

* docs: Add secure boot and disk encryption overview [Alex Gonzalez]
* hostapp-update-hooks: Fail if new keys are used [Alex Gonzalez]
* resin-init-flasher: In setupmode program new keys [Alex Gonzalez]

# v2.108.33
## (2023-01-31)

* tests: os: skip persistent logging test for pi0 [rcooke-warwick]

# v2.108.32
## (2023-01-31)

* efitools: Allow builds for ARM architecture [Alex Gonzalez]

# v2.108.31
## (2023-01-31)

* rollback-health: bind-mount EFI partition when split from boot [Michal Toman]

# v2.108.30
## (2023-01-30)

* redsocks: Deploy README and sample configration file [Alexandru Costache]
* recipes-bsp/u-boot: Import extra uboot environment from scanned devices [Alexandru Costache]

# v2.108.29
## (2023-01-28)

* bluez: Update to v5.66 [Alex Gonzalez]

# v2.108.28
## (2023-01-26)

* patch: Update balenaOS docs title [Vipul Gupta (@vipulgupta2048)]

# v2.108.27
## (2023-01-20)

* tests: os: fix tests that use glider on rpi0 [rcooke-warwick]

# v2.108.26
## (2023-01-20)

* Enable back connectivity check in NetworkManager [Zahari Petkov]

# v2.108.25
## (2023-01-18)

* tests: os: add basic SB/FDE tests [Joseph Kogut]

# v2.108.24
## (2023-01-18)

* networkmanager: Make iptables wait for xtables.lock [Zahari Petkov]

# v2.108.23
## (2023-01-16)

* balena-keys: rebuild if keys change [Alex Gonzalez]
* classes: sign-*: resign if keys change [Alex Gonzalez]

# v2.108.22
## (2023-01-16)

* workflows: esr: use semver compatible versions [Alex Gonzalez]

# v2.108.21
## (2023-01-14)

* efitools: Package lock down EFI image into its own package [Alex Gonzalez]

# v2.108.20
## (2023-01-12)

* workflows: meta-balena-esr: Fix version calculation [Alex Gonzalez]

# v2.108.19
## (2023-01-10)

* redsocks: Increase maximum number of open files [Alex Gonzalez]

# v2.108.18
## (2023-01-09)

* Revert "flasher: output logs to serial console" [Joseph Kogut]

# v2.108.17
## (2023-01-09)

* Update balena-os/balena-supervisor to v14.4.10 [renovate[bot]]

# v2.108.16
## (2023-01-09)

* balena-supervisor: Set the supervisor package version [Kyle Harding]

# v2.108.15
## (2023-01-05)


<details>
<summary> Update tests/leviathan digest to e23c1bb [renovate[bot]] </summary>

> ## leviathan-2.14.8
> ### (2023-01-05)
> 
> * chore(deps): update dependency eslint-config-standard to 17.0.0 [renovate[bot]]
> 
> ## leviathan-2.14.7
> ### (2023-01-05)
> 
> * worker: Deprecate the WORKER_RELEASE env var [Kyle Harding]
> 
> ## leviathan-2.14.6
> ### (2023-01-05)
> 
> * e2e: Switch from rpi4 to rpi3 for e2e tests [Kyle Harding]
> * core: Increase the default timeout for worker connections to 30s [Kyle Harding]
> 
> ## leviathan-2.14.5
> ### (2023-01-04)
> 
> * renovate: Disable automerge for major and minor updates [Kyle Harding]
> 
> ## leviathan-2.14.4
> ### (2023-01-04)
> 
> * chore(deps): update dependency typedoc to 0.23.23 [renovate[bot]]
> 

</details>

# v2.108.14
## (2023-01-04)

* tests: os: chrony: disable NTP w/ dnsmasq dbus API [Joseph Kogut]

# v2.108.13
## (2023-01-04)


<details>
<summary> Update tests/leviathan digest to 44dceb4 [renovate[bot]] </summary>

> ## leviathan-2.14.3
> ### (2023-01-04)
> 
> * chore(deps): update dependency eslint to 8.31.0 [renovate[bot]]
> 

</details>


<details>
<summary> Update tests/leviathan digest to 4383482 [renovate[bot]] </summary>

> ## leviathan-2.14.3
> ### (2023-01-04)
> 
> * chore(deps): update dependency eslint to 8.31.0 [renovate[bot]]
> 

</details>

# v2.108.12
## (2023-01-04)

* tests/hup: Avoid an old engine bug when pulling multiarch images on rpi [Kyle Harding]

# v2.108.11
## (2023-01-03)


<details>
<summary> Update tests/leviathan digest to d3485ab [renovate[bot]] </summary>

> ## leviathan-2.13.0
> ### (2023-01-03)
> 
> * Revert "minor: Add @balena/leviathan-test-helpers package" [Kyle Harding]
> 
> ## leviathan-2.12.4
> ### (Invalid date)
> 
> * chore(deps): update dependency eslint-plugin-standard to 4.1.0 [renovate[bot]]
> 

</details>

# v2.108.10
## (2022-12-30)


<details>
<summary> Update tests/leviathan digest to 7d6326d [renovate[bot]] </summary>

> ## leviathan-2.12.3
> ### (Invalid date)
> 
> * chore(deps): update dependency eslint-plugin-node to 11.1.0 [renovate[bot]]
> 
> ## leviathan-2.12.2
> ### (2022-12-29)
> 
> * Run out-of-band e2e tests after Flowzone passes [Kyle Harding]
> 
> ## leviathan-2.12.1
> ### (2022-12-29)
> 
> * chore(deps): update dependency eslint-plugin-jsdoc to 39.6.4 [renovate[bot]]
> 
> ## leviathan-2.12.0
> ### (2022-12-29)
> 
> * chore(deps): update core/contracts digest to 4698e4e [renovate[bot]]
> 
> ## leviathan-2.11.9
> ### (2022-12-29)
> 
> * chore(deps): update dependency balena-os/leviathan-worker to 2.6.13 [renovate[bot]]
> 

</details>

# v2.108.9
## (2022-12-29)


<details>
<summary> Update tests/leviathan digest to 1dcb432 [renovate[bot]] </summary>

> ## leviathan-2.11.8
> ### (2022-12-28)
> 
> * chore(deps): update dependency eslint-config-prettier to 8.5.0 [renovate[bot]]
> 

</details>

# v2.108.8
## (2022-12-28)


<details>
<summary> Update tests/leviathan digest to e09fae4 [renovate[bot]] </summary>

> ## leviathan-2.11.7
> ### (2022-12-28)
> 
> * renovate: Remove v prefix from leviathan-worker github-tags [Kyle Harding]
> 

</details>

# v2.108.7
## (2022-12-28)

* tests: os: fix modem test teardown [rcooke-warwick]

# v2.108.6
## (2022-12-27)

* flasher: output logs to serial console [Joseph Kogut]

# v2.108.5
## (2022-12-21)

* Engine healthcheck: deal with empty uuid file [Leandro Motta Barros]

# v2.108.4
## (2022-12-20)

* distro: For OS development, enable serial console [Alex Gonzalez]

# v2.108.3
## (2022-12-20)


<details>
<summary> Update tests/leviathan digest to f06d285 [renovate[bot]] </summary>

> ## leviathan-2.11.6
> ### (2022-12-16)
> 
> * Fix renovate extends syntax to include balena-io config [Kyle Harding]
> 
> ## leviathan-2.11.5
> ### (2022-12-16)
> 
> * renovate: Inherit settings from balena-io/renovate-config [Kyle Harding]
> 
> ## leviathan-2.11.4
> ### (2022-12-16)
> 
> * add logging and timeout to balena push [rcooke-warwick]
> 

</details>

# v2.108.2
## (2022-12-19)

* Update balena-os/balena-supervisor to v14.4.9 [renovate[bot]]

# v2.108.1
## (2022-12-18)

* common: signing: improve debug output on failure [Joseph Kogut]

# v2.108.0
## (2022-12-16)

* Update NetworkManager to 1.40.4 [Zahari Petkov]

# v2.107.40
## (2022-12-16)

* Add upstream resolvconf 1.91 recipe for kirkstone [Zahari Petkov]

# v2.107.39
## (2022-12-16)


<details>
<summary> Update tests/leviathan digest to f44bbbd [renovate[bot]] </summary>

> ## leviathan-2.11.3
> ### (2022-12-16)
> 
> * Disable renovate config for now [Kyle Harding]
> * Restore worker release env var [Kyle Harding]
> 
> ## leviathan-2.11.2
> ### (2022-12-15)
> 
> * Update Node.js to v12.22.12 [Renovate Bot]
> 
> ## leviathan-2.11.1
> ### (2022-12-15)
> 
> * Remove dependabot as renovate is enabled in balena-io/renovate-config [Kyle Harding]
> * Pin worker to a release and add renovate regex template [Kyle Harding]
> 
> ## leviathan-2.11.0
> ### (2022-12-15)
> 
> * Update core/contracts digest to 08f029b [Renovate Bot]
> 
> ## leviathan-2.10.12
> ### (2022-12-15)
> 
> * Revert "Avoid conflicting docker subnets" [Vipul Gupta]
> 

</details>

# v2.107.38
## (2022-12-16)

* Update balena-os/balena-supervisor to v14.4.8 [renovate[bot]]

# v2.107.37
## (2022-12-15)

* tests: cloud: simplify apps to speedup suite [rcooke-warwick]

# v2.107.36
## (2022-12-15)


<details>
<summary> Update tests/leviathan digest to 48ffd13 [renovate[bot]] </summary>

> ## leviathan-2.10.11
> ### (2022-12-14)
> 
> * Avoid conflicting docker networks [Kyle Harding]
> 

</details>

# v2.107.35
## (2022-12-15)

* patch: Add default debug object to test config [Vipul Gupta (@vipulgupta2048)]

# v2.107.34
## (2022-12-14)

* initrdscripts: Wait for udev processing to complete when unlocking LUKS devices [Michal Toman]

# v2.107.33
## (2022-12-14)

* tests: hup: clean up inactive partition pre hup [rcooke-warwick]

# v2.107.32
## (2022-12-14)

* tests/cloud: Increase the wait time for services to start [Kyle Harding]

# v2.107.31
## (2022-12-14)


<details>
<summary> Update tests/leviathan digest to 27b78a4 [renovate[bot]] </summary>

> ## leviathan-2.10.10
> ### (2022-12-13)
> 
> * Enable external contributions via flowzone [Kyle Harding]
> 

</details>

# v2.107.30
## (2022-12-13)

* extra-udev-rules: Update teensy.rules [Alex Gonzalez]
* extra-udev-rules: Rename recipe [Alex Gonzalez]

# v2.107.29
## (2022-12-13)

* balena-image-initramfs: disable redundant compression [Joseph Kogut]

# v2.107.28
## (2022-12-12)

* initrdscripts: Only unlock LUKS partitions on the OS drive [Michal Toman]

# v2.107.27
## (2022-12-12)

* chrony: disable reverse dns lookups in healthcheck [Ken Bannister]

# v2.107.26
## (2022-12-12)

* connectivity: Add linux firmware for iwlwifi 9260 [Alex Gonzalez]

# v2.107.25
## (2022-12-11)

* image_types_balena: fix inconsistency with flasher image partition naming [Alex Gonzalez]

# v2.107.24
## (2022-12-09)

* Update balena-os/balena-supervisor to v14.4.6 [renovate[bot]]

# v2.107.23
## (2022-12-09)

* patch: Add product documentation [Vipul Gupta (@vipulgupta2048)]

# v2.107.22
## (2022-12-09)

* tests: os: fsck: make compatible with old yocto releaes [rcooke-warwick]

# v2.107.21
## (2022-12-08)

* tests/connectivity: Run the proxy tests with the actual redsocks uid of the DUT [Florin Sarbu]

# v2.107.20
## (2022-12-07)

* kernel-balena: enable zstd compression [Joseph Kogut]

# v2.107.19
## (2022-12-06)

* image_types_balena: generate bmap file [Joseph Kogut]
* flasher: write disk image skipping sparse blocks [Joseph Kogut]
* image_types_balena: create sparse disk image [Joseph Kogut]

# v2.107.18
## (2022-12-04)


<details>
<summary> Update tests/leviathan digest to fe4d6a1 [renovate[bot]] </summary>

> ## leviathan-2.10.9
> ### (2022-12-02)
> 
> * Revert "docker-compose: stop using the default docker bridge" [Kyle Harding]
> 
</details>

# v2.107.17
## (2022-12-02)


<details>
<summary> Update tests/leviathan digest to de97fa2 [renovate[bot]] </summary>

> ## leviathan-2.10.8
> ### (Invalid date)
> 
> * patch: Improve archivelogs journalctl command [Vipul Gupta (@vipulgupta2048)]
> * core: Reduce to 30 the retries number when trying to get the IP address of the DUT [Florin Sarbu]
> 
> ## leviathan-2.10.7
> ### (Invalid date)
> 
> * docker-compose: stop using the default docker bridge [Alex Gonzalez]
> 
> ## leviathan-2.10.6
> ### (2022-11-29)
> 
> * os/balenaos: Remove hidden attribute from DUT wireless connection file [Alexandru Costache]
> 
> ## leviathan-2.10.5
> ### (2022-11-29)
> 
> * patch: Add debug: unstable to docs [Vipul Gupta (@vipulgupta2048)]
> 
</details>

# v2.107.16
## (2022-12-01)

* Refactor and clean up the purge data tests [Kyle Harding]

# v2.107.15
## (2022-12-01)

* Updated CBS Docs Updated link to the CDS Product Repo [Ryan H]

# v2.107.14
## (2022-11-30)

* test: os: fix search for active interface [rcooke-warwick]

# v2.107.13
## (2022-11-29)

* balena-image-flasher: Include LUKS variant of GRUB config with FDE in place [Michal Toman]

# v2.107.12
## (2022-11-28)


<details>
<summary> Update tests/leviathan digest to 61016ad [renovate[bot]] </summary>

> ## leviathan-2.10.4
> ### (2022-11-25)
> 
> * bump contracts to 2.0.27 [rcooke-warwick]
> 
> ## leviathan-2.10.3
> ### (2022-11-24)
> 
> * On Apple Silicon we should install balena CLI via npm [Kyle Harding]
> 
</details>

# v2.107.11
## (2022-11-25)

* add os testing docs [rcooke-warwick]

# v2.107.10
## (2022-11-25)

* balena-image.bb: Include bits for LUKS when FDE is enabled [Michal Toman]

# v2.107.9
## (2022-11-24)

* resin-init-flasher: Fix double /dev/ prefix when encrypting partitions [Michal Toman]
* grub-conf: fix partition indexes in LUKS config [Michal Toman]
* os-helpers-fs: add dependency on parted [Michal Toman]
* hostapp-update-hooks: use stage2 bootloader GRUB config when using LUKS [Michal Toman]
* balena-rollback: Fix partition index detection for luks devices [Michal Toman]
* balena-rollback: Find following symbolic links [Alex Gonzalez]
* hostapp-update-hooks: Find following symlinks [Alex Gonzalez]
* hostapp-update-hooks: Fix partition index detection for luks devices [Alex Gonzalez]

# v2.107.8
## (2022-11-24)


<details>
<summary> Update tests/leviathan digest to bdf8eb2 [renovate[bot]] </summary>

> ## leviathan-2.10.2
> ### (2022-11-23)
> 
> * add high level architecture overview [rcooke-warwick]
> 
> ## leviathan-2.10.1
> ### (2022-11-23)
> 
> * Add conditions for Apple Silicon workstations [Kyle Harding]
> 
</details>

# v2.107.7
## (2022-11-23)

* tests: ssh-auth: rework local authentication with cloud keys to work in testbots [Alex Gonzalez]
* ssh-auth: do not use a separate custom key [Alex Gonzalez]
* Revert "test: ssh-auth: fix test cases using custom keys" [Alex Gonzalez]

# v2.107.6
## (2022-11-22)

* Update balena-os/balena-supervisor to v14.4.4 [renovate[bot]]

# v2.107.5
## (2022-11-22)

* Update balena-os/balena-supervisor to v14.4.2 [renovate[bot]]

# v2.107.4
## (2022-11-19)

* Update balena-os/balena-supervisor to v14.4.1 [renovate[bot]]

# v2.107.3
## (2022-11-19)

* kernel-balena: Kernel version check should include provided version [Alex Gonzalez]

# v2.107.2
## (2022-11-18)

* chronyd: allow service status notification socket access to all [Alex Gonzalez]
* chrony: update to version 4.2 [Alex Gonzalez]

# v2.107.1
## (2022-11-17)

* docs: add RAID setup info [Joseph Kogut]

# v2.107.0
## (2022-11-17)

* Update balena-os/balena-supervisor to v14.4.0 [renovate[bot]]

# v2.106.8
## (2022-11-17)

* classes: kernel-balena: add wireguard module [Alex Gonzalez]

# v2.106.7
## (2022-11-15)

* test: ssh-auth: fix test cases using custom keys [Alex Gonzalez]

# v2.106.6
## (2022-11-15)

* Update balena-os/balena-supervisor to v14.3.3 [renovate[bot]]

# v2.106.5
## (2022-11-14)

* openvpn: fix a race condition that leaves system with no running supervisor [Alex Gonzalez]

# v2.106.4
## (2022-11-12)

* ssh-auth: setConfig: run synchronously [Alex Gonzalez]
* cloud: ssh-auth: use custom path for custom key [Alex Gonzalez]
* balena-config-vars: Set permissions for cache file [Alex Gonzalez]

# v2.106.3
## (2022-11-11)

* common: kernel-devsrc: fix pseudo abort [Joseph Kogut]

# v2.106.2
## (2022-11-10)

* flasher: minor formatting [Joseph Kogut]
* flasher: fix detection and exclusion of installation media [Joseph Kogut]
* flasher: properly expand device_pattern globs [Joseph Kogut]

# v2.106.1
## (2022-11-10)

* tests: cloud: use cloud ssh to avoid race cond [rcooke-warwick]

# v2.106.0
## (2022-11-10)

* Update balena-os/balena-supervisor to v14.3.0 [renovate[bot]]

# v2.105.32
## (2022-11-09)

* Enable network access for tasks talking to the signing service [Michal Toman]

# v2.105.31
## (2022-11-08)

* Add meta-balena-esr workflow [Alex Gonzalez]

# v2.105.30
## (2022-11-08)

* tests: os: ensure by-state links are created [Joseph Kogut]

# v2.105.29
## (2022-11-07)

* prepare-openvpn: do not use cached configuration [Alex Gonzalez]

# v2.105.28
## (2022-11-06)

* patch: Delete conf.js for test suites [Vipul Gupta (@vipulgupta2048)]

# v2.105.27
## (2022-11-04)

* wpa-supplicant: Sync with v2.10 from upstream [Zahari Petkov]

# v2.105.26
## (2022-11-04)

* patch: Skip HUP suite if no releases found [Vipul Gupta (@vipulgupta2048)]

# v2.105.25
## (2022-11-04)

* Update balena-os/balena-supervisor to v14.2.20 [renovate[bot]]

# v2.105.24
## (2022-11-03)

* Update balena-os/balena-supervisor to v14.2.18 [renovate[bot]]

# v2.105.23
## (2022-11-01)

* tests: hup: handle exception when unwrapping non-flasher image [Joseph Kogut]

# v2.105.22
## (2022-10-31)

* Update Docs Link Updated the link in the docs to the device-type listings (on hub as SOT) [Ryan H]

# v2.105.21
## (2022-10-27)

* openssh: allow RSA signatures with SHA1 algorithms [Alex Gonzalez]

# v2.105.20
## (2022-10-26)

* meta-resin-sumo: libical: Fix build QA error [Alex Gonzalez]

# v2.105.19
## (2022-10-26)

* meta-resin-sumo: keep tpm2-tools in 5.0 [Alex Gonzalez]

# v2.105.18
## (2022-10-25)


<details>
<summary> Update tests/leviathan digest to f83df7d [renovate[bot]] </summary>

> ## leviathan-2.10.0
> ### (2022-10-25)
> 
> * minor: Add @balena/leviathan-test-helpers package [Vipul Gupta (@vipulgupta2048)]
> 
</details>

# v2.105.17
## (2022-10-21)

* tests: hup: reduce num. flashes and  hostapp sends [rcooke-warwick]

# v2.105.16
## (2022-10-20)

* common: openvpn: remove resin.conf [Joseph Kogut]

# v2.105.15
## (2022-10-19)

* Revert "chrony: update to version 4.1 to match kirkstone's version" [Alex Gonzalez]

# v2.105.14
## (2022-10-18)

* patch: Enable RPi3-64 for Device tree tests [Vipul Gupta (@vipulgupta2048)]

# v2.105.13
## (2022-10-18)

* ntp: Remove race condition from directory creation [Alex Gonzalez]

# v2.105.12
## (2022-10-17)

* classes: kernel-balena: Allow aufs patching to use network [Alex Gonzalez]

# v2.105.11
## (2022-10-13)

* Update balena-os/balena-supervisor to v14.2.10 [renovate[bot]]

# v2.105.10
## (2022-10-12)

* classes: kernel-balena: improve aufs branch selection [Alex Gonzalez]

# v2.105.9
## (2022-10-11)

* meta-balena-rust: Fix ABI for arm [Alex Gonzalez]

# v2.105.8
## (2022-10-11)

* meta-balena-thud: Enable GOCACHE [Alex Gonzalez]

# v2.105.7
## (2022-10-06)

* Update balena-os/balena-supervisor to v14.2.8 [renovate[bot]]

# v2.105.6
## (2022-10-06)


<details>
<summary> Update tests/leviathan digest to 4482393 [renovate[bot]] </summary>

> ## leviathan-2.9.9
> ### (2022-10-05)
> 
> * Revert "worker: Pin to stable release 2.5.10 prior to md support" [Kyle Harding]
> 
> ## leviathan-2.9.8
> ### (2022-10-05)
> 
> * Switch to Flowzone for CI [Kyle Harding]
> * Remove leftover balena.yml file [Kyle Harding]
> 
</details>

# v2.105.5
## (2022-10-01)


<details>
<summary> Update tests/leviathan digest to a2079bd [renovate[bot]] </summary>

> ## leviathan-2.9.7
> ### (Invalid date)
> 
> * Splie interface name into config [rcooke-warwick]
> * core: Specify wireless interface name for the 243390 device type [Alexandru Costache]
> 
</details>

# v2.105.4
## (2022-10-01)

* Update balena-os/balena-supervisor to v14.2.7 [renovate[bot]]

# v2.105.3
## (2022-09-30)

* flowzone: Run also for pull requests into ESR branches [Alex Gonzalez]
* Switch from balenaCI to flowzone [Pagan Gazzard]

# v2.105.2
## (2022-09-22)

* contributing-device-support.md: Clarify repo set-up in balenaOS org [Florin Sarbu]

# v2.105.1
## (2022-09-21)


<details>
<summary> Update tests/leviathan digest to 15d608b [renovate[bot]] </summary>

> ## leviathan-2.9.6
> ### (2022-09-21)
> 
> * core/contracts: bump contracts to v2.0.16 [Alexandru Costache]
> 
</details>

# v2.105.0
## (2022-09-20)

* Update balena-os/balena-supervisor to v14.2.0 [renovate[bot]]

# v2.104.1
## (2022-09-20)

* balena: remove kernel-module-nf-nat-native dependency for host build [Alexandru Costache]

# v2.104.0
## (2022-09-19)

* Update balena-os/balena-supervisor to v14.1.1 [renovate[bot]]

# v2.103.5
## (2022-09-19)

* Update balena-os/balena-supervisor to v14.0.25 [renovate[bot]]

# v2.103.4
## (2022-09-17)


<details>
<summary> Update tests/leviathan digest to 881cd72 [renovate[bot]] </summary>

> ## leviathan-2.9.5
> ### (2022-09-15)
> 
> * bump contracts to  v2.0.15 [rcooke-warwick]
> 
> ## leviathan-2.9.4
> ### (2022-09-13)
> 
> * increase timeout on local push sv ping [rcooke-warwick]
> 
> ## leviathan-2.9.3
> ### (2022-09-08)
> 
> * patch: Remove unused SDK helpers [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.9.2
> ### (2022-09-08)
> 
> * patch: Remove unused CLI helpers [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.9.1
> ### (2022-09-08)
> 
> * patch: Remove npm package as dependency [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.9.0
> ### (2022-09-07)
> 
> * core: Switch to debian base and install standalone balena-cli [Kyle Harding]
> * core: Set node engine to match the Dockerfile [Kyle Harding]
> * core: Remove balena-cli npm dependency [Kyle Harding]
> 
</details>

# v2.103.3
## (2022-09-15)

* resin-init-flasher: skip array members not matching a named array [Joseph Kogut]
* resin-init-flasher: support pattern matching of devices [Joseph Kogut]

# v2.103.2
## (2022-09-14)

* mobynit: allow compile task to use network [Joseph Kogut]

# v2.103.1
## (2022-09-13)

* tests: os: only do hdmi test if has capture device [rcooke-warwick]

# v2.103.0
## (2022-09-12)

* README: Add kirkstone support [Alex Gonzalez]
* layer.conf: Add kirkstone support [Alex Gonzalez]
* kernel-balena-noimage: Remove kernel-image packages from image [Alex Gonzalez]
* meta-balena-kirkstone: plymouth: Adapt custom patches [Alex Gonzalez]
* meta-balena-kirkstone: systemd: Ammend patches to remove fuzziness warning [Alex Gonzalez]
* meta-balena-kirkstone: replace honister with kirkstone [Alex Gonzalez]
* meta-balena-kirkstone: use upstream kernel-devsrc recipe [Alex Gonzalez]
* meta-balena-kirkstone: use the procps recipe from upstream [Alex Gonzalez]
* meta-balena-kirkstone: Add kirkstone integration layer [Alex Gonzalez]
* classes: image-balena: Fix journal blocks calculation [Alex Gonzalez]
* packagegroup-resin: Move libnss-ato out of packagegroup to avoid build error [Alex Gonzalez]
* openvpn: update to version 2.5.6 [Alex Gonzalez]
* balena-supervisor: Allow network use in install task [Alex Gonzalez]
* docker-disk: Allow compile task to use network [Alex Gonzalez]
* chrony: update to version 4.1 to match kirkstone's version [Alex Gonzalez]
* os-config: Adapt to kirkstone [Alex Gonzalez]
* healthdog: Adapt to kirkstone [Alex Gonzalez]
* compatibility: Do not update tpm2-tss below Dunfell [Alex Gonzalez]
* tpm2-tss: update to kirkstone [Alex Gonzalez]
* tpm2-tools: update to kirkstone [Alex Gonzalez]
* tpm2-abrmd: update to kirkstone [Alex Gonzalez]
* meta-balena-common: Assure all recipes have branch and protocol in SRC_URI [Alex Gonzalez]
* bluez5: update to 5.64 [Alex Gonzalez]
* efi-tools: Replace SSTATE_DUPWHITELIST with SSTATE_ALLOW_OVERLAP_FILES [Alex Gonzalez]

# v2.102.6
## (2022-09-07)


<details>
<summary> Update tests/leviathan digest to 7fe3c5f [renovate[bot]] </summary>

> ## leviathan-2.8.4
> ### (2022-09-07)
> 
> * core: Copy all files/directories except those in dockerignore [Kyle Harding]
> * core: Move contracts submodule back to original path [Kyle Harding]
> 
> ## leviathan-2.8.3
> ### (2022-09-07)
> 
> * patch: Migrate away from config package [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.8.2
> ### (2022-09-06)
> 
> * worker: Pin to stable release 2.5.10 prior to md support [Kyle Harding]
> 
> ## leviathan-2.8.1
> ### (2022-09-03)
> 
> * patch: Fix contracts name [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.8.0
> ### (2022-08-26)
> 
> * patch: Accept 429 HTTP codes using config file [Vipul Gupta (@vipulgupta2048)]
> * minor: Add support for Private Contracts [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.7.4
> ### (2022-08-24)
> 
> * Fix "Declaration emit" error during `npm run docs` [Leandro Motta Barros]
> 
</details>

# v2.102.5
## (2022-09-06)

* patch: Add package-lock.json files for tests [Vipul Gupta (@vipulgupta2048)]

# v2.102.4
## (2022-08-30)

* udev: run resin-update-state after md assemble [Joseph Kogut]
* resin_update_state_probe: do not skip md devices [Joseph Kogut]

# v2.102.3
## (2022-08-30)

* renovate: Restore default commit body [Kyle Harding]

# v2.102.2
## (2022-08-29)

* Renovate: Fix package rules for balena supervisor [Kyle Harding]

# v2.102.1
## (2022-08-29)

* meta-balena-thud: initramfs: Fix building with latest meta-balena [Alex Gonzalez]

# v2.102.0
## (2022-08-25)

* meta-balena-common: distro: Add rust preferred versions [Alex Gonzalez]
* meta-balena-common: os-config: Update to v1.2.11 [Alex Gonzalez]
* meta-balena-integration: Replace parallel_make_argument() [Alex Gonzalez]
* meta-balena-integration: Update cmake for versions below Zeus [Alex Gonzalez]
* meta-balena-rust: Add condition check for parallel_make_argument() use [Alex Gonzalez]
* meta-balena-rust: Provide crate fetcher for Yocto versions without it [Alex Gonzalez]
* meta-balena-rust: Modify to use without oe.rust.arch_to_rust_arch() support [Alex Gonzalez]
* meta-balena-rust: Add rust recipes to keep the rust version a distribution config [Alex Gonzalez]
* meta-balena-rust: Add compatibility layer [Alex Gonzalez]

# v2.101.11
## (2022-08-24)

* renovate: Fix nested changelogs and change-type for SV updates [Kyle Harding]

# v2.101.10
## (2022-08-23)

* meta-resin-sumo: linux-firmware: Move to a location included in BBPATH [Alex Gonzalez]
* meta-resin-sumo: use v1.14.2 [Alex Gonzalez]
* meta-resin-sumo: libqmi: Use v1.26.0 [Alex Gonzalez]
* meta-resin-sumo: libmbim: use v 1.24.2 [Alex Gonzalez]
* balena: Disable GOCACHE [Alex Gonzalez]

# v2.101.9
## (2022-08-23)


<details>
<summary> Update tests/leviathan digest to f7533c1 [renovate[bot]] </summary>

> ## leviathan-2.7.3
> ### (2022-08-16)
> 
> * compose: qemu: enable loopback and metadata devices [Joseph Kogut]
> 
</details>

# v2.101.8
## (2022-08-23)

* Update balena-io/balena-supervisor to v14.0.14 [renovate[bot]]

# v2.101.7
## (2022-08-17)

* Add automated tests for the Engine healthcheck [Leandro Motta Barros]
* Use a lightweight Engine healthcheck [Leandro Motta Barros]
* Make Engine watchdog termination graceful [Leandro Motta Barros]

# v2.101.6
## (2022-08-15)

* tests/cloud: fix ssh prod test for physical duts [rcooke-warwick]

# v2.101.5
## (2022-08-12)

* meta-balena-rust: Link to meta-rust [Alex Gonzalez]

# v2.101.4
## (2022-08-08)


<details>
<summary> Update tests/leviathan digest to c2c68d2 [renovate[bot]] </summary>

> ## leviathan-2.7.2
> ### (2022-08-05)
> 
> * exit with failure if suite doesn't start [rcooke-warwick]
> 
> ## leviathan-2.7.1
> ### (2022-08-02)
> 
> * Regenerate docs [Leandro Motta Barros]
> * Document proper worker config for QEMU workers [Leandro Motta Barros]
> * Fix a couple of typos in the docs [Leandro Motta Barros]
> 
> ## leviathan-2.7.0
> ### (2022-07-26)
> 
> * minor: Add Unstable tests debug feature [Vipul Gupta (@vipulgupta2048)]
> 
</details>

# v2.101.3
## (2022-08-05)

* Update balena-io/balena-supervisor to v14.0.13 [renovate[bot]]

# v2.101.2
## (2022-08-05)

* DRY the HUP smoke tests [Leandro Motta Barros]
* Check volume contents over HUPs [Leandro Motta Barros]

# v2.101.1
## (2022-08-01)

* os-config: Update os-config from v1.2.1 to v1.2.10 [Zahari Petkov]

# v2.101.0
## (2022-07-29)

* resin-device-register: Use fatrw to access the boot partition [Alex Gonzalez]
* hostapp-update-hooks: Use fatrw to access the boot partition [Alex Gonzalez]
* balena-unique-key: Use fatrw to access the boot partition [Alex Gonzalez]
* balena-rollback: Use fatrw if available [Alex Gonzalez]
* update-hostapp-extensions: Use fatrw if available [Alex Gonzalez]
* balena-config-vars: Provide FAT safe filesystem access alternatives [Alex Gonzalez]
* fatrw: Add recipe [Alex Gonzalez]

# v2.100.11
## (2022-07-25)

* test: os: chrony: Double the wait for time skew test [Kyle Harding]
* os: tests: chrony: Wrap disable/enable NTP in test conditions [Kyle Harding]
* tests: os: Add helper to write or remove properties in config.json [Kyle Harding]

# v2.100.10
## (2022-07-24)

* tests: cloud: preload: fix no-return-await [Joseph Kogut]
* tests: cloud: preload: reduce waitUntil interval [Joseph Kogut]
* tests: cloud: multicontainer: reduce waitUntil interval [Joseph Kogut]

# v2.100.9
## (2022-07-22)

* tests: os: engine-socket - wait for response [rcooke-warwick]

# v2.100.8
## (2022-07-21)

* tests/os: Add 243390 unmanged Wifi HATs tests from testLodge [Alexandru Costache]

# v2.100.7
## (2022-07-21)

* tests: hup: Clear inactive storage partition before HUP [Kyle Harding]
* tests: hup: Add root partition tests [Kyle Harding]
* tests: hup: Replace custom steps with tests and verify exit code [Kyle Harding]
* tests: hup: Wait for rollback files to be removed or created [Kyle Harding]

# v2.100.6
## (2022-07-21)

* balena-config-vars: Do not use cache in flasher images [Alex Gonzalez]

# v2.100.5
## (2022-07-21)

* Update balena-io/balena-supervisor to v14.0.12 [renovate[bot]]

# v2.100.4
## (2022-07-20)


<details>
<summary> Update tests/leviathan digest to d3c6489 [renovate[bot]] </summary>

> ## leviathan-2.6.8
> ### (2022-07-20)
> 
> * core: Reduce logging in failed SSH attempts [Kyle Harding]
> 
> ## leviathan-2.6.7
> ### (2022-07-18)
> 
> * Revert "patch: Increase timeout for worker connections" [Kyle Harding]
> * core: Update node-tap to 14.10.8 [Kyle Harding]
> 
</details>

# v2.100.3
## (2022-07-20)

* tests: ssh-auth: Rework to prevent race conditions [Kyle Harding]

# v2.100.2
## (2022-07-15)


<details>
<summary> Update tests/leviathan digest to c2755a1 [renovate[bot]] </summary>

> ## leviathan-2.6.6
> ### (2022-07-15)
> 
> * core: worker: add retryOptions to executeCommand methods [Joseph Kogut]
> 
</details>

# v2.100.1
## (2022-07-15)

* tests: cloud: fix production mode ssh test [Joseph Kogut]

# v2.100.0
## (2022-07-14)

* docs: Add configuration overview [Alex Gonzalez]
* Create empty configuration units [Alex Gonzalez]
* Make configuration units storage path a distro setting [Alex Gonzalez]
* balena-configurable: Generate initial unit configuration file [Alex Gonzalez]
* balena-units-conf: Add script to generate configuration units [Alex Gonzalez]
* balena-units-conf: Rename configuration directory [Alex Gonzalez]
* balena-units-conf: Process static configuration unit files at build time [Alex Gonzalez]
* os-helpers-config: Extract functions from os-config-json to helper file [Alex Gonzalez]
* os-helpers: Rename os-helpers-devmode to os-helpers-config [Alex Gonzalez]
* balena-config-vars: Split static defaults into a different file [Alex Gonzalez]
* os-config-json: Log configuration changes [Alex Gonzalez]
* os-config-json: Recreate environment cache file [Alex Gonzalez]
* balena-config-vars: Cache environment in memory file [Alex Gonzalez]

# v2.99.30
## (2022-07-14)

* Update backport for current being 2.98.x [Alex Gonzalez]

# v2.99.29
## (2022-07-14)

* Update balena-io/balena-supervisor to v14.0.10 [renovate[bot]]

# v2.99.28
## (2022-07-13)


<details>
<summary> Update tests/leviathan digest to d57299a [renovate[bot]] </summary>

> ## leviathan-2.6.5
> ### (2022-07-12)
> 
> * core: Reduce the interval for sdk.executeCommandInHostOS [Kyle Harding]
> * Revert "reduce ssh retries" [Kyle Harding]
> 
> ## leviathan-2.6.4
> ### (2022-07-07)
> 
> * remove parallel suites across multiple workers [rcooke-warwick]
> 
> ## leviathan-2.6.3
> ### (2022-07-06)
> 
> * reduce ssh retries [rcooke-warwick]
> 
> ## leviathan-2.6.2
> ### (2022-07-04)
> 
> * Makefile: Fix unique container names when running on Jenkins [Kyle Harding]
> * Makefile: Ignore failures when cleaning up [Kyle Harding]
> 
> ## leviathan-2.6.1
> ### (2022-07-01)
> 
> * patch: Remove testing step of purging old volumes [Kyle Harding]
> * patch: Increase timeout for worker connections [Kyle Harding]
> 
> ## leviathan-2.6.0
> ### (Invalid date)
> 
> * minor: Improve e2e serial test for Leviathan v2 [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.5.7
> ### (Invalid date)
> 
> * patch: Limit e2e execution time to 2 hours [Kyle Harding]
> 
> ## leviathan-2.5.6
> ### (Invalid date)
> 
> * patch: Use ubuntu-latest GH runners for e2e [Kyle Harding]
> 
</details>

# v2.99.27
## (2022-06-30)

* tests: os: fingerprint: fix errant promise [Joseph Kogut]

# v2.99.26
## (2022-06-29)

* tests: cloud: Wait for random triggers to be updated [Kyle Harding]

# v2.99.25
## (2022-06-28)


<details>
<summary> Update tests/leviathan digest to 4fe9b19 [renovate[bot]] </summary>

> ## leviathan-2.5.5
> ### (2022-06-24)
> 
> * github: Run e2e tests via github actions [Kyle Harding]
> * make: Clean local volumes before running tests [Kyle Harding]
> * worker: Pin worker image to latest by default [Kyle Harding]
> * e2e: Update e2e suite config to support testbots [Kyle Harding]
> 
</details>

# v2.99.24
## (2022-06-28)

* tests: Increase delay when testing randomized timers [Kyle Harding]

# v2.99.23
## (2022-06-27)

* Update: update balena-io/balena-supervisor to v14.0.8 [renovate[bot]]

# v2.99.22
## (2022-06-27)

* balena-supervisor: Replace BOOT_MOUNTPOINT with BALENA_BOOT_MOUNTPOINT [Alex Gonzalez]
* balena-config-vars: Remove BOOT_MOUNTPOINT from configuration environment [Alex Gonzalez]

# v2.99.21
## (2022-06-27)

* balena-config-vars: Do not use systemctl to list unit files [Alex Gonzalez]

# v2.99.20
## (2022-06-24)

* tests: os: make apiKey an optional parameter [Joseph Kogut]

# v2.99.19
## (2022-06-24)

* tests: os: purge-data: reduce intervals in waitUntil [Joseph Kogut]

# v2.99.18
## (2022-06-23)

* tests: os: config-json: fix race in udevRules test [Joseph Kogut]

# v2.99.17
## (2022-06-22)

* Update balena-io/balena-supervisor to v14.0.7 [renovate[bot]]

# v2.99.16
## (2022-06-22)

* tests: os: modem: reduce time taken scanning for modems [Joseph Kogut]

# v2.99.15
## (2022-06-21)


<details>
<summary> Update tests/leviathan digest to 9e0ab34 [renovate[bot]] </summary>

> ## leviathan-2.5.4
> ### (2022-06-17)
> 
> * core: worker: simplify rebootDut [Joseph Kogut]
> * core: worker: reduce interval in executeCommandInHostOS [Joseph Kogut]
> 
</details>

# v2.99.14
## (2022-06-21)

* tests: os: chrony: simplify error handling [Joseph Kogut]
* tests: os: chrony: use waitForServiceState [Joseph Kogut]
* tests: os: chrony: block NTP by disabling DNS resolution [Joseph Kogut]

# v2.99.13
## (2022-06-21)

* Update balena-io/balena-supervisor to v14 [renovate[bot]]

# v2.99.12
## (2022-06-20)

* renovate: Add regex manager for balena-supervisor [Kyle Harding]

# v2.99.11
## (2022-06-20)

* tests: cloud: check preloaded app starts w/o api [rcooke-warwick]

# v2.99.10
## (2022-06-18)

* Update backport for current being 2.88.x [Alex Gonzalez]

# v2.99.9
## (2022-06-17)

* hostapp-update-hooks: Rework bootfiles blacklist [Florin Sarbu]

# v2.99.8
## (2022-06-17)

* base-files: Fix syntax in mdns.allow addition [Alex Gonzalez]
* efitools: Fix append syntax [Alex Gonzalez]

# v2.99.7
## (2022-06-17)

* resindataexpander: Move get_part_table_type to os-helpers-fs [Michal Toman]

# v2.99.6
## (2022-06-17)

* balena-efi.service: Mount if /mnt/boot/EFI is a symlink [Michal Toman]

# v2.99.5
## (2022-06-17)

* grub-efi: disable shim_lock when in secure boot mode [Michal Toman]

# v2.99.4
## (2022-06-16)


<details>
<summary> Update tests/leviathan digest to 6934150 [Renovate Bot] </summary>

> ## leviathan-2.5.3
> ### (2022-06-16)
> 
> * patch: Fix failFast options [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.5.2
> ### (2022-06-15)
> 
> * core: worker: handle all local connections the same [Joseph Kogut]
> 
> ## leviathan-2.5.1
> ### (2022-06-14)
> 
> * core: catch ssh errors correctly [rcooke-warwick]
> 
> ## leviathan-2.5.0
> ### (2022-06-13)
> 
> * make: Disable buildkit and add --pull to worker flags [Kyle Harding]
> * patch: Replace worker Dockerfile with bh.cr reference [Kyle Harding]
> * patch: Remove testbot worker compose file [Kyle Harding]
> * patch: Remove balena-ci workflow for deploying to rigs [Kyle Harding]
> * Remove worker references from package.json [Kyle Harding]
> * Remove worker source files [Kyle Harding]
> 
</details>

# v2.99.3
## (2022-06-16)

* tests: os: Run os suite before hup and cloud [Kyle Harding]
* tests: os: Refactor config-json tests to wait for passing results [Kyle Harding]
* tests: os: chrony: Avoid conflicts with supervisor firewall [Kyle Harding]

# v2.99.2
## (2022-06-13)

* tests: os: chrony: reduce retry interval [Joseph Kogut]

# v2.99.1
## (2022-06-11)

* tests: hup: gzip hostapp before transfer to DUT [rcooke-warwick]

# v2.99.0
## (2022-06-10)

* chronyd: Add time synchronization healthcheck [Alex Gonzalez]

# v2.98.45
## (2022-06-09)

* tests: os: chrony: fix formatting of this.worker [Joseph Kogut]
* tests: os: chrony: reduce delays and retries [Joseph Kogut]

# v2.98.44
## (2022-06-09)


<details>
<summary> Update tests/leviathan digest to ea72650 [Renovate Bot] </summary>

> ## leviathan-2.4.1
> ### (2022-06-09)
> 
> * catch error in executeCommandInhostOs [rcooke-warwick]
> 
> ## leviathan-2.4.0
> ### (2022-06-07)
> 
> * get ssh to work with ed25519 algorithm [rcooke-warwick]
> 
</details>

# v2.98.43
## (2022-06-09)

* tests: cloud: update container names [rcooke-warwick]

# v2.98.42
## (2022-06-05)

* tests:cloud: Register teardown only when DUT is reachable [Florin Sarbu]

# v2.98.41
## (2022-06-05)


<details>
<summary> Update tests/leviathan digest to 4fbc1b8 [Renovate Bot] </summary>

> ## leviathan-2.3.10
> ### (2022-06-05)
> 
> * worker: Expose additional QEMU runtime args via docker-compose [Kyle Harding]
> 
</details>

# v2.98.40
## (2022-06-04)

* tests: hup: reduce delay between retries [Joseph Kogut]

# v2.98.39
## (2022-06-04)

* tests: cloud: reduce waitUntil interval [Joseph Kogut]

# v2.98.38
## (2022-06-03)

* Added all device support options [Ryan H]

# v2.98.37
## (2022-06-03)


<details>
<summary> Update tests/leviathan digest to 8976bdb [Renovate Bot] </summary>

> ## leviathan-2.3.9
> ### (2022-06-02)
> 
> * core: bump node 12 -> 14 [Joseph Kogut]
> 
> ## leviathan-2.3.8
> ### (2022-06-02)
> 
> * core: suiteSubprocess: replace this.state.log w/ console.log [Joseph Kogut]
> 
</details>

# v2.98.36
## (2022-06-03)

* os: waitForServiceState: fix missing rejectionFail [Joseph Kogut]

# v2.98.35
## (2022-06-02)

* tests: os: udev: improve formatting [Joseph Kogut]
* tests: os: udev: use systemd.waitForServiceState [Joseph Kogut]

# v2.98.34
## (2022-06-01)


<details>
<summary> Update tests/leviathan digest to b3b1b48 [Renovate Bot] </summary>

> ## leviathan-2.3.7
> ### (2022-06-01)
> 
> * worker: qemu: remove debug print statements [Joseph Kogut]
> 
> ## leviathan-2.3.6
> ### (2022-05-26)
> 
> * core: worker: shorten getDutIp interval [Joseph Kogut]
> * worker: helpers: memoize resolveLocalTarget [Joseph Kogut]
> * worker: helpers: resolveLocalTarget: increase timeout [Joseph Kogut]
> 
</details>

# v2.98.33
## (2022-05-27)


<details>
<summary> Update tests/leviathan digest to 95649fb [Renovate Bot] </summary>

> ## leviathan-2.3.5
> ### (2022-05-25)
> 
> * workers: qemu: fix vars path for x86_64 [Joseph Kogut]
> 
</details>

# v2.98.32
## (2022-05-27)

* supervisor: Update balena-supervisor to v13.1.11 [Felipe Lalanne]

# v2.98.31
## (2022-05-26)

* tests: os: config-json: fix race by waiting for InvocationID change [Joseph Kogut]
* tests: os: reformat config-json tests [Joseph Kogut]

# v2.98.30
## (2022-05-24)

* Remove localMode setting from standalone image configuration [Alex Gonzalez]

# v2.98.29
## (2022-05-23)


<details>
<summary> Update balena-engine to v20.10.17 [Leandro Motta Barros] </summary>

> ## balena-engine-20.10.17
> ### (2022-05-17)
> 
> * Fix "slice bounds out of range" while applying deltas [Leandro Motta Barros]
> 
</details>

# v2.98.28
## (2022-05-20)


<details>
<summary> Update tests/leviathan digest to 727ba9f [Renovate Bot] </summary>

> ## leviathan-2.3.4
> ### (2022-05-20)
> 
> * worker: qemu: add new qemu firmware paths [Joseph Kogut]
> * worker: install edk2 firmware for aarch64 [Joseph Kogut]
> * worker: Change default qemu memory from 2G to 512M [Kyle Harding]
> * make: Do not assume qemu DUT arch will match the host [Kyle Harding]
> * make: Allow passed env vars to replace any .env values [Kyle Harding]
> 
</details>

# v2.98.27
## (2022-05-18)

* patch: Fix heading anchor links in CDS doc index [Vipul Gupta]

# v2.98.26
## (2022-05-17)

* balena-supervisor: Randomize the updater timer period [Alex Gonzalez]

# v2.98.25
## (2022-05-16)

* patch: Get CDS doc ready for docs sync [Vipul Gupta]
* test: os-config: Use common code to wait for service state [Alex Gonzalez]

# v2.98.24
## (2022-05-15)

* os-config: Randomize the timer period [Alex Gonzalez]

# v2.98.23
## (2022-05-11)

* linux-firmware: Fix quz-a0-hr-b0 and quz-a0-jf-b0 packaging for compression [Michal Toman]

# v2.98.22
## (2022-05-11)


<details>
<summary> Update tests/leviathan digest to 01719b5 [Renovate Bot] </summary>

> ## leviathan-2.3.3
> ### (2022-05-09)
> 
> * Fixes spelling and grammar in e2e [Alex]
> 
> ## leviathan-2.3.2
> ### (2022-05-02)
> 
> * Record environment variables to file for client env [Kyle Harding]
> 
> ## leviathan-2.3.1
> ### (2022-05-02)
> 
> * patch: Remove development shortcuts [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.3.0
> ### (2022-04-29)
> 
> * minor: Add support for debug object [Vipul Gupta (@vipulgupta2048)]
> 
> ## leviathan-2.2.14
> ### (2022-04-29)
> 
> * patch: Remove Express server port config [Vipul Gupta (@vipulgupta2048)]
> 
</details>

# v2.98.21
## (2022-05-11)

* contributing-device-support.md: Enhance device contribution guide [Florin Sarbu]

# v2.98.20
## (2022-05-10)

* renovate: Override commit body for meta-balena to Change-type [Kyle Harding]
* renovate: Remove extra leviathan package rules [Kyle Harding]

# v2.98.19
## (2022-05-10)

* tests/connectivity: Force proxy tests to use IPv4 [Kyle Harding]
* tests/connectivity: Fix compose warnings for expected string [Kyle Harding]

# v2.98.18
## (2022-05-10)


<details>
<summary> supervisor: Update balena-supervisor to v13.1.6 [Alex Gonzalez] </summary>

> ## balena-supervisor-13.1.6
> ### (2022-05-06)
> 
> * Avoid splash image failures if image is corrupt [Felipe Lalanne]
> 
> ## balena-supervisor-13.1.5
> ### (2022-05-03)
> 
> * Use write + sync when writing configs to /mnt/boot [Felipe Lalanne]
> 
</details>

# v2.98.17
## (2022-05-06)

* renovate: Override default package rules to enable leviathan [Kyle Harding]

# v2.98.16
## (2022-05-05)

* renovate: Replace tests with tests/suites in default ignorePaths [Kyle Harding]

# v2.98.15
## (2022-05-04)

* Rename renovate config [Kyle Harding]

# v2.98.14
## (2022-05-04)


<details>
<summary> supervisor: Update balena-supervisor to v13.1.4 [Kyle Harding] </summary>

> ## balena-supervisor-13.1.4
> ### (2022-04-28)
> 
> * Use delay instead of interval to recursively report state [20k-ultra]
> 
> ## balena-supervisor-13.1.3
> ### (2022-04-20)
> 
> * Remove in memory storage of started/stopped containers [20k-ultra]
> * Only start a container once in its lifetime This will ensure the restart policy specified is not violated [20k-ultra]
> 
> ## balena-supervisor-13.1.2
> ### (2022-04-18)
> 
> * Explain /v2/state/status's status field in its response [Christina Wang]
> 
> ## balena-supervisor-13.1.1
> ### (2022-04-13)
> 
> * Do not fail lockfile cleanup if files do not exist [Felipe Lalanne]
> 
> ## balena-supervisor-13.1.0
> ### (2022-04-12)
> 
> * Add lockfile binary and internal lib for interfacing with it [Christina Wang]
> 
> ## balena-supervisor-13.0.3
> ### (2022-04-08)
> 
> * Add system id/model support for Compulab IOT-gate [Felipe Lalanne]
> 
> ## balena-supervisor-13.0.2
> ### (2022-04-08)
> 
> * Correctly evaluate downloadProgress when computing current state [20k-ultra]
> 
> ## balena-supervisor-13.0.1
> ### (2022-04-01)
> 
> * Fix database migration for legacyApps [Felipe Lalanne]
> 
> ## balena-supervisor-13.0.0
> ### (2022-03-23)
> 
> * Add support for GET v3 target state [Felipe Lalanne]
> 
> ## balena-supervisor-12.11.43
> ### (2022-03-21)
> 
> * Always add status to image download report [Felipe Lalanne]
> 
> ## balena-supervisor-12.11.42
> ### (2022-03-18)
> 
> * Moved test setup into file included for all tests [20k-ultra]
> 
> ## balena-supervisor-12.11.41
> ### (2022-03-16)
> 
> * Added PR template doc [20k-ultra]
> 
> ## balena-supervisor-12.11.40
> ### (2022-03-16)
> 
> * Only count report connectivity errors for healthcheck [Felipe Lalanne]
> * update packages for vulnerabilities [20k-ultra]
> 
> ## balena-supervisor-12.11.39
> ### (2022-03-16)
> 
> * Move report throttle out of reporting logic [20k-ultra]
> * Update npm dep sinon to v11.1.2 [20k-ultra]
> 
</details>

# v2.98.13
## (2022-05-03)

* os: tests: optimize connectivity tests [Joseph Kogut]

# v2.98.12
## (2022-05-02)

* tests/hup: Test hostapp-update from current release [Kyle Harding]

# v2.98.11
## (2022-04-29)

* tests: os: create swap test [Joseph Kogut]

# v2.98.10
## (2022-04-28)

* tests: bump leviathan to 2.13 [rcooke-warwick]

# v2.98.9
## (2022-04-28)

* tests: bump leviathan to 2.2.11 [rcooke-warwick]

# v2.98.8
## (2022-04-28)

* tests/cloud: fix ssh test for testbot workers [rcooke-warwick]

# v2.98.7
## (2022-04-27)

* linux-firmware: package QuZ-a0-jf-b0 separately [Michal Toman]

# v2.98.6
## (2022-04-26)

* timeinit/timesync-https: Update rtc after setting system time [Alexandru Costache]

# v2.98.5
## (2022-04-26)

* networkmanager: Use default DHCP timeout [Zahari Petkov]

# v2.98.4
## (2022-04-25)

* Disable Engine startup timeouts [Leandro Motta Barros]

# v2.98.3
## (2022-04-25)

* Add renovate configuration [Kyle Harding]

# v2.98.2
## (2022-04-25)

* balena-config-vars: unit-conf: Correct description [Alex Gonzalez]
* tests: os: Remove sshKeys test [Alex Gonzalez]
* tests: cloud: Add SSH authentication tests [Alex Gonzalez]
* os-sshkeys: When ssh keys change, regenerate development configuration [Alex Gonzalez]
* development-features: use os-helpers-devmode include file [Alex Gonzalez]
* os-helpers: Add os-helpers-devmode [Alex Gonzalez]

# v2.98.1
## (2022-04-23)

* tests/leviathan: Update leviathan to v2.2.4 [Kyle Harding]

# v2.98.0
## (2022-04-23)

* Refresh PKI assets from config endpoint [ab77]

# v2.97.0
## (2022-04-23)


<details>
<summary> Update balena-engine to v20.10.16 [Leandro Motta Barros] </summary>

> ## balena-engine-20.10.16
> ### (2022-04-07)
> 
> * contrib/init/systemd: update balena-engine.service [TIAN Yuanhao]
> 
> ## balena-engine-20.10.15
> ### (2022-04-05)
> 
> * Log more info upon when raising errRootFSMismatch [Leandro Motta Barros]
> 
> ## balena-engine-20.10.14
> ### (2022-04-01)
> 
> * Add more integration tests for deltas [Leandro Motta Barros]
> 
> ## balena-engine-20.10.13
> ### (2022-03-09)
> 
> * Add link to post to test landr [andrew]
> 
</details>

# v2.96.1
## (2022-04-22)

* kernel-balena: Mention https protocol for github repository [Alexandru Costache]

# v2.96.0
## (2022-04-22)

* mobynit: Update to v0.2.0 [Alex Gonzalez]

# v2.95.17
## (2022-04-22)

* resin-device-register: avoid blocking the flasher when not connected [Alexandru Costache]

# v2.95.16
## (2022-04-19)

* Package iwlwifi-QuZ-a0-hr-b0 firmware separately [Florin Sarbu]

# v2.95.15
## (2022-04-06)

* kernel-headers-test: clean tools like fixdep [Alexandru Costache]

# v2.95.14
## (2022-04-06)

* Updates SIM info for soracom and provides docs. [Alex]

# v2.95.13
## (2022-04-06)

* test/hup: fix unmounting error [rcooke-warwick]

# v2.95.12
## (2022-03-31)

* grub-efi: Remove patch passing secure boot status to the kernel [Michal Toman]

# v2.95.11
## (2022-03-30)

* hostapp-update: Mount data partition on target balena/tmp [Kyle Harding]

# v2.95.10
## (2022-03-30)

* tests/os: check supervisor is pulled  after purge [rcooke-warwick]

# v2.95.9
## (2022-03-28)

* tests: update leviathan to 2.0.4 [rcooke-warwick]
* tests: update config for new leviathan version [rcooke-warwick]

# v2.95.8
## (2022-03-25)

* resindataexpander: Check and fix end GPT if necessary [Alexandru Costache]

# v2.95.7
## (2022-03-23)

* hostapp-update-hooks: Always update legacy development variants to development mode [Alex Gonzalez]

# v2.95.6
## (2022-03-22)

* balena-supervisor: Use architecture instead of device type to query API [Alex Gonzalez]
* update-balena-supervisor: Support passing command line image argument [Alex Gonzalez]

# v2.95.5
## (2022-03-21)

* tests/kernel-overlap: Prevent test run failure on older kernels [Alexandru Costache]

# v2.95.4
## (2022-03-17)

* tests/os: wait for osconfig service to be inactive [rcooke-warwick]

# v2.95.3
## (2022-03-15)

* balena-supervisor: Update balena-supervisor to v12.11.38 Ensure preloaded applications are ran when no internet is available on first run [20k-ultra]

# v2.95.2
## (2022-03-11)

* kernel-balena: Disable building gcc plugins [Alexandru Costache]

# v2.95.1
## (2022-03-08)

* tests: Add leviathan v2.0.0 as a submodule [Kyle Harding]
* tests/cloud: Cleanup wait until loops in cloud suite [Kyle Harding]
* tests/hup: Remove bluebird and this.context.get references [Kyle Harding]
* tests/os: Remove bluebird and this.context.get references [Kyle Harding]
* tests/cloud: Remove bluebird and this.context.get references [Kyle Harding]
* tests: Cleanup suites config to support both testbot and qemu workers [Kyle Harding]
* tests/cloud: Update cloud suite to support core on client [Kyle Harding]
* tests/hup: Update hup suite to support core on client [Kyle Harding]
* tests/os: Update os suite to support core on client [Kyle Harding]

# v2.95.0
## (2022-03-04)

* Adds modem test suite [Alex]

# v2.94.5
## (2022-03-04)

* Use by-state symlink for mounting the EFI partition when split [Michal Toman]
* os-helpers: add TPM2 helpers [Michal Toman]
* Add PCR protection policy to TPM operation unlocking LUKS passphrase [Michal Toman]

# v2.94.4
## (2022-03-04)

* balena-supervisor: Fix supervisor tagging command [Florin Sarbu]

# v2.94.3
## (2022-03-02)

* tests/os: fix bracket in bbb overlay test [rcooke-warwick]

# v2.94.2
## (2022-03-02)

* tests: Enhance BeagleBone Black u-boot overlay test [Florin Sarbu]

# v2.94.1
## (2022-03-01)

* balena-image: Default image type to balenaos-img [Alex Gonzalez]
* Remove legacy resinhup images. [Alex Gonzalez]

# v2.94.0
## (2022-03-01)


<details>
<summary> Update balena-supervisor to v12.11.36 [Robert Günzler] </summary>

> ## balena-supervisor-12.11.36
> ### (2022-02-23)
> 
> * Ignore selinux security opts when comparing services [Felipe Lalanne]
> 
> ## balena-supervisor-12.11.35
> ### (2022-02-16)
> 
> * Add troubleshooting notice for macOS [fisehara]
> 
> ## balena-supervisor-12.11.34
> ### (2022-02-15)
> 
> * Create `touch` and `getBootTime` utility functions [Felipe Lalanne]
> * Add update lock check to PATCH /v1/device/host-config [Christina Wang]
> 
> ## balena-supervisor-12.11.33
> ### (2022-02-09)
> 
> * Add support for local ipv6 reporting [Felipe Lalanne]
> 
</details>

* meta-resin-pyro: make sure $GO is set [Robert Günzler]
* Refactor balena-engine recipe to more closely resemble upstream [Robert Günzler]
* Update Golang recipes to 1.16.2 [Robert Günzler]

<details>
<summary> Update balena-engine to v20.10.12 [Robert Günzler] </summary>

> ## balena-engine-20.10.12
> ### (2022-02-18)
> 
> * storagemigration: keep going if migration fails [Robert Günzler]
> * graphdriver/copy: fix handling of sockets [Robert Günzler]
> * pkg/storagemigration: use graphdriver/copy.DirCopy [Robert Günzler]
> * Prune Jenkinsfile [Robert Günzler]
> * Backport platform-detection fixes from containerd [Robert Günzler]
> * storagemigration: capture failcleanup logs in logfile [Robert Günzler]
> * storagemigration: move logic to package [Robert Günzler]
> * prevent slice oob access in concatReadSeekCloser [Martin Rauscher]
> * Make layer download resuming more resilient [Leandro Motta Barros]
> * Drop CODEOWNERS [Robert Günzler]
> * pkg/storagemigration: poperly handle errors during state creation [Robert Günzler]
> * pkg/storagemigration: allow writing logs to separate file [Robert Günzler]
> * storagemigration: defer commit to next start [Robert Günzler]
> * Lock destination layers while delta is being processed [Robert Günzler]
> * Add aufs to overlay2 migrator [Robert Günzler]
> * Update the README [Robert Günzler]
> * Cleanup repo [Robert Günzler]
> * Add a SECURITY.md [Robert Günzler]
> * top_unix.go: allow busybox ps with no args [Kyle Harding]
> * Bump balena-os/balena-containerd to 1da48a8 [Tian Yuanhao]
> * Add changelog template to allow generating nested changelogs [Robert Günzler]
> * Update github issue and pr templates [Robert Günzler]
> * Update codeowners [Robert Günzler]
> * hack: Fix CLI versioning [Robert Günzler]
> * Fixed typos in getting-started.md docs [Miguel Casqueira]
> * Add integration tests for hostapp handling [Robert Günzler]
> * Fix container data deletion [Roman Mazur]
> * overlay2: Add List support [Roman Mazur]
> * aufs: Add List support [Roman Mazur]
> * layer: Remove unreferenced driver layers on create [Roman Mazur]
> * layer: Prune unused data on layer store creation [Roman Mazur]
> * layer: Persist cacheID early on transaction start [Roman Mazur]
> * pkg/authorization: Fix test failures on macOS [Roman Mazur]
> * Move ci to balenaCI [Robert Günzler]
> * contrib: Add balena-engine version of dind container [Robert Günzler]
> * build.sh: Disable btrfs,zfs,devicemapper graphdrivers [Robert Günzler]
> * Bump CLI dependency to include fix for #178 [Robert Günzler]
> * Bump CLI dependency to include --cidenv flag [Robert Günzler]
> * Allow passing container ID to container via environment variable [Robert Günzler]
> * contrib/install.sh: Add details to the success message [Robert Günzler]
> * contrib/install.sh: Rename balena to balenaEngine in ASCII art output [Robert Günzler]
> * contrib/install.sh: Fail on error [Robert Günzler]
> * Add daemon flags to configure max download/upload attempts during pull/push [Robert Günzler]
> * aufs,overlay2: Add driver opts for disk sync [Robert Günzler]
> * Fix double locking in the event handling code of OOM events [Robert Günzler]
> * integration-tests: Add test for containers with memory,cpu constraints [Robert Günzler]
> * Update Dockerfiles used for build to Go 1.10.8 [Robert Günzler]
> * travis: Use the minimal machine [Robert Günzler]
> * Add cli for tagging delta images [Robert Günzler]
> * Allow tagging of image deltas on creation [Robert Günzler]
> * docs: Fix Docker capitalisation in balenaEngine docs [Paulo Castro]
> * Update balenaEngine logo in README.md [Paulo Castro]
> * Disable incompatible integration tests [Paulo Castro]
> 
> ## balena-engine-20.10.11
> ### (2021-12-09)
> 
> * Merge upstream v20.10.11 [Robert Günzler]
> 
</details>

# v2.93.2
## (2022-03-01)

* prepare-openvpn: Make configurable [Alex Gonzalez]

# v2.93.1
## (2022-02-28)

* tests/cloud: Use deviceID returned from pre-registration [Kyle Harding]

# v2.93.0
## (2022-02-26)

* resin-device-register: Use supervisor version label instead of tag [Alex Gonzalez]
* balena-supervisor: Rename repository/tag to fleet/version [Alex Gonzalez]
* docker-disk: entry.sh: Rename repository/tag to fleet/version [Alex Gonzalez]

# v2.92.0
## (2022-02-25)

* Update ModemManager to v1.18.4 [Zahari Petkov]

# v2.91.6
## (2022-02-25)

* resin-device-register: Regenerate VPN credentials on registration [Alex Gonzalez]
* resin-init-flasher: Wait for resin-device-register to start [Alex Gonzalez]

# v2.91.5
## (2022-02-24)

* suites/os: Add testcase for RPi device-tree [Alexandru Costache]

# v2.91.4
## (2022-02-24)

* openvpn: Remove dependency on timesync-http target [Alex Gonzalez]

# v2.91.3
## (2022-02-24)

* tests/os: Wait for os-config-json service to be inactive [Kyle Harding]

# v2.91.2
## (2022-02-23)

* contributing-device-support.md: Updates to board support instructions [Florin Sarbu]

# v2.91.1
## (2022-02-21)

* tests/cloud: wait for update lock message in logs [rcooke-warwick]
* tests/cloud: register teardown before  online [rcooke-warwick]

# v2.91.0
## (2022-02-14)

* openssh: Add a dependency on os-sshkeys [Alex Gonzalez]
* balena-supervisor: Add dependency on root CA [Alex Gonzalez]
* balena: Add dependency on balena-hostname [Alex Gonzalez]
* Make services configurable [Alex Gonzalez]
* classes: Add balena-configurable [Alex Gonzalez]
* balena-config-vars: Split config.json configuration on write [Alex Gonzalez]
* Remove config-json.target [Alex Gonzalez]

# v2.90.0
## (2022-02-13)

* resin-init-flasher: check for UEFI mode and set config variables [Mark Corbin]
* resin-init-flasher: Fix flashing progress reporting for LUKS [Michal Toman]
* resin-init-flasher: Use flasher kernel to emulate stage2 bootloader with LUKS [Michal Toman]
* resin-init-flasher: Add support for opt-in full disk encryption [Michal Toman]

# v2.89.19
## (2022-02-13)

* README: Update versioning information [Alex Gonzalez]

# v2.89.18
## (2022-02-11)

* fix cloud suite teardown [rcooke-warwick]

# v2.89.17
## (2022-02-09)

* suites/hup: Add under-voltage test before and after HUP [Alexandru Costache]

# v2.89.16
## (2022-02-07)

* balena-supervisor: Update balena-supervisor to v12.11.32 [Felipe Lalanne]

# v2.89.15
## (2022-02-07)

* resindataexpander: do not return after resizing the partition only [Michal Toman]

# v2.89.14
## (2022-02-03)

* resin-u-boot.bbclass: Do not error if no config_defaults.h [Florin Sarbu]

# v2.89.13
## (2022-02-01)

* docker-disk: Tag the supervisor digest with the repo name [Kyle Harding]

# v2.89.12
## (2022-01-31)

* resindataexpander: expand fs independent of partition [Joseph Kogut]

# v2.89.11
## (2022-01-29)

* image_types_balena: Augment dependency on u-boot do_deploy task [Florin Sarbu]

# v2.89.10
## (2022-01-28)

* tests: relax boot splash screen check [rcooke-warwick]

# v2.89.9
## (2022-01-27)

* archive logs using local ssh [rcooke-warwick]
* put archiver in the right place [rcooke-warwick]
* Enable UART serial console for supported devices [Kyle Harding]
* archive image on teardown [rcooke-warwick]
* put device in dev mode [rcooke-warwick]
* tests: add extra logging to cloud suite [rcooke-warwick]

# v2.89.8
## (2022-01-27)

* u-boot: Move config fragments merging code out of common layer [Florin Sarbu]

# v2.89.7
## (2022-01-26)

* explain balenaRootCA better [Martin Rauscher]

# v2.89.6
## (2022-01-26)

* classes/kernel-balena: Update aufs patches for kernel 5.10.82 [Alexandru Costache]

# v2.89.5
## (2022-01-24)

* os: tests: optimize fingerprint tests [Joseph Kogut]

# v2.89.4
## (2022-01-21)

* tests: add cloud test suite [rcooke-warwick]

# v2.89.3
## (2022-01-20)

* initramfs-framework: Make cleaning udev database the last step [Alex Gonzalez]

# v2.89.2
## (2022-01-20)

* recipes-core/jq: Use 64bit time symbols [Alexandru Costache]

# v2.89.1
## (2022-01-19)

* tests: Enable UART serial console where supported [Kyle Harding]

# v2.89.0
## (2022-01-19)

* docker-disk: Pull images from Balena's registry [Alex Gonzalez]
* balena-supervisor: Use image location path instead of repository:tag [Alex Gonzalez]
* distro: balena-os: Add default cloud environment distro setting [Alex Gonzalez]

# v2.88.22
## (2022-01-18)

* intel-quark: Fix to honister syntax [Alex Gonzalez]
* recipes-core/bash: Use 64bit time symbols [Alexandru Costache]
* recipes-core/busybox: Use 64bit time symbols [Alexandru Costache]

# v2.88.21
## (2022-01-17)

* tests: os: config-json: cleanup persistentLogging test [Joseph Kogut]
* tests: os: config-json: return promise from sshKeys test [Joseph Kogut]
* tests: os: config-json: cleanup dnsServers config test [Joseph Kogut]
* tests: os: config-json: cleanup ntpServer config test [Joseph Kogut]
* tests: os: config-json: cleanup hostname config test [Joseph Kogut]
* tests: os: create waitForServiceState helper [Joseph Kogut]
* tests: os: config-json: remove reboot from randomMacAddressScan test [Joseph Kogut]
* tests: os: config-json: remove reboot from connectivity test [Joseph Kogut]
* tests: os: config-json: remove reboot from udevRules test [Joseph Kogut]

# v2.88.20
## (2022-01-17)

* chrony: fix mount service dependency for driftfile [Mark Corbin]

# v2.88.19
## (2022-01-12)

* os: tests: optimize fsck tests [Joseph Kogut]

# v2.88.18
## (2022-01-11)

* conf/distro: Prefer rust v1.36 for releases older than Honister [Alexandru Costache]

# v2.88.17
## (2022-01-10)

* recipes-core/coreutils: Use 64bit time symbols [Alexandru Costache]
* classes/image_types_balena: Preserve file modification times with mcopy [Alexandru Costache]

# v2.88.16
## (2022-01-05)

* balena-os.inc: Switch balena backend storage to overlay2 [Florin Sarbu]

# v2.88.15
## (2022-01-04)

* initrdscripts: fsuuidinit: Generate resin-rootA last [Alex Gonzalez]
* lvm2: Add rule to persist dm devices in udev database [Alex Gonzalez]
* initrdscript: Cleanup udev database before transitioning to rootfs [Alex Gonzalez]
* initrdscripts: Use /run as bootparam_root storage [Alex Gonzalez]
* lvm: Add lvm rules when secure boot is configured [Alex Gonzalez]
* balena-keys: Fetch DER keys and decode from base64 [Alex Gonzalez]

# v2.88.14
## (2022-01-04)

* Sync cached writes to disk when updating supervisor.conf [Miguel Casqueira]

# v2.88.13
## (2022-01-04)

* hostapp-update-hooks: Handle developmentMode updates [Alex Gonzalez]

# v2.88.12
## (2022-01-03)

* systemd/timeinit: handle missing date field in HTTPS header [Mark Corbin]

# v2.88.11
## (2021-12-22)

* balena-supervisor: Update balena-supervisor to v12.11.16 Update balena-supervisor from 12.11.0 to 12.11.16 [Miguel Casqueira]

# v2.88.10
## (2021-12-16)

* Update NetworkManager to 1.32.12 [Zahari Petkov]

# v2.88.9
## (2021-12-15)

* u-boot: Move u-boot configs inclusion into resin-u-boot.bbclass [Florin Sarbu]

# v2.88.8
## (2021-12-09)

* patch: Add archiveLogs Teardown for HUP suite [Vipul Gupta]

# v2.88.7
## (2021-12-06)

* tests: Ensure BDADDR is initialized [Alexandru Costache]

# v2.88.6
## (2021-12-04)

* docs: Fix links in Rollback documentation [Kyle Harding]

# v2.88.5
## (2021-12-04)

* tests: os: fix unhandled exception when unwrapping non-flasher image [Joseph Kogut]

# v2.88.4
## (2021-12-03)

* tests: Add basic checks for data loss during HUP [Kyle Harding]
* hostapp-update-hooks: Ensure data breadcrumb is present before HUP [Kyle Harding]

# v2.88.3
## (2021-12-02)

* grub-conf: Delay grub boot in os development mode [Alex Gonzalez]
* grub-efi: Allow input/output in OS development mode [Alex Gonzalez]

# v2.88.2
## (2021-12-02)

* sign-efi.bbclass: Do not deploy the unused .signed symlink [Michal Toman]
* sign-gpg.bbclass: Only deploy the detached signature [Michal Toman]
* kernel-image-initramfs.bb: Ship kernel and matching signature [Michal Toman]
* Make kexec work under kernel lockdown [Michal Toman]

# v2.88.1
## (2021-12-02)

* bluez5: Update to bluez 5.61 from poky honister [Kyle Harding]

# v2.88.0
## (2021-12-01)

* systemd/timeinit: add HTTPS time synchronisation service [Mark Corbin]

# v2.87.32
## (2021-12-01)

* tests: Add BeagleBone Black u-boot overlay test [Florin Sarbu]

# v2.87.31
## (2021-11-30)

* resin-update-state.rules: do not run for unnamed partitions [Michal Toman]
* resin_update_state_probe: do not skip device mapper devices [Michal Toman]

# v2.87.30
## (2021-11-30)

* tests: Add device specific RevPi Core 3 DIO module test [Alexandru Costache]

# v2.87.29
## (2021-11-29)

* common: image-balena: enable developmentMode when OS_DEVELOPMENT=1 [Joseph Kogut]

# v2.87.28
## (2021-11-26)

* Add secure boot keys to the flasher boot partition [Alex Gonzalez]

# v2.87.27
## (2021-11-25)

* balena-os: make sure PAM support is not configured [Alex Gonzalez]

# v2.87.26
## (2021-11-25)

* tests: add test for filesystem checks [Joseph Kogut]
* common: initrdscript: fsck resin-data on boot [Joseph Kogut]

# v2.87.25
## (2021-11-25)

* connectivity: reduce ping interval to minimum [Joseph Kogut]

# v2.87.24
## (2021-11-24)

* tests: Fix dnsmasq tests in cases where 8.8.8.8 is assigned via DHCP [Kyle Harding]

# v2.87.23
## (2021-11-24)

* 0-signed-update HUP hook: mount efivarfs if necessary [Michal Toman]

# v2.87.22
## (2021-11-24)

* grub-efi: Accept no input and output nothing when in secure boot mode [Michal Toman]

# v2.87.21
## (2021-11-24)

* linux-firmware: Include MT7601U firmware [Zahari Petkov]

# v2.87.20
## (2021-11-23)

* balena-image: Add balena keys to boot partition if required [Alex Gonzalez]
* grub-conf: Enforce module signing and integrity lockdown on luks config [Alex Gonzalez]
* distro: balena-os: Add empty SIGN_API [Alex Gonzalez]
* classes: image-balena: Copy signed files if present [Alex Gonzalez]
* classes/sign-gpg: Rename class to sign_gpg [Alex Gonzalez]
* classes: Rename sign to sign-gpg [Alex Gonzalez]
* classes: sign: Drop suffix from deployed files [Alex Gonzalez]
* resin-init-flasher: Set fde grub.cfg if secure boot is enabled [Alex Gonzalez]
* balena-image-initramfs: Add secure boot dependencies [Alex Gonzalez]
* kernel-image-initramfs: Install signed kernel images if available [Alex Gonzalez]
* kernel-balena: Configure for secure boot [Alex Gonzalez]

# v2.87.19
## (2021-11-22)

* common: enable multi-label mDNS resolution and IPv6 [Joseph Kogut]

# v2.87.18
## (2021-11-22)

* unwrap flasher images in os suite if needed [rcooke-warwick]
* bluetooth and hup test with qemu [rcooke-warwick]

# v2.87.17
## (2021-11-21)

* efitools: Add recipe [Alex Gonzalez]
* sbsigntool: Add recipe [Alex Gonzalez]

# v2.87.16
## (2021-11-21)

* peak: Modify kernel driver to use signing class [Alex Gonzalez]

# v2.87.15
## (2021-11-21)

* kernel-balena.class: Add support for FDE and sign for secure boot [Michal Toman]

# v2.87.14
## (2021-11-21)

* sign-efi.bbclass: do not mix old and new bitbake syntax [Michal Toman]
* Revert "sign-efi.class, sign-kmod.class: Replace original files with signed ones" [Michal Toman]

# v2.87.13
## (2021-11-20)

* meta-resin-sumo/pyro: Fix initramfs-framework kexec dependencies [Alex Gonzalez]
* initrdscripts: Use a 2nd stage bootloader to unlock LUKS partitions [Michal Toman]
* grub-efi: add support for signature verification in secure boot mode [Michal Toman]

# v2.87.12
## (2021-11-20)

* initramfs-module-cryptsetup: add TPM dependencies [Michal Toman]

# v2.87.11
## (2021-11-20)

* balena-keys: Add recipe [Alex Gonzalez]

# v2.87.10
## (2021-11-20)

* sign-efi.class, sign-kmod.class: Replace original files with signed ones [Michal Toman]
* Add signing classes [Alex Gonzalez]

# v2.87.9
## (2021-11-17)

* hostapp-update-hooks: Add a hook that aborts HUP to unsigned OS under secure boot [Michal Toman]

# v2.87.8
## (2021-11-17)

* resin-mounts: mount EFI partition if it is split from boot [Michal Toman]

# v2.87.7
## (2021-11-16)

* initrdscripts: add a script for unlocking LUKS volumes [Michal Toman]

# v2.87.6
## (2021-11-15)

* connectivity: proxy: move nadoo/glider to container [Joseph Kogut]

# v2.87.5
## (2021-11-11)

* tests: os: Add exposed engine socket test [Alex Gonzalez]

# v2.87.4
## (2021-11-11)

* resindataexpander: also resize LUKS volume if necessary [Michal Toman]

# v2.87.3
## (2021-11-11)

* Add out-of-tree peak CAN driver [Michal Toman]

# v2.87.2
## (2021-11-11)

* Add recipes for TPM2 tools [Michal Toman]

# v2.87.1
## (2021-11-10)

* recipes-devtools/dosfstools: Fix build with Poky Honister [Alexandru Costache]

# v2.87.0
## (2021-11-09)

* meta-balena-common/conf: Switch layer to Honister compatibility [Alexandru Costache]

# v2.86.3
## (2021-11-09)

* patch: Fix URL to yocto project dependencies [Kyle Harding]

# v2.86.2
## (2021-11-08)

* dosfstools: selectively apply upstreamed patch [Joseph Kogut]
* tests: wait for the chronyd service become active [Mark Corbin]

# v2.86.1
## (2021-11-02)

* tests/issue: Add test to check issues files [Alex Gonzalez]
* base files: Use HOSTOS_VERSION in issue and issue.net [Alex Gonzalez]

# v2.86.0
## (2021-10-29)

* Create new data partition reset service [Kyle Harding]

# v2.85.17
## (2021-10-28)

* restrict dtoverlay test to rpi devices [rcooke-warwick]

# v2.85.16
## (2021-10-27)


<details>
<summary> Update balena-engine to v19.03.30 [Robert Günzler] </summary>

> ## balena-engine-19.03.30
> ### (2021-10-26)
> 
> * storagemigration: keep going if migration fails [Robert Günzler]
> * graphdriver/copy: fix handling of sockets [Robert Günzler]
> 
</details>

# v2.85.15
## (2021-10-26)

* linux-firmware: Include RTL8723BU firmware files [Zahari Petkov]

# v2.85.14
## (2021-10-25)

* balena-supervisor: Update balena-supervisor to v12.11.0 [Felipe Lalanne]

# v2.85.13
## (2021-10-21)

* balena-engine: Remove deprecated development drop-in service file [Kyle Harding]

# v2.85.12
## (2021-10-21)

* make led test work with beaglebone [rcooke-warwick]

# v2.85.11
## (2021-10-06)

* patch: Add dtoverlay practical test [Vipul Gupta (@vipulgupta2048)]

# v2.85.10
## (2021-10-04)

* image-balena: Decouple boot directory generation from rootfs task [Alex Gonzalez]

# v2.85.9
## (2021-10-01)

* classes/resin-u-boot: Increase OS_BOOTCOUNT_LIMIT to 3 [Alexandru Costache]

# v2.85.8
## (2021-09-29)

* hostapp-update-hooks: Blacklist Rock Pi configuration file [Alexandru Costache]

# v2.85.7
## (2021-09-28)

* balena-healthcheck: Remove redundant steps and rely on hello-world [Kyle Harding]

# v2.85.6
## (2021-09-27)

* kernel-balena: Fix kernel config warning for UPROBE_EVENTS [Alex Gonzalez]
* kernel-balena: Configure DEBUG_FS [Alex Gonzalez]

# v2.85.5
## (2021-09-23)

* Run iwlwifi firmware cleanup in fakeroot [Kyle Harding]

# v2.85.4
## (2021-09-21)

* common: conf: create disable-user-ns distro feature [Joseph Kogut]

# v2.85.3
## (2021-09-21)

* balena-os-sysctl: Reduce the console default loglevel [Alex Gonzalez]
* balena-config-vars: Re-run os-sshkeys if config.json is modified [Alex Gonzalez]
* systemd: Use drop-in to modify unit files instead of sed [Alex Gonzalez]

# v2.85.2
## (2021-09-17)


<details>
<summary> Update balena-engine to v19.03.29 [Robert Günzler] </summary>

> ## balena-engine-19.03.29
> ### (2021-09-14)
> 
> * pkg/storagemigration: use graphdriver/copy.DirCopy [Robert Günzler]
> 
> ## balena-engine-19.03.28
> ### (2021-09-14)
> 
> * Prune Jenkinsfile [Robert Günzler]
> 
> ## balena-engine-19.03.27
> ### (2021-09-01)
> 
> * Backport platform-detection fixes from containerd [Robert Günzler]
> 
</details>

# v2.85.1
## (2021-09-17)

* Fix typo in OS_DEVELOPMENT distro feature [Kyle Harding]
* tests: Remove OS variants [Alex Gonzalez]

# v2.85.0
## (2021-09-15)

* Replace image variants with development mode [Alex Gonzalez]

<details>
<summary> balena-supervisor: Update balena-supervisor to v12.10.10 [Alex Gonzalez] </summary>

> ## balena-supervisor-12.10.10
> ### (2021-09-07)
> 
> * api-keys: Remove os variant parameter for authentication check [Alex Gonzalez]
> * os-release: Use developmentMode to ascertain OS variant in new releases [Alex Gonzalez]
> * config: Add developmentMode to schema [Alex Gonzalez]
> 
> ## balena-supervisor-12.10.9
> ### (2021-09-02)
> 
> * Update URL to balena-proxy-config source code [Kyle Harding]
> 
> ## balena-supervisor-12.10.8
> ### (2021-09-01)
> 
> * Bump path-parse from 1.0.6 to 1.0.7 [dependabot[bot]]
> 
> ## balena-supervisor-12.10.7
> ### (2021-09-01)
> 
> * Bump tar from 4.4.13 to 4.4.19 [dependabot[bot]]
> 
> ## balena-supervisor-12.10.6
> ### (2021-09-01)
> 
> * Remove "variable list" heading in configuration doc [Miguel Casqueira]
> 
> ## balena-supervisor-12.10.5
> ### (2021-08-31)
> 
> * Clean up configurations.md [Miguel Casqueira]
> 
> ## balena-supervisor-12.10.4
> ### (2021-08-31)
> 
> * Include issues with downgrading versions in README [Miguel Casqueira]
> 
</details>

* u-boot: Introduce a compile time osdev-image feature [Alex Gonzalez]
* os-release: Remove image variants information [Alex Gonzalez]
* Replace DEVELOPMENT_IMAGE and image variants with OS_DEVELOPMENT [Alex Gonzalez]
* images: Remove debug-tweaks settings. [Alex Gonzalez]
* openssh: Enable runtime development configuration [Alex Gonzalez]
* balena-info: Rename from resin-info [Alex Gonzalez]
* balena: Expose engine socket on development mode [Alex Gonzalez]
* image-balena: Allow passwordless root logins [Alex Gonzalez]
* image_balena: Remove "balena" hostname from development images [Alex Gonzalez]
* systemd: Runtime enablement of serial console [Alex Gonzalez]
* development-features: Add service for development features runtime management [Alex Gonzalez]

# v2.84.7
## (2021-09-13)

* hostapp-update-hooks: Fix blacklisted extlinux.conf file path [Alexandru Costache]

# v2.84.6
## (2021-09-11)

* balena-persistent-logs: add comment and update logging [Mark Corbin]
* meta-balena: rename resin-persistent-logs [Mark Corbin]

# v2.84.5
## (2021-09-10)

* tests: led: require led property from device type [Joseph Kogut]

# v2.84.4
## (2021-09-09)

* tests: Remove reboots from redsocks test cases [Kyle Harding]

# v2.84.3
## (2021-09-09)

* tests: Prevent failure when journalctl has no logs for some boots [Kyle Harding]

# v2.84.2
## (2021-09-08)

* contributing-device-support.md: Updates to board support instructions [Florin Sarbu]

# v2.84.1
## (2021-09-05)

* tests: s/BALENA_MACHINE_NAME/BALENA_ARCH [Joseph Kogut]

# v2.84.0
## (2021-09-03)

* balena-engine: Enable storage migration [Robert Günzler]

<details>
<summary> Update balena-engine to v19.03.26 [Robert Günzler] </summary>

> ## balena-engine-19.03.26
> ### (2021-08-31)
> 
> * storagemigration: capture failcleanup logs in logfile [Robert Günzler]
> 
> ## balena-engine-19.03.25
> ### (2021-08-20)
> 
> * storagemigration: move logic to package [Robert Günzler]
> 
</details>

# v2.83.22
## (2021-09-02)

* tests: remove healthcheck test race condition [rcooke-warwick]

# v2.83.21
## (2021-09-01)

* tests: Register teardown only when DUT is reachable [rcooke-warwick]

# v2.83.20
## (2021-09-01)

* tests: Use new Archiver implementation & helpers [Vipul Gupta (@vipulgupta2048)]

# v2.83.19
## (2021-09-01)

* tests: List boots when collecting journal logs in hup suite [Kyle Harding]

# v2.83.18
## (2021-08-31)


<details>
<summary> balena-supervisor: Update balena-supervisor to v12.10.3 [Kyle Harding] </summary>

> ## balena-supervisor-12.10.3
> ### (2021-08-24)
> 
> * Skip restarting services if they are part of conf targets [Kyle Harding]
> 
> ## balena-supervisor-12.10.2
> ### (2021-08-02)
> 
> * Removed fire emoji prefix for firewall logs. [peakyDicers]
> 
> ## balena-supervisor-12.10.1
> ### (2021-08-02)
> 
> * Fix regression with local mode push [Felipe Lalanne]
> 
> ## balena-supervisor-12.10.0
> ### (2021-07-28)
> 
> * Remove comparison based on image, release, and service ids [Felipe Lalanne]
> 
> ## balena-supervisor-12.9.6
> ### (2021-07-26)
> 
> * Use tags to track supervised images in docker [Felipe Lalanne]
> 
> ## balena-supervisor-12.9.5
> ### (2021-07-22)
> 
> * Log the delta URL that will be downloaded on update [Felipe Lalanne]
> 
> ## balena-supervisor-12.9.4
> ### (2021-07-08)
> 
> * Fix db-helper module for tests [Felipe Lalanne]
> 
</details>

# v2.83.17
## (2021-08-31)

* Assign a fixed name to the balena-healthcheck container [Kyle Harding]

# v2.83.16
## (2021-08-31)

* kernel-modules-headers: Copy module.lds [Alex Gonzalez]

# v2.83.15
## (2021-08-30)

* kernel-balena: remove global blacklist of btrfs [Joseph Kogut]

# v2.83.14
## (2021-08-26)

* tests: remove reboot requirement from NTP server test [Mark Corbin]
* recipes-connectivity: fix auto-update when config.json changes [Mark Corbin]

# v2.83.13
## (2021-08-26)

* networkmanager: fix hostname race condition [Mark Corbin]

# v2.83.12
## (2021-08-25)

* tests: remove reboot requirement from hostname test [Mark Corbin]
* hostname: update system hostname when config.json changes [Mark Corbin]

# v2.83.11
## (2021-08-24)

* linux-firmware: Use wildcards when selecting files to package [Alex Gonzalez]
* linux-firmware: Add firmware compression support [Alex Gonzalez]
* kernel-balena: Support firmware compression from kernel version 5.3 [Alex Gonzalez]

# v2.83.10
## (2021-08-18)

* kernel-balena: Add function to conditionally configure based on version [Alex Gonzalez]
* kernel-balena: Split function to get kernel version from source [Alex Gonzalez]
* kernel-resin: Add as symlink to kernel-balena [Alex Gonzalez]
* kernel-balena: Replace and deprecate kernel-resin [Alex Gonzalez]

# v2.83.9
## (2021-08-17)

* recipes-connectivity: improve NTP dispatcher script [Mark Corbin]

# v2.83.8
## (2021-08-17)


<details>
<summary> Update balena-engine to v19.03.24 [Alex Gonzalez] </summary>

> ## balena-engine-19.03.24
> ### (2021-08-12)
> 
> * prevent slice oob access in concatReadSeekCloser [Martin Rauscher]
> 
</details>

# v2.83.7
## (2021-08-14)

* grub: don't package or install bindir utils [Joseph Kogut]

# v2.83.6
## (2021-08-13)

* balena-os-sysctl: disable user namespacing by default [Joseph Kogut]
* common: kernel-resin: enable user namespacing [Joseph Kogut]

# v2.83.5
## (2021-08-13)

* resin-u-boot.bbclass: Make console silencing change more resilient [Florin Sarbu]

# v2.83.4
## (2021-08-11)

* balena-os: pin linux-firmware to 20210511 from hardknott [Joseph Kogut]
* linux-firmware: upgrade 20190815 -> 20210511 [Joseph Kogut]

# v2.83.3
## (2021-08-05)

* supervisor: Consolidate supervisor container removal [Kyle Harding]

# v2.83.2
## (2021-08-05)

* tests: Fix insecure registry error [Robert Günzler]

# v2.83.1
## (2021-07-31)

* linux-firmware: package i915 generations separately [Joseph Kogut]

# v2.83.0
## (2021-07-29)

* Add support for rootfs on MD RAID1 [Michal Toman]

# v2.82.13
## (2021-07-29)

* tests: Symlink /dev/null instead of copying bash to break services [Michal Toman]

# v2.82.12
## (2021-07-24)

* common: grub: don't install sbin utils [Joseph Kogut]

# v2.82.11
## (2021-07-21)

* tests: Remove journalctl line limit from hup suite [Kyle Harding]
* tests: Enable rollback tests in hup suite [Kyle Harding]
* tests: Update smoke test conditions [Kyle Harding]
* tests: Add rollback tests to HUP suite [Kyle Harding]
* rollback-altboot: Fix minor typo in log message [Kyle Harding]

# v2.82.10
## (2021-07-20)

* tests: Remove reboot requirement from dnsmasq tests [Kyle Harding]

# v2.82.9
## (2021-07-16)

* patch: Make OS test suite compatible with current helpers [Vipul Gupta (@vipulgupta2048)]

# v2.82.8
## (2021-07-16)

* kernel-devsrc: Add upstream recipe from hardknott-3.3.1 for dunfell [Florin Sarbu]

# v2.82.7
## (2021-07-15)


<details>
<summary> Update balena-engine to v19.03.23 [Leandro Motta Barros] </summary>

> ## balena-engine-19.03.23
> ### (2021-07-12)
> 
> * Make layer download resuming more resilient [Leandro Motta Barros]
> 
> ## balena-engine-19.03.22
> ### (2021-06-30)
> 
> * Drop CODEOWNERS [Robert Günzler]
> 
> ## balena-engine-19.03.21
> ### (2021-06-25)
> 
> * Lock destination layers while delta is being processed [Robert Günzler]
> 
> ## balena-engine-19.03.20
> ### (2021-06-17)
> 
> * pkg/storagemigration: poperly handle errors during state creation [Robert Günzler]
> 
> ## balena-engine-19.03.19
> ### (2021-06-10)
> 
> * pkg/storagemigration: allow writing logs to separate file [Robert Günzler]
> * storagemigration: defer commit to next start [Robert Günzler]
> 
</details>

# v2.82.6
## (2021-07-15)

* dnsmasq: Restart when config.json changes [Kyle Harding]
* balena-config-vars: Restart target when config.json changes [Kyle Harding]
* balena-config-vars: Add config-json.target service [Kyle Harding]
* balena-config-vars: Restore null as valid for dnsServers [Kyle Harding]

# v2.82.5
## (2021-07-15)

* kernel-headers-test: Update base image to buster [Florin Sarbu]

# v2.82.4
## (2021-07-14)

* tests: Add hup test suite [Robert Günzler]

# v2.82.3
## (2021-07-13)

* Check that the hostapp image fits the inactive partion on HUP [Alex Gonzalez]
* image-balena: Add check for docker image size [Alex Gonzalez]
* balena-image: Break down the rootfs image size calculation [Alex Gonzalez]
* image_types_balena: Add rootfs size calculation function [Alex Gonzalez]

# v2.82.2
## (2021-07-13)

* Update balena-supervisor from v12.8.8 to v12.9.3 [Miguel Casqueira]

# v2.82.1
## (2021-07-12)

* balena-hostname: add comments and improve logging [Mark Corbin]
* meta-balena: rename resin-hostname to balena-hostname [Mark Corbin]

# v2.82.0
## (2021-07-10)

* networkmanager: Rename references to resin [Kyle Harding]
* resin-proxy-config: Rename to balena-proxy-config [Kyle Harding]
* resin-ntp-config: Rename to balena-ntp-config [Kyle Harding]
* resin-net-config: Rename to balena-net-config [Kyle Harding]

# v2.81.1
## (2021-07-09)

* balena-engine: Restore previous systemd service settings [Kyle Harding]

# v2.81.0
## (2021-07-06)

* recipes-core: add a 'network connectivity wait' service [Mark Corbin]

# v2.80.12
## (2021-07-05)

* Remove CODEOWNERS [Michal Toman]

# v2.80.11
## (2021-07-01)

* get journal logs at the end of the suite [rcooke-warwick]

# v2.80.10
## (2021-06-24)

* hostapp-update-hooks: Migrate supervisor database [Kyle Harding]
* hostapp-update-hooks: Revert sv database path used by previous hooks [Kyle Harding]

# v2.80.9
## (2021-06-21)

* balena-engine: refactor systemd service [Robert Günzler]

# v2.80.8
## (2021-06-21)

* Update balena-supervisor from v12.8.7 to v12.8.8 [Florin Sarbu]

# v2.80.7
## (2021-06-18)

* prevent failed teardown from making test hang [rcooke-warwick]

# v2.80.6
## (2021-06-17)

* catch error if image path is corrupted [rcooke-warwick]

# v2.80.5
## (2021-06-17)

* update-balena-supervisor: Improve obtaining the supervisor directory name [Alexandru Costache]
* Update balena-supervisor from v12.7.0 to v12.8.7 [Miguel Casqueira]

# v2.80.4
## (2021-06-14)

* kernel-headers-test: simplify example module Makefile [Joseph Kogut]

# v2.80.3
## (2021-06-10)

* Add oneshot service to migrate supervisor state config [Kyle Harding]

# v2.80.2
## (2021-06-09)

* update-balena-supervisor: Refactor script to ensure target version is ran [Alexandru Costache]

# v2.80.1
## (2021-06-07)

* bluez5: Disable PnP Device Information service [Zahari Petkov]

# v2.80.0
## (2021-06-07)

* Revert Go 1.16 recipes [Joseph Kogut]

# v2.79.10
## (2021-06-03)

* supervisor: Remove symlink to legacy resin sysconfig [Kyle Harding]
* hostapp-update-hooks: Migrate resin-supervisor to balena-supervisor [Kyle Harding]
* supervisor: Remove legacy resin supervisor container [Kyle Harding]

# v2.79.9
## (2021-06-03)

* hostapp-update-hooks: Sync to disk when hook is done [Alex Gonzalez]
* extract-balena-ca: Sync changes to disk in case of power loss [Alex Gonzalez]
* resin-net-config: Make sure to sync changes to disk in case of power loss [Alex Gonzalez]

# v2.79.8
## (2021-06-02)

* bluez: Set policy configuration to AutoEnable [Alex Gonzalez]
* bluez5: Replace executable path directory in unit file [Alex Gonzalez]

# v2.79.7
## (2021-05-26)

* meta-balena: rename connectivity packagegroup [Mark Corbin]

# v2.79.6
## (2021-05-26)

* bluez5: Use bluez5 recipe from poky master [Zahari Petkov]

# v2.79.5
## (2021-05-21)

* README: Update supported Yocto versions [Alex Gonzalez]

# v2.79.4
## (2021-05-21)

* Skip some services when running under docker [Robert Günzler]

# v2.79.3
## (2021-05-20)

* kernel-resin: disable panic on hung task [Joseph Kogut]

# v2.79.2
## (2021-05-19)

* Add boot-splash test to unmanaged suite [rcooke-warwick]

# v2.79.1
## (2021-05-18)

* balena-os: Add preferred provider for Go native [Alex Gonzalez]

# v2.79.0
## (2021-05-13)

* balena-engine: build in GOPATH mode [Joseph Kogut]
* recipes-devtools: go: backport get_linuxloader [Joseph Kogut]
* meta-resin-pyro: go-native: include fix-goarch.inc [Joseph Kogut]
* meta-balena-common: upgrade from go 1.12.17 to 1.16.2 [Joseph Kogut]

# v2.78.2
## (2021-05-13)

* balena-config-vars: improve handling of NM config parameters [Mark Corbin]

# v2.78.1
## (2021-05-12)

* Add Device Tree tests [Vipul Gupta (@vipulgupta2048)]

# v2.78.0
## (2021-05-10)

* Add symlinks and aliases for legacy resin namespaces [Kyle Harding]
* Rename resin-supervisor to balena-supervisor [Kyle Harding]

# v2.77.2
## (2021-05-10)


<details>
<summary> Update balena-supservisor from v12.5.10 to v12.7.0 [Kyle Harding] </summary>

> ## balena-supervisor-12.7.0
> ### (2021-05-07)
> 
> * Backwards compatility changes for old resin namespaces [Kyle Harding]
> * Change container name to balena_supervisor [Kyle Harding]
> * Rename resin-supervisor to balena-supervisor [Kyle Harding]
> 
> ## balena-supervisor-12.6.8
> ### (2021-05-06)
> 
> * Show warning instead of exception for invalid network config [Felipe Lalanne]
> 
> ## balena-supervisor-12.6.7
> ### (2021-05-06)
> 
> * Patch awaiting response when checking if supervisor0 network exists [Miguel Casqueira]
> 
> ## balena-supervisor-12.6.6
> ### (2021-05-06)
> 
> * Fix parsing driver_opts from compose to docker network creation [quentinGllmt]
> 
> ## balena-supervisor-12.6.5
> ### (2021-05-06)
> 
> 
> <details>
> <summary> Update balena-register-device and send extra info at provision time [Pagan Gazzard] </summary>
> 
>> ### balena-register-device-7.2.0
>> #### (2021-04-29)
>> 
>> * Support `supervisorVersion`/`osVersion`/`osVariant`/`macAddress` fields [Pagan Gazzard]
>> 
>> ### balena-register-device-7.1.1
>> #### (2021-04-29)
>> 
>> * Update dependencies [Pagan Gazzard]
>> 
>> ### balena-register-device-7.1.0
>> #### (2020-07-13)
>> 
>> * Switch from randomstring to uuid for generating device uuids [Pagan Gazzard]
>> 
>> ### balena-register-device-7.0.1
>> #### (2020-07-13)
>> 
>> * Add .versionbot/CHANGELOG.yml for nested changelogs [Pagan Gazzard]
>> 
>> ### balena-register-device-7.0.0
>> #### (2020-07-06)
>> 
>> * Convert to type checked javascript [Pagan Gazzard]
>> * Drop callback interface in favor of promise interface [Pagan Gazzard]
>> * Switch to a named export [Pagan Gazzard]
>> * Convert to typescript [Pagan Gazzard]
>> * Update to typed-error 3.x [Pagan Gazzard]
>> * Switch to returning native promises [Pagan Gazzard]
>> * Update to balena-request 11.x [Pagan Gazzard]
>> * Use typescript import helpers [Pagan Gazzard]
>> 
> </details>
> 
> 
> ## balena-supervisor-12.6.4
> ### (2021-05-05)
> 
> * Log error responses from API when reporting state [Felipe Lalanne]
> 
> ## balena-supervisor-12.6.3
> ### (2021-05-04)
> 
> * Added configurations.md to document all configurable vars [Miguel Casqueira]
> 
> ## balena-supervisor-12.6.2
> ### (2021-04-30)
> 
> * Remove version tag from livepush generated image [Felipe Lalanne]
> 
> ## balena-supervisor-12.6.1
> ### (2021-04-27)
> 
> * Remove mz, mkdirp, body-parser dependencies [Christina Wang]
> 
> ## balena-supervisor-12.6.0
> ### (2021-04-27)
> 
> * Bump dockerode types to 2.5.34 [Felipe Lalanne]
> 
> ## balena-supervisor-12.5.16
> ### (2021-04-27)
> 
> * Enable docker layer caching on CircleCI [Miguel Casqueira]
> 
> ## balena-supervisor-12.5.15
> ### (2021-04-26)
> 
> * Added clean step to remove previous builds before running tests [Miguel Casqueira]
> 
> ## balena-supervisor-12.5.14
> ### (2021-04-26)
> 
> * balena-supervisor: replace references to resin-vars [Mark Corbin]
> 
> ## balena-supervisor-12.5.13
> ### (2021-04-25)
> 
> * Update supervisor to typescript 4 [Felipe Lalanne]
> 
> ## balena-supervisor-12.5.12
> ### (2021-04-20)
> 
> * Bump ssri from 6.0.1 to 6.0.2 [dependabot[bot]]
> 
> ## balena-supervisor-12.5.11
> ### (2021-04-14)
> 
> * Refactor extra_uEnv to not match with intel nuc [Miguel Casqueira]
> 
</details>

# v2.77.1
## (2021-05-10)

* Update os-config from v1.2.0 to v1.2.1 [Kyle Harding]

# v2.77.0
## (2021-05-05)

* grub update hook: move variables from grub.cfg to grubenv [Michal Toman]

# v2.76.0
## (2021-04-30)

* kernel: Always include overlayfs support [Robert Günzler]

# v2.75.1
## (2021-04-29)

* grub: grub-efi: buildin gzio for gz compressed kernels [Joseph Kogut]

# v2.75.0
## (2021-04-22)

* Update mobynit to the new multi-container hostOS specification [Alex Gonzalez]

# v2.74.0
## (2021-04-20)

* balena-engine: Update to 19.03.18 [Robert Günzler]

# v2.73.15
## (2021-04-20)

* modemmanager:u-blox-switch: Rework the u-blox modem switch to ECM mode [Florin Sarbu]

# v2.73.14
## (2021-04-19)

* device-progress: do not force an exit code [Matthew McGinn]

# v2.73.13
## (2021-04-19)

* add retries to status check [rcooke-warwick]

# v2.73.12
## (2021-04-16)

* meta-balena: rename resin-vars to balena-config-vars [Mark Corbin]

# v2.73.11
## (2021-04-16)

* patch: Add strict bootcount count condition [Vipul Gupta (@vipulgupta2048)]
* patch: Reactivate Persistent Logging test [Vipul Gupta (@vipulgupta2048)]

# v2.73.10
## (2021-04-14)

* repo.yml: Move balena-supervisor reference to balena-os [Alex Gonzalez]

# v2.73.9
## (2021-04-14)

* Update balena-supervisor from v12.5.6 to v12.5.10 [Christina Wang]

# v2.73.8
## (2021-04-13)

* resin-mounts/etc-fake-hwclock: add dependency on resin-state services [Mark Corbin]

# v2.73.7
## (2021-04-13)

* fix udev test indentation [rcooke-warwick]
* Added comments for easier debugging [rcooke-warwick]
* Fix old tests + add new tests based on testlodge [rcooke-warwick]

# v2.73.6
## (2021-04-12)

* Add automated test checking for udev/resin_update_state_probe warnings [Michal Toman]
* udev: Silence warnings from resin_update_state_probe [Michal Toman]

# v2.73.5
## (2021-04-06)

* Update balena-supervisor from v12.4.6 to v12.5.6 [Christina Wang]

# v2.73.4
## (2021-03-20)

* Add to persistent logging defn [Andrew Nhem]

# v2.73.3
## (2021-03-19)

* wifi: remove listed example as it's discontinued [Tomás Migone]

# v2.73.2
## (2021-03-17)

* hostapp-update: convert absolute symlinks to relative [Joseph Kogut]

# v2.73.1
## (2021-03-16)

* Update balena-supervisor from v12.3.5 to v12.4.6 [Felipe Lalanne]

# v2.73.0
## (2021-03-15)

* image_types_balena: make rootfs labeling generic [Joseph Kogut]
* image_types_balena: make agnostic to root fstype [Joseph Kogut]
* mkfs-hostapp-native: make agnostic to fstype [Joseph Kogut]

# v2.72.2
## (2021-03-15)

* balena: dissolve healthcheck-image-load into healthcheck script [Robert Günzler]

# v2.72.1
## (2021-03-11)

* Fix disablement of userspace firmware loading requests [Pelle van Gils]

# v2.72.0
## (2021-03-10)


<details>
<summary> os-config: Update os-config from v1.1.4 to v1.2.0 [Kyle Harding] </summary>

> ## os-config-1.2.0
> ### (2021-02-23)
> 
> * os-config: rename flasher flag path [Kyle Harding]
> 
</details>

* Rename resin image types to balena [Kyle Harding]

# v2.71.7
## (2021-03-08)

* Apply aufs patches if aufs is present in kernel config [Kyle Harding]

# v2.71.6
## (2021-03-05)

* grub-efi: build required modules into grub image [Joseph Kogut]

# v2.71.5
## (2021-03-03)

* initrdscripts: always use by-uuid symlink looking for flasher rootfs [Michal Toman]

# v2.71.4
## (2021-03-01)

* Update OS test suite [Vipul Gupta (@vipulgupta2048)]

# v2.71.3
## (2021-02-26)

* balena: Make the healthcheck loading service part of balena.service [Robert Günzler]

# v2.71.2
## (2021-02-23)

* dnsmasq: enable dbus support [Kyle Harding]
* dnsmasq: update to 2.84 with dnspooq fix [Kyle Harding]

# v2.71.1
## (2021-02-23)

* recipes-bsp: grub: install only release modules [Joseph Kogut]

# v2.71.0
## (2021-02-15)

* meta-balena-common: add grub-efi support [Joseph Kogut]

# v2.70.2
## (2021-02-12)

* Update PR template to specify test coverage in more detail [Alex Gonzalez]
* Update codeowners [Alex Gonzalez]

# v2.70.1
## (2021-02-11)

* Add leviathan automated OS test suite [Vipul Gupta (@vipulgupta2048)]

# v2.70.0
## (2021-02-11)

* systemd/timeinit: use systemd mount unit for /etc/fake-hwclock [Mark Corbin]

# v2.69.1
## (2021-02-03)

* Update balena-supervisor from v12.3.0 to v12.3.5 [Miguel Casqueira]

# v2.69.0
## (2021-02-01)

* openvpn: remove resin-ntp-config call from upscript.sh [Mark Corbin]
* resin-vars: trigger NTP config script on config.json changes [Mark Corbin]
* resin-ntp-config: update script and add systemd service [Mark Corbin]
* networkmanager: add improved dispatcher scripts for NTP handling [Mark Corbin]
* chrony: add sourcedir support and helper script [Mark Corbin]

# v2.68.1
## (2021-01-29)

* Fix task ordering for the iwlwifi_firmware_clean task [Florin Sarbu]

# v2.68.0
## (2021-01-29)

* Update NetworkManager to 1.28.0 [Zahari Petkov]

# v2.67.6
## (2021-01-28)

* docs: mention balenaRootCA as a config.json parameter [Matthew McGinn]

# v2.67.5
## (2021-01-27)

* replace busybox ps with procps [klutchell] [Kyle Harding]

# v2.67.4
## (2021-01-27)

* Update aufs4 and aufs5 kernel patches [Florin Sarbu]

# v2.67.3
## (2021-01-15)

* kernel-headers-test: Install python dependency [Alexandru Costache]

# v2.67.2
## (2021-01-14)

* Fix pppd timeout when launched by NetworkManager [Zahari Petkov]

# v2.67.1
## (2021-01-13)

* resin-device-register: Fix post provisioning state not reported [Alexandru Costache]

# v2.67.0
## (2021-01-12)

* Update balena-supervisor from v12.2.11 to v12.3.0 [Felipe Lalanne]

# v2.66.3
## (2021-01-12)

* Respect custom CA in supervisor [Michal Toman]

# v2.66.2
## (2021-01-11)

* README: Rename resin-logo to balena-logo. [Alex Gonzalez]

# v2.66.1
## (2021-01-04)

* kernel-devsrc: use upstream recipe starting with dunfell [Kyle Harding]
* gen_mod_headers: add missing arch headers to tools [Kyle Harding]

# v2.66.0
## (2020-12-18)

* chrony: bump to version 4.0 [Mark Corbin]

# v2.65.1
## (2020-12-17)

* u-boot: Add required configuration for BalenaOS environment [Alex Gonzalez]

# v2.65.0
## (2020-12-14)

* Update balena-supervisor from v12.1.1 to v12.2.11 [Miguel Casqueira]

# v2.64.4
## (2020-12-14)

* Add IPV6 multicast routing capability [Alex Gonzalez]

# v2.64.3
## (2020-12-11)

* Revert "resin-data.mount: Remove default dependencies" [Alex Gonzalez]
* hostapp-update-hooks: Add supervisor database fix [Alex Gonzalez]
* resin-supervisor: Make sure the database directory exists [Alex Gonzalez]
* Correct the data partition mountpoint [Alex Gonzalez]

# v2.64.2
## (2020-12-10)

* meta-balena-common: kernel-resin: enable task-accounting by default [Joseph Kogut]
* meta-balena-common: kernel-resin: create task-accounting config [Joseph Kogut]

# v2.64.1
## (2020-12-09)

* Update codeowners [Alex Gonzalez]

# v2.64.0
## (2020-12-07)

* rust: remove merged fix for TUNE_FEATURES parsing [Kyle Harding]
* systemd: update patches to avoid fuzzy matching [Kyle Harding]
* systemd: add missing udev rules [Kyle Harding]
* systemd: avoid conflicts with timeinit package [Kyle Harding]
* dropbear: prevent conflicts with openssh [Kyle Harding]
* networkmanager: add bash requirement [Kyle Harding]
* networkmanager: remove deprecated bluetooth inherit [Kyle Harding]
* meta-balena-common: replace distro_features_check with features_check [Kyle Harding]
* avahi: remove example services [Kyle Harding]
* u-boot: disable u-boot-initial-env [Kyle Harding]
* dnsmasq: fix build after y2038 changes in glib [Kyle Harding]
* bluez5: replace experimental flag patch with service conf [Kyle Harding]
* mtools: remove initialize-direntry patch [Kyle Harding]
* meta-balena-dunfell: dunfell compatibility layer support [Kyle Harding]

# v2.63.1
## (2020-12-04)

* start-resin-supervisor: fix directory creation for 'balena start' [Mark Corbin]

# v2.63.0
## (2020-11-30)

* zram-swap-init: adjust default to lesser of 50%/4GB [Joseph Kogut]

# v2.62.2
## (2020-11-25)

* chrony: use a non-privileged UDP source port [Mark Corbin]

# v2.62.1
## (2020-11-19)

* supervisor: remove old/unnecessary balenaRootCA references [Matthew McGinn]

# v2.62.0
## (2020-11-13)

* systemd/timeinit: improve RTC handling at boot [Mark Corbin]
* os-helpers: add support functions for system date/time [Mark Corbin]

# v2.61.3
## (2020-11-05)

* modemmanager: add u-blox-modeswitch scripts [Mark Corbin]

# v2.61.2
## (2020-11-05)

* Check the API for configuration changes once a day [Michal Toman]

# v2.61.1
## (2020-11-04)

* Enable kernel user space probes support [Alex Gonzalez]

# v2.61.0
## (2020-11-04)


<details>
<summary> Update balena-supervisor from v11.14.0 to v12.1.1 [Cameron Diver] </summary>

> ## balena-supervisor-12.1.1
> ### (2020-10-28)
> 
> * Use root mount point to find device-type.json [Cameron Diver]
> 
> ## balena-supervisor-12.1.0
> ### (2020-10-28)
> 
> * Change log source from docker to journalctl [Thomas Manning]
> 
> ## balena-supervisor-12.0.9
> ### (2020-10-27)
> 
> * Change source of deviceType to device-type.json [Felipe Lalanne]
> 
> ## balena-supervisor-12.0.8
> ### (2020-10-26)
> 
> * Fixed evaluating if updates are needed to reach target state [Miguel Casqueira]
> 
> ## balena-supervisor-12.0.7
> ### (2020-10-19)
> 
> * Improved log message when networks do not match [Miguel Casqueira]
> 
> ## balena-supervisor-12.0.6
> ### (2020-10-16)
> 
> * Fixes check allowing preloading in local (unmanaged) mode [ab77]
> * Handle delete of multiple images with same dockerImageId [Felipe Lalanne]
> 
> ## balena-supervisor-12.0.5
> ### (2020-10-14)
> 
> * Improve calculation for used system memory [Felipe Lalanne]
> 
> ## balena-supervisor-12.0.4
> ### (2020-10-13)
> 
> * Don't require an existing supervisor container to sync [Cameron Diver]
> 
> ## balena-supervisor-12.0.3
> ### (2020-10-12)
> 
> * Refactor system information filtering [Cameron Diver]
> * tests: Clean up and consistify naming scheme [Cameron Diver]
> 
> ## balena-supervisor-12.0.2
> ### (2020-10-12)
> 
> * Attempt a state report once every maxReportFrequency [Cameron Diver]
> * Remove superfluous current state reporting code from api-binder [Cameron Diver]
> 
> ## balena-supervisor-12.0.1
> ### (2020-10-12)
> 
> * Add features label `io.balena.features.journal-logs` [Thomas Manning]
> 
> ## balena-supervisor-12.0.0
> ### (2020-09-29)
> 
> * version: drop SUPERVISOR_VERSION env var [Matthew McGinn]
> 
> ## balena-supervisor-11.14.8
> ### (2020-09-29)
> 
> * Fix supervisor deadlock during migration [Felipe Lalanne]
> 
> ## balena-supervisor-11.14.7
> ### (2020-09-25)
> 
> * Correctly evaluate if scheduledApply.delay is not set [Miguel Casqueira]
> 
> ## balena-supervisor-11.14.6
> ### (2020-09-24)
> 
> * Fix config checks for ConfigFS backend [Felipe Lalanne]
> 
> ## balena-supervisor-11.14.5
> ### (2020-09-24)
> 
> * mixpanel: superisor_version -> supervisor_version [Matthew McGinn]
> 
> ## balena-supervisor-11.14.4
> ### (2020-09-18)
> 
> * api: Implement scoped Supervisor API keys [Rich Bayliss]
> 
> ## balena-supervisor-11.14.3
> ### (2020-09-17)
> 
> * Clarify docs for toggling update lock override from dashboard [M. Casqueira]
> 
> ## balena-supervisor-11.14.2
> ### (2020-09-15)
> 
> * Refactor extra_uEnv backend to match with more devices [Miguel Casqueira]
> 
> ## balena-supervisor-11.14.1
> ### (2020-09-14)
> 
> * application-manager: Convert to a singleton [Rich Bayliss]
> * device-state: Convert to a singleton [Rich Bayliss]
> * api-binder: Convert to a singleton [Rich Bayliss]
> 
</details>

# v2.60.1
## (2020-10-30)

* chrony: set the source UDP port for NTP requests to 123 [Mark Corbin]

# v2.60.0
## (2020-10-29)

* chrony: don't restore time from drift file or RTC [Mark Corbin]
* systemd/timeinit: add fake.hwclock to maintain system time over reboots [Mark Corbin]
* resin-mounts: add bind mount service for /etc/fake-hwclock [Mark Corbin]

# v2.59.0
## (2020-10-27)

* Add host extensions support [Alex Gonzalez]
* packagegroup-resin: Add hostapp extensions update script [Alex Gonzalez]
* hostapp-extensions-update: Add host extensions update script [Alex Gonzalez]
* resin-vars: Parse the HOSTEXT_IMAGES variable from config.json [Alex Gonzalez]
* docker-disk: Add the host extension images to the data partition [Alex Gonzalez]
* docker-disk: Generalize hostapp platform variable [Alex Gonzalez]
* initrdscripts: Busybox switch_root does not support -c argument [Alex Gonzalez]
* resin-filesystem-expand: Omit fs check and resize if partition is mounted [Alex Gonzalez]
* initrdscripts: Expand the resin-data filesystem [Alex Gonzalez]
* initrdscripts: Add resin-data to fs UUID generation [Alex Gonzalez]
* resin-data.mount: Remove default dependencies [Alex Gonzalez]
* packagegroup-resin: Add independent mobynit package to image [Alex Gonzalez]
* balena-engine: Do not build mobynit [Alex Gonzalez]
* mobynit: Fix source directory [Alex Gonzalez]
* mobynit: Separate recipe from balena-engine [Alex Gonzalez]

# v2.58.6
## (2020-10-15)

* readme: DCHP -> DHCP [Matthew McGinn]

# v2.58.5
## (2020-10-13)

* bootfiles: blacklist proper grub configuration backend [Matthew McGinn]

# v2.58.4
## (2020-10-05)

* docker-disk: Allow expanding data filesystem on 2TB disks [Alexandru Costache]

# v2.58.3
## (2020-09-18)

* Blacklist supervisor configuration backend files during HUP [Alex Gonzalez]

# v2.58.2
## (2020-09-17)

* hooks: fix up improperly named variable [Matthew McGinn]

# v2.58.1
## (2020-09-15)

* Wait for the root device to come up when necessary [Michal Toman]

# v2.58.0
## (2020-09-05)

* Respect balenaRootCA system-wide [Michal Toman]

# v2.57.1
## (2020-09-04)

* os-helpers-logging: Log to stderr rather than stdout [Michal Toman]

# v2.57.0
## (2020-09-04)

* Update libmbim to 1.24.2, libqmi to 1.26.0, modemmanager to 1.14.2 [Vicentiu Galanopulo]

# v2.56.0
## (2020-09-03)


<details>
<summary> Update balena-supervisor from v11.13.0 to v11.14.0 [Cameron Diver] </summary>

> ## balena-supervisor-11.14.0
> ### (2020-09-03)
> 
> * Add device system information to state endpoint patch [Cameron Diver]
> 
</details>

# v2.55.0
## (2020-09-03)


<details>
<summary> Update balena-supervisor from v11.12.4 to v11.13.0 [Cameron Diver] </summary>

> ## balena-supervisor-11.13.0
> ### (2020-08-29)
> 
> * added support for configuring ODMDATA [Miguel Casqueira]
> 
> ## balena-supervisor-11.12.11
> ### (2020-08-27)
> 
> * bug: Resolve mDNS API URLs [Rich Bayliss]
> 
> ## balena-supervisor-11.12.10
> ### (2020-08-24)
> 
> * Preventing removing all configurations if device has no backends [Miguel Casqueira]
> 
> ## balena-supervisor-11.12.9
> ### (2020-08-20)
> 
> * Don't enforce the vc4-fkms-v3d dtoverlay on rpi4 [Cameron Diver]
> 
> ## balena-supervisor-11.12.8
> ### (2020-08-19)
> 
> 
> <details>
> <summary> Update dependencies [Pagan Gazzard] </summary>
> 
>> ### node-docker-delta-2.2.11
>> #### (2020-08-19)
>> 
>> * Add .versionbot/CHANGELOG.yml for nested changelogs [Pagan Gazzard]
>> 
>> ### node-docker-delta-2.2.10
>> #### (2020-08-05)
>> 
>> * Removed unused dependencies [Pagan Gazzard]
>> * circleci: update docker [Pagan Gazzard]
>> 
>> ### docker-progress-4.0.3
>> #### (2020-08-17)
>> 
>> * Update to balena-lint 5.x [Pagan Gazzard]
>> 
>> ### docker-progress-4.0.2
>> #### (2020-08-17)
>> 
>> * Add .versionbot/CHANGELOG.yml for nested changelogs [Pagan Gazzard]
>> 
>> ### docker-progress-4.0.1
>> #### (2020-03-04)
>> 
>> * Update dependencies [Pagan Gazzard]
>> 
>> ### docker-progress-4.0.0
>> #### (2019-03-26)
>> 
>> * Detect error events in push/pull progress streams [Paulo Castro]
>> 
>> ### docker-toolbelt-3.3.10
>> #### (2020-08-19)
>> 
>> * Add .versionbot/CHANGELOG.yml for nested changelogs [Pagan Gazzard]
>> 
>> ### docker-toolbelt-3.3.9
>> #### (2020-08-17)
>> 
>> * Update to balena-lint 5.x [Pagan Gazzard]
>> 
>> ### livepush-3.5.1
>> #### (2020-08-19)
>> 
>> * Add .versionbot/CHANGELOG.yml for nested changelogs [Pagan Gazzard]
>> 
>> ### livepush-3.5.0
>> #### (2020-07-13)
>> 
>> * Allow setting ENV variables in the live image [Roman Mazur]
>> * Bump dockerode types dependency [Roman Mazur]
>> 
>> ### livepush-3.4.1
>> #### (2020-05-05)
>> 
>> * Update README with information about live directives [Cameron Diver]
>> 
>> ### livepush-3.4.0
>> #### (2020-04-15)
>> 
>> * 🔭 Add a file watcher which can be used by library users [Cameron Diver]
>> 
>> ### resin-docker-build-1.1.6
>> #### (2020-08-19)
>> 
>> * Add .versionbot/CHANGELOG.yml for nested changelogs [Pagan Gazzard]
>> 
>> ### resin-docker-build-1.1.5
>> #### (2020-04-02)
>> 
>> * Update README with correct instantiation method [CameronDiver]
>> 
> </details>
> 
> 
> ## balena-supervisor-11.12.7
> ### (2020-08-19)
> 
> 
> <details>
> <summary> Update typed-error to 3.x [Pagan Gazzard] </summary>
> 
>> ### typed-error-3.2.1
>> #### (2020-08-05)
>> 
>> * Update dependencies [Pagan Gazzard]
>> 
>> ### typed-error-3.2.0
>> #### (2019-11-20)
>> 
>> * update deps and specify minimum engine requirements [Will Boyce]
>> 
>> ### typed-error-3.1.0
>> #### (2019-04-01)
>> 
>> * dev: Enforce prettier coding standards [Will Boyce]
>> * npm: Update dependencies and remove `package-lock.json` [Will Boyce]
>> * codeowners: Add top contributors @wrboyce, @Page-, and @dfunckt [Will Boyce]
>> * versionbot: Add CHANGELOG.yml (for nested changelogs) [Will Boyce]
>> 
>> ### typed-error-3.0.2
>> #### (2018-11-01)
>> 
>> * Update README with new import style [CameronDiver]
>> 
>> ### typed-error-3.0.1
>> #### (2018-10-29)
>> 
>> * Update to typescript 3 [Pagan Gazzard]
>> * Update dev dependencies [Pagan Gazzard]
>> * Add node-10 to the circle test suite [Pagan Gazzard]
>> 
>> ### typed-error-3.0.0
>> #### (2018-04-17)
>> 
>> * Distribute generated typescript declaration [Will Boyce]
>> * use circle for build/publish and add package-lock [Will Boyce]
>> * add lint scripts/requirements [Will Boyce]
>> * Remove `BaseError` class and  directly subclass `Error` [Will Boyce]
>> * Update dependencies, clean up package/tsconfig [Will Boyce]
>> 
>> ### typed-error-2.0.1
>> #### (2017-12-15)
>> 
>> * Add LICENSE [Akis Kesoglou]
>> 
> </details>
> 
> 
> ## balena-supervisor-11.12.6
> ### (2020-08-18)
> 
> 
> <details>
> <summary> Update pinejs-client-request to 7.2.1 [Pagan Gazzard] </summary>
> 
>> ### pinejs-client-request-7.2.1
>> #### (2020-08-18)
>> 
>> 
>> <details>
>> <summary> Update dependencies [Pagan Gazzard] </summary>
>> 
>>> #### pinejs-client-js-6.7.1
>>> ##### (2020-08-12)
>>> 
>>> * Fix prepare $count typings [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-6.7.0
>>> ##### (2020-08-12)
>>> 
>>> * Improve typings for request/post/put/patch/delete [Pagan Gazzard]
>>> 
>> </details>
>> 
>> 
>> ### pinejs-client-request-7.2.0
>> #### (2020-08-12)
>> 
>> 
>> <details>
>> <summary> Update pinejs-client-core to 6.6.1 [Pagan Gazzard] </summary>
>> 
>>> #### typed-error-3.2.1
>>> ##### (2020-08-05)
>>> 
>>> * Update dependencies [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-6.6.1
>>> ##### (2020-08-11)
>>> 
>>> * Fix typing when id is specified to be `AnyObject | undefined` [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-6.6.0
>>> ##### (2020-08-11)
>>> 
>>> * Deprecate `$expand: { 'a/$count': {...} }` [Pagan Gazzard]
>>> * Deprecate `resource: 'a/$count'` and update typings to reflect it [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-6.5.0
>>> ##### (2020-08-11)
>>> 
>>> * Add `options: { $count: { ... } }` sugar for top level $count [Pagan Gazzard]
>>> * Add `$expand: { a: { $count: { ... } } }` sugar for $count in expands [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-6.4.0
>>> ##### (2020-08-11)
>>> 
>>> * Improve return typing of `subscribe` method [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-6.3.0
>>> ##### (2020-08-11)
>>> 
>>> * Fix Poll.on typings [Pagan Gazzard]
>>> * Improve return typing when id is passed to GET methods [Pagan Gazzard]
>>> * Remove `PromiseResult` type, use `Promise<PromiseResultTypes>` instead [Pagan Gazzard]
>>> * Remove `PromiseObj` type, use `Promise<{}>` instead [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-6.2.0
>>> ##### (2020-08-10)
>>> 
>>> * Add `$filter: { a: { $count: 1 } }` sugar for $count in filters [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-6.1.2
>>> ##### (2020-08-10)
>>> 
>>> * Remove redundant ParamsObj/SubscribeParamsObj types [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-6.1.1
>>> ##### (2020-08-10)
>>> 
>>> * Make use of `mapObj` helper in more places [Pagan Gazzard]
>>> * Use `Object.keys` in preference to `hasOwnProperty` where applicable [Pagan Gazzard]
>>> 
>> </details>
>> 
>> 
> </details>
> 
> 
> ## balena-supervisor-11.12.5
> ### (2020-08-12)
> 
> * Refactor configurable backend class names [Miguel Casqueira]
> 
</details>

# v2.54.3
## (2020-08-25)

* Pack /lib/vdso/Makefile in kernel-modules-headers [Vicentiu Galanopulo]

# v2.54.2
## (2020-08-12)


<details>
<summary> balena-supervisor: Update to v11.12.4 [Alex Gonzalez] </summary>

> ## balena-supervisor-11.12.4
> ### (2020-08-12)
> 
> * bug: Firewall not blocking supervisor access from outside the device [Rich Bayliss]
> 
> ## balena-supervisor-11.12.3
> ### (2020-08-11)
> 
> * bug: Allow DNS through firewall for local containers [Rich Bayliss]
> 
</details>

# v2.54.1
## (2020-08-07)

* Package iwlwifi-cc-a0-48 firmware separately [Florin Sarbu]

# v2.54.0
## (2020-08-06)


<details>
<summary> Update balena-supervisor from v11.9.9 to v11.12.2 [Cameron Diver] </summary>

> ## balena-supervisor-11.12.2
> ### (2020-08-05)
> 
> * Fix device-tag fetching function [Cameron Diver]
> 
> ## balena-supervisor-11.12.1
> ### (2020-08-05)
> 
> 
> <details>
> <summary> Update resumable-request [Pagan Gazzard] </summary>
> 
>> ### resumable-request-2.0.1
>> #### (2020-08-05)
>> 
>> * Add .versionbot/CHANGELOG.yml for nested changelogs [Pagan Gazzard]
>> * Optimize lodash dependency [Pagan Gazzard]
>> 
> </details>
> 
> 
> ## balena-supervisor-11.12.0
> ### (2020-08-05)
> 
> 
> <details>
> <summary> Update contrato to 0.5 [Pagan Gazzard] </summary>
> 
>> ### contrato-0.5.0
>> #### (2020-08-05)
>> 
>> * Remove handlebars-helpers to shrink bundle size [Pagan Gazzard]
>> 
>> ### contrato-0.4.0
>> #### (2020-08-04)
>> 
>> 
>> <details>
>> <summary> Update skhema to 5.x [Pagan Gazzard] </summary>
>> 
>>> #### skhema-5.3.2
>>> ##### (2020-08-04)
>>> 
>>> * Switch to typed-error [Pagan Gazzard]
>>> 
>>> #### skhema-5.3.1
>>> ##### (2020-08-04)
>>> 
>>> * Add .versionbot/CHANGELOG.yml for nested changelogs [Pagan Gazzard]
>>> 
>>> #### skhema-5.3.0
>>> ##### (2020-05-05)
>>> 
>>> * filter: Throw a custom error if the schema is invalid [Juan Cruz Viotti]
>>> 
>>> #### skhema-5.2.9
>>> ##### (2019-12-12)
>>> 
>>> * Add test to show .filter() not working correctly [StefKors]
>>> * When combining with baseSchema merge enum with AND operator [StefKors]
>>> 
>>> #### skhema-5.2.8
>>> ##### (2019-11-27)
>>> 
>>> * Ensure values in "enum" are unique [Juan Cruz Viotti]
>>> 
>>> #### skhema-5.2.7
>>> ##### (2019-11-27)
>>> 
>>> * filter: Correctly handle "enum" inside "anyOf" [Juan Cruz Viotti]
>>> 
>>> #### skhema-5.2.6
>>> ##### (2019-11-19)
>>> 
>>> * merge: Be explicit about additionalProperties [Juan Cruz Viotti]
>>> 
>>> #### skhema-5.2.5
>>> ##### (2019-05-09)
>>> 
>>> * Add a resolver for the const keyword [Lucian]
>>> 
>>> #### skhema-5.2.4
>>> ##### (2019-04-15)
>>> 
>>> * Configure AJV instances with an LRU cache [Juan Cruz Viotti]
>>> 
>>> #### skhema-5.2.3
>>> ##### (2019-04-15)
>>> 
>>> * Set addUsedSchema to false in all AJV instances [Juan Cruz Viotti]
>>> 
>>> #### skhema-5.2.2
>>> ##### (2019-03-20)
>>> 
>>> * Fix bug in scoreMatch when handling arrays [Lucian]
>>> 
>>> #### skhema-5.2.1
>>> ##### (2019-03-19)
>>> 
>>> * Fix bad require name and .only in tests [Lucian]
>>> 
>>> #### skhema-5.2.10
>>> ##### (Invalid date)
>>> 
>>> * .filter(): Only match if the base schema matches [Lucian Buzzo]
>>> 
>>> #### skhema-5.2.0
>>> ##### (2019-03-19)
>>> 
>>> * Add ability to provide custom resolvers to merge() [Lucian]
>>> 
>>> #### skhema-5.1.1
>>> ##### (2019-02-08)
>>> 
>>> * Split up and optimize lodash dependencies [Lucian]
>>> 
>>> #### skhema-5.1.0
>>> ##### (2019-01-08)
>>> 
>>> * feature: Implement method for restricting a schema by another schema [Lucian Buzzo]
>>> 
>>> #### skhema-5.0.0
>>> ##### (Invalid date)
>>> 
>>> * Remove ability to add custom keywords or formats [Lucian]
>>> 
>>> #### skhema-4.0.4
>>> ##### (Invalid date)
>>> 
>>> * Improve performance of clone operations [Lucian]
>>> 
>>> #### skhema-4.0.3
>>> ##### (2018-12-10)
>>> 
>>> * Don't bust AJV cache [Lucian]
>>> 
>>> #### skhema-4.0.2
>>> ##### (2018-12-10)
>>> 
>>> * Add benchmark tests [Giovanni Garufi]
>>> 
>>> #### skhema-4.0.1
>>> ##### (2018-12-04)
>>> 
>>> * Recurse through nested `anyOf` statements when filtering [Lucian]
>>> 
>>> #### skhema-4.0.0
>>> ##### (2018-12-03)
>>> 
>>> * Treat undefined additionalProperties as true instead of false [Lucian]
>>> 
>>> #### skhema-3.0.1
>>> ##### (Invalid date)
>>> 
>>> * stryker: Increase test timeout [Juan Cruz Viotti]
>>> * test: Configure Stryker for mutative testing [Juan Cruz Viotti]
>>> 
>>> #### skhema-3.0.0
>>> ##### (2018-11-29)
>>> 
>>> * Define additionalProperty inheritance in anyOf [Giovanni Garufi]
>>> * Formalising filtering logic [Lucian]
>>> * Added failing test case with mutation [Lucian]
>>> 
>>> #### skhema-2.5.2
>>> ##### (2018-11-07)
>>> 
>>> * hotfix: Make sure things that should be filtered are filtered [Juan Cruz Viotti]
>>> 
>>> #### skhema-2.5.1
>>> ##### (2018-11-06)
>>> 
>>> * filter: Force additionalProperties: true on match schemas [Juan Cruz Viotti]
>>> 
>>> #### skhema-2.5.0
>>> ##### (2018-10-16)
>>> 
>>> * Validate against just the schema if `options.schemaOnly` is true [Lucian Buzzo]
>>> 
>>> #### skhema-2.4.1
>>> ##### (2018-10-09)
>>> 
>>> * merge: When merging an empty array, return a wildcard schema [Lucian Buzzo]
>>> 
>>> #### skhema-2.4.0
>>> ##### (2018-10-09)
>>> 
>>> * validate: Make object optional [Lucian Buzzo]
>>> 
>> </details>
>> 
>> 
>> ### contrato-0.3.1
>> #### (2020-08-04)
>> 
>> * Add .versionbot/CHANGELOG.yml for nested changelogs [Pagan Gazzard]
>> 
>> ### contrato-0.3.0
>> #### (2020-07-17)
>> 
>> * Add logical operator support in templates [Stevche Radevski]
>> 
> </details>
> 
> 
> ## balena-supervisor-11.11.7
> ### (2020-08-04)
> 
> * Bump elliptic from 6.5.2 to 6.5.3 [dependabot[bot]]
> 
> <details>
> <summary> Update pinejs-client-request and make use of a named key [Pagan Gazzard] </summary>
> 
>> ### pinejs-client-request-7.1.0
>> #### (2020-07-28)
>> 
>> 
>> <details>
>> <summary> Update dependencies [Pagan Gazzard] </summary>
>> 
>>> #### pinejs-client-js-6.1.0
>>> ##### (2020-07-21)
>>> 
>>> * Add support for using named ids [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-6.0.1
>>> ##### (2020-06-19)
>>> 
>>> * Drop unnecessary async from request() [Thodoris Greasidis]
>>> 
>> </details>
>> 
>> 
>> ### pinejs-client-request-7.0.1
>> #### (2020-07-28)
>> 
>> * Increase default timeout to 59s [Pagan Gazzard]
>> 
> </details>
> 
> 
> ## balena-supervisor-11.11.6
> ### (2020-07-31)
> 
> * Fixes documentation - ping doesn't need apiKey and minor documentation formatting changes. [Nitish Agarwal]
> 
> ## balena-supervisor-11.11.5
> ### (2020-07-31)
> 
> * Fixes #1299 v1 start/stop endpoint issue with service access. [Nitish Agarwal]
> 
> ## balena-supervisor-11.11.4
> ### (2020-07-31)
> 
> * bug: Fix undefined containerId object [Rich Bayliss]
> 
> ## balena-supervisor-11.11.3
> ### (2020-07-30)
> 
> * fix matching extra_uEnv backend with unsupported devices [Miguel Casqueira]
> 
> ## balena-supervisor-11.11.2
> ### (2020-07-30)
> 
> * Fix an issue with reporting initial config using a stale target state [Pagan Gazzard]
> 
> ## balena-supervisor-11.11.1
> ### (2020-07-29)
> 
> * fix up "atleast" -> "at least" [Matthew McGinn]
> 
> ## balena-supervisor-11.11.0
> ### (2020-07-28)
> 
> * Support setting device/fleet configuration in extra_uEnv.txt [Miguel Casqueira]
> 
> ## balena-supervisor-11.10.0
> ### (2020-07-24)
> 
> * Extract current state reporting to its own module [Pagan Gazzard]
> 
> ## balena-supervisor-11.9.10
> ### (2020-07-23)
> 
> * log detection of changes to VPN status [dt-rush]
> 
</details>

# v2.53.14
## (2020-08-06)

* balena-unique-key: Ensure config.json is synced after replacing [Alexandru Costache]

# v2.53.13
## (2020-08-05)

* flasher-register: if no supervisor information found, report null [Matthew McGinn]

# v2.53.12
## (2020-08-04)

* systemd: Set net.ipv4.conf.all.rp_filter in balena-os-sysctl [Alexandru Costache]

# v2.53.11
## (2020-07-30)

* Use a named key when querying for device by uuid [Pagan Gazzard]

# v2.53.10
## (2020-07-29)

* supervisor: allow supervisor updates without controlling the supervisor state [Matthew McGinn]

# v2.53.9
## (2020-07-23)


<details>
<summary> balena-supervisor: Update to v11.9.9 [Rich Bayliss] </summary>

> ## balena-supervisor-11.9.9
> ### (2020-07-23)
> 
> * common: Fix bug where aliases might be undefined [Rich Bayliss]
> 
</details>

# v2.53.8
## (2020-07-23)

* resin-supervisor: Create required directories before launch [Alex Gonzalez]

# v2.53.7
## (2020-07-23)


<details>
<summary> balena-supervisor: Update to v11.9.8 [Florin Sarbu] </summary>

> ## balena-supervisor-11.9.8
> ### (2020-07-22)
> 
> * Bump lodash from 4.17.15 to 4.17.19 [dependabot[bot]]
> 
> ## balena-supervisor-11.9.7
> ### (2020-07-22)
> 
> * docker-utils: Test network gateway determination logic [Rich Bayliss]
> * Fix docker-util using incorrect reference for function [Miguel Casqueira]
> 
</details>

# v2.53.6
## (2020-07-21)

* recipes-containers/balena: Use separate service for loading healthcheck image [Alexandru Costache]

# v2.53.5
## (2020-07-21)


<details>
<summary> balena-supervisor: Update to v11.9.6 [Rich Bayliss] </summary>

> ## balena-supervisor-11.9.6
> ### (2020-07-20)
> 
> * Fix purge and restart invocations by providing instanced apps [Cameron Diver]
> * Fix purge invocations of new singletons [Cameron Diver]
> 
> ## balena-supervisor-11.9.5
> ### (2020-07-14)
> 
> * Update ESR version information [Cameron Diver]
> 
</details>

# v2.53.4
## (2020-07-21)

* Add support for aufs5 on kernel 5.x variants [Florin Sarbu]
* Force choosing busybox-hwclock over util-linux-hwclock [Alex Gonzalez]

# v2.53.3
## (2020-07-16)

* provisioning: provide base supervisor_version during provision [Matthew McGinn]

# v2.53.2
## (2020-07-16)

* Add LZ4 support config for older kernels [Alexandru Costache]

# v2.53.1
## (2020-07-14)

* Remove unnecessary config.json keys [Pagan Gazzard]

# v2.53.0
## (2020-07-14)

* resin-supervisor: Create required directories before launch [Alex Gonzalez]
* Rebrand custom resin logos [Alex Gonzalez]
* plymouth: Remove patch that sets plymouth resin theme [Alex Gonzalez]
* docker-disk: Update dind container to v19.03.10 [Michal Toman]
* docker-disk: Update to still supported dind container [Gergely Imreh]
* Use udev for setting up wlan power management [Michal Toman]
* Use --mount instead of --volume for bind mounts to the supervisor container. [Robert Günzler]

# v2.52.7
## (2020-07-13)


<details>
<summary> Update balena-supervisor from v11.9.3 to v11.9.4 [Rich Bayliss] </summary>

> ## balena-supervisor-11.9.4
> ### (2020-07-13)
> 
> * bug: Fix unhandled promise rejection [Rich Bayliss]
> 
</details>

# v2.52.6
## (2020-07-13)

* Update to use api v6 and fix a quoting bug [Pagan Gazzard]

# v2.52.5
## (2020-07-10)

* Allow comments in iptables ruleset [Alex Gonzalez]

# v2.52.4
## (2020-07-09)


<details>
<summary> Update balena-supervisor from v11.4.10 to v11.9.3 [Cameron Diver] </summary>

> ## balena-supervisor-11.9.3
> ### (2020-07-08)
> 
> * Fix bug where a promise was not resolved in db-format [Cameron Diver]
> * Convert deviceConfig module to a singleton [Cameron Diver]
> 
> ## balena-supervisor-11.9.2
> ### (2020-07-06)
> 
> * avahi: Control with HOST_DISCOVERABILITY [Cameron Diver]
> 
> ## balena-supervisor-11.9.1
> ### (2020-07-01)
> 
> * firewall: Add Host Firewall functionality [Rich Bayliss]
> 
> ## balena-supervisor-11.9.0
> ### (2020-06-23)
> 
> * Added support for configuring FDT directive in extlinux.conf [Miguel Casqueira]
> 
> ## balena-supervisor-11.8.4
> ### (2020-06-22)
> 
> * state: Report device MAC address to the API [Rich Bayliss]
> 
> ## balena-supervisor-11.8.3
> ### (2020-06-18)
> 
> 
> <details>
> <summary> Update pinejs-client-request to 7.x [Pagan Gazzard] </summary>
> 
>> ### pinejs-client-request-7.0.0
>> #### (2020-06-16)
>> 
>> * Empty commit to attempt republish [Pagan Gazzard]
>> * Switch from bluebird-lru-cache to lru-cache for caching [Pagan Gazzard]
>> * Update target to es2018 [Pagan Gazzard]
>> * Remove bluebird dependency [Pagan Gazzard]
>> * Convert to async/await [Pagan Gazzard]
>> 
>> <details>
>> <summary> Update to pinejs-client-core 6.x [Pagan Gazzard] </summary>
>> 
>>> #### pinejs-client-js-6.0.0
>>> ##### (2020-06-04)
>>> 
>>> * Increase minimum es version to es2015 [Pagan Gazzard]
>>> * Convert to async/await [Pagan Gazzard]
>>> * Remove now unnecessary PinejsClientCoreFactory [Pagan Gazzard]
>>> * Switch to using native promises [Pagan Gazzard]
>>> * Drop support for deprecated request overrides [Pagan Gazzard]
>>> * Drop support for deprecated `query` method [Pagan Gazzard]
>>> * Drop support for deprecated string based requests [Pagan Gazzard]
>>> * Use `;` for expand options instead of `&` [Pagan Gazzard]
>>> 
>> </details>
>> 
>> 
>> ### pinejs-client-request-6.2.0
>> #### (2020-06-08)
>> 
>> * Lazy load bluebird-lru-cache and lodash [Pagan Gazzard]
>> 
>> ### pinejs-client-request-6.1.4
>> #### (2020-06-08)
>> 
>> * Convert some lodash usage to native versions [Pagan Gazzard]
>> 
>> ### pinejs-client-request-6.1.3
>> #### (2020-06-04)
>> 
>> * Remove unused dependencies [Pagan Gazzard]
>> 
>> ### pinejs-client-request-6.1.2
>> #### (2020-06-02)
>> 
>> 
>> <details>
>> <summary> Update dependencies [Pagan Gazzard] </summary>
>> 
>>> #### pinejs-client-js-5.8.0
>>> ##### (2020-05-29)
>>> 
>>> * Generate optional builds for es2015/es2018 as well as the default es5 [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.7.1
>>> ##### (2020-05-25)
>>> 
>>> * Update dependencies [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.7.0
>>> ##### (2020-04-15)
>>> 
>>> * Make transformGetResult a method , to ease overriding the get method [Thodoris Greasidis]
>>> 
>> </details>
>> 
>> 
>> ### pinejs-client-request-6.1.1
>> #### (2020-03-19)
>> 
>> * Add linting [Pagan Gazzard]
>> 
>> ### pinejs-client-request-6.1.0
>> #### (2020-03-19)
>> 
>> * Move require-npm4-to-publish to dev dependencies [Pagan Gazzard]
>> 
>> <details>
>> <summary> Update dependencies [Pagan Gazzard] </summary>
>> 
>>> #### typed-error-3.2.0
>>> ##### (2019-11-20)
>>> 
>>> * update deps and specify minimum engine requirements [Will Boyce]
>>> 
>>> #### pinejs-client-js-5.6.11
>>> ##### (2020-02-21)
>>> 
>>> * 🐛: Fix missing `deprecated.getStringParams` function [Andreas Fitzek]
>>> 
>>> #### pinejs-client-js-5.6.10
>>> ##### (2020-02-14)
>>> 
>>> * Update to resin-lint 3.x [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.6.9
>>> ##### (2020-02-14)
>>> 
>>> * CircleCI: Remove deploy job as it's handled by balenaCI [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.6.8
>>> ##### (2020-02-14)
>>> 
>>> * Add the missing `method` on the post method [Thodoris Greasidis]
>>> 
>>> #### pinejs-client-js-5.6.7
>>> ##### (2020-02-14)
>>> 
>>> * Deprecate request overrides [Pagan Gazzard]
>>> * Deprecate queries using a string url [Pagan Gazzard]
>>> * Deprecate `query` in favor of `get` [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.6.6
>>> ##### (2020-02-14)
>>> 
>>> * Allow resource/$count in $filter [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.6.5
>>> ##### (2020-01-30)
>>> 
>>> * Remove `defaults` helper in favour of `??` [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.6.4
>>> ##### (2020-01-30)
>>> 
>>> * Avoid allocations when destroying a poll [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.6.3
>>> ##### (2020-01-30)
>>> 
>>> * Improve `RawFilter` typing [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.6.2
>>> ##### (2020-01-29)
>>> 
>>> * Update dependencies [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.6.1
>>> ##### (2020-01-22)
>>> 
>>> * Switch most CODEOWNERS entries to a team [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.6.0
>>> ##### (2019-07-12)
>>> 
>>> * Add 'upsert' method supporting natural keys, requires Pinejs ^10.19.1 [Thodoris Greasidis]
>>> 
>>> #### pinejs-client-js-5.5.4
>>> ##### (2019-06-18)
>>> 
>>> * Remove unnecessary `string` type that is handled by the `Params` type [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.5.3
>>> ##### (2019-06-18)
>>> 
>>> * Use an .npmrc to prevent creating a package-lock on each install [Thodoris Greasidis]
>>> 
>>> #### pinejs-client-js-5.5.2
>>> ##### (2019-06-10)
>>> 
>>> * Add some type casting so that it compiles on TypeScript 3.5 [Thodoris Greasidis]
>>> 
>>> #### pinejs-client-js-5.5.1
>>> ##### (2019-05-15)
>>> 
>>> * Fix downstream declaration creation errors due to `Dictionary` [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.5.0
>>> ##### (2019-05-15)
>>> 
>>> * Add a prepare method that prepares a query into a function [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.4.1
>>> ##### (2019-05-10)
>>> 
>>> * Add CODEOWNERS [Gergely Imreh]
>>> 
>>> #### pinejs-client-js-5.4.0
>>> ##### (2019-05-10)
>>> 
>>> * Add support for parameter aliases in resource ids [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.3.10
>>> ##### (2019-05-10)
>>> 
>>> * Deduplicate transformation of GET results [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.3.9
>>> ##### (2019-05-10)
>>> 
>>> * Simplify how we expose types, which means `subscribe` is now exposed [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.3.8
>>> ##### (2019-05-09)
>>> 
>>> * Add automatic formatting via prettier [Pagan Gazzard]
>>> 
>>> #### pinejs-client-js-5.3.7
>>> ##### (2019-05-08)
>>> 
>>> * Remove node 4 build, add node 12 [Pagan Gazzard]
>>> * Add .versionbot/CHANGELOG.yml for downstream changelogs [Pagan Gazzard]
>>> 
>> </details>
>> 
>> 
>> ### pinejs-client-request-6.0.3
>> #### (2020-01-22)
>> 
>> * Add CODEOWNERS [Pagan Gazzard]
>> 
>> ### pinejs-client-request-6.0.2
>> #### (2019-05-08)
>> 
>> * Add node 12 tests [Pagan Gazzard]
>> * Add upstream for pinejs-client-core [Pagan Gazzard]
>> 
>> ### pinejs-client-request-6.0.1
>> #### (2019-04-23)
>> 
>> * Update target to es2016, part of/fixing the typed-error bump [Pagan Gazzard]
>> 
>> ### pinejs-client-request-6.0.0
>> #### (2019-04-17)
>> 
>> * typed-error: Update to v3.1.0 [Will Boyce]
>> 
> </details>
> 
> 
> ## balena-supervisor-11.8.2
> ### (2020-06-17)
> 
> * Make service-manager module a singleton [Cameron Diver]
> * Make volume-manager module a singleton [Cameron Diver]
> * Make network-manager module a singleton [Cameron Diver]
> * Add supervisor upgrade document [Hugh Brown]
> 
> ## balena-supervisor-11.8.1
> ### (2020-06-16)
> 
> * Update webpack dependencies [Pagan Gazzard]
> 
> ## balena-supervisor-11.8.0
> ### (2020-06-16)
> 
> * Use API v6 [Akis Kesoglou]
> 
> ## balena-supervisor-11.7.3
> ### (2020-06-15)
> 
> * Db-format module code fixups [Cameron Diver]
> 
> ## balena-supervisor-11.7.2
> ### (2020-06-11)
> 
> * Add label to expose gpu to container [Robert Günzler]
> 
> ## balena-supervisor-11.7.1
> ### (2020-06-11)
> 
> * Move database app processing out to its own module [Cameron Diver]
> * Make target-state-cache a singleton [Cameron Diver]
> 
> ## balena-supervisor-11.7.0
> ### (2020-06-10)
> 
> * Respect an initialDeviceName field in the config.json [Cameron Diver]
> 
> ## balena-supervisor-11.6.6
> ### (2020-06-10)
> 
> * Make images module a singleton [Cameron Diver]
> 
> ## balena-supervisor-11.6.5
> ### (2020-06-09)
> 
> * fix: API auth missing on state GET/PATCH [Rich Bayliss]
> 
> ## balena-supervisor-11.6.4
> ### (2020-06-08)
> 
> * Refactored @ts-ignore to @ts-expect-error in test file [Miguel Casqueira]
> 
> ## balena-supervisor-11.6.3
> ### (2020-06-08)
> 
> * Make logger module a singleton [Cameron Diver]
> * Fix exponential backoff for state polling [Pagan Gazzard]
> 
> ## balena-supervisor-11.6.2
> ### (2020-06-08)
> 
> * Make the event-tracker module a singleton [Cameron Diver]
> 
> ## balena-supervisor-11.6.1
> ### (2020-06-05)
> 
> * Convert all test files to TS and add .spec to all filenames [Miguel Casqueira]
> * fix: Pin alpine python version [Rich Bayliss]
> 
> ## balena-supervisor-11.6.0
> ### (2020-06-03)
> 
> * Isolate target state fetching to its own module which emits on update [Pagan Gazzard]
> 
> ## balena-supervisor-11.5.3
> ### (2020-06-02)
> 
> * Make docker module a singleton [Cameron Diver]
> 
> ## balena-supervisor-11.5.2
> ### (2020-06-02)
> 
> * Make the config module a singleton [Cameron Diver]
> 
> ## balena-supervisor-11.5.1
> ### (2020-06-01)
> 
> * Remove unused dependencies and dedupe [Cameron Diver]
> 
> ## balena-supervisor-11.5.0
> ### (2020-05-29)
> 
> * Refactor device-state healthchecks to log reason for failure [Miguel Casqueira]
> 
> ## balena-supervisor-11.4.17
> ### (2020-05-29)
> 
> * Update dependencies [Pagan Gazzard]
> 
> ## balena-supervisor-11.4.16
> ### (2020-05-29)
> 
> * Make the db module a singleton [Cameron Diver]
> 
> ## balena-supervisor-11.4.15
> ### (2020-05-26)
> 
> * Check for ApiError before using it as such [Cameron Diver]
> 
> ## balena-supervisor-11.4.14
> ### (2020-05-21)
> 
> * check for 409 status code, rather than string matching uuid conflicts [Cameron Diver]
> 
> ## balena-supervisor-11.4.13
> ### (2020-05-21)
> 
> * Use safeStateClone to avoid call-stack exceeding errors [Cameron Diver]
> 
> ## balena-supervisor-11.4.12
> ### (2020-05-19)
> 
> * Improved handling of invalid appId in V2 state endpoint [Miguel Casqueira]
> 
> ## balena-supervisor-11.4.11
> ### (2020-05-18)
> 
> * Switch to balenaApi for the state patch as patching cannot be cached [Pagan Gazzard]
> 
</details>

# v2.52.3
## (2020-07-09)

* systemd: Simplify zram swap unit dependencies to avoid ordering cycle [Alex Gonzalez]

# v2.52.2
## (2020-07-06)

* kernel-resin: Make USB_SERIAL and USB_SERIAL_GENERIC built-ins [Alex Gonzalez]
* kernel-resin: Fix configuration warnings from newer kernels [Alex Gonzalez]
* kernel-resin: Update balena kernel configuration for updated engine [Alex Gonzalez]

# v2.52.1
## (2020-07-02)

* Fix up UUID variable when communicating with API [Matthew McGinn]

# v2.52.0
## (2020-06-30)

* Add compressed memory swap support [Alex Gonzalez]
* systemd-zram-swap: Add compressed memory swap support [Alex Gonzalez]
* kernel-resin: Built-in zram configuration [Alex Gonzalez]

# v2.51.8
## (2020-06-30)

* resin-ntp-config: merge 'burst' command with 'add server' line [Mark Corbin]

# v2.51.7
## (2020-06-25)

* resin-image: Install extra_uEnv.txt in boot partition [Alexandru Costache]

# v2.51.6
## (2020-06-25)

* initrdscripts: rootfs: Fix comparison to account for empty variable [Alex Gonzalez]
* Use UUID rather than ID when communicating with API [Matthew McGinn]

# v2.51.5
## (2020-06-18)

* Set chrony default servers as pools [Matthew McGinn]

# v2.51.4
## (2020-06-15)

* Generate nested changelogs for balena-engine [Robert Günzler]

# v2.51.3
## (2020-06-10)

* Revert allowing local resin-supervisor image updates [Alex Gonzalez]

# v2.51.2
## (2020-06-08)

* Disable u-boot console, silence u-boot in production builds [Florin Sarbu]

# v2.51.1
## (2020-06-04)

* openvpn: Add runtime dependency on bash [Willem Remie]

# v2.51.0
## (2020-06-03)

* balena-engine: Update to 19.03.13 [Robert Günzler]

# v2.50.4
## (2020-06-02)

* Use correct SRC_URI for bindmount [Florin Sarbu]

# v2.50.3
## (2020-06-01)

* os-helpers-fs: Fix shellcheck warnings [Alex Gonzalez]
* Fallback to label root device matching to support devices with closed source bootloaders [Alex Gonzalez]
* Fallback to labels and partlabels for devices with custom HUPs [Alex Gonzalez]

# v2.50.2
## (2020-05-27)

* Enable the Analog Devices AD5446 kernel driver [Florin Sarbu]

# v2.50.1
## (2020-05-21)

* networkmanager: Remove build warning [Alex Gonzalez]
* Remove busybox-syslog to use only systemd's journald [Alex Gonzalez]
* Update CODEOWNERS [Alex Gonzalez]
* Backport NM patch for setting modem MTU correctly [Florin Sarbu]
* update-resin-supervisor: short circuit if remote image cannot be fetched [Matthew McGinn]

<details>
<summary> Update balena-supervisor from v11.4.1 to v11.4.10 [Cameron Diver] </summary>

> ## balena-supervisor-11.4.10
> ### (2020-05-18)
> 
> * Fix leftover spurious return from typescript conversion [Cameron Diver]

> ## balena-supervisor-11.4.9
> ### (2020-05-18)
> 
> * Catch errors in the target state poll so polling will always continue [Pagan Gazzard]

> ## balena-supervisor-11.4.8
> ### (2020-05-18)
> 
> * Avoid querying `instantUpdates` on every state poll [Pagan Gazzard]

> ## balena-supervisor-11.4.7
> ### (2020-05-16)
> 
> * Fix default request options [Pagan Gazzard]

> ## balena-supervisor-11.4.6
> ### (2020-05-15)
> 
> * Remove CoffeeScript tests and all CoffeeScript tools [Miguel Casqueira]

> ## balena-supervisor-11.4.5
> ### (2020-05-15)
> 
> * Update to @balena/lint 5.x [Pagan Gazzard]

> ## balena-supervisor-11.4.4
> ### (2020-05-15)
> 
> * Add a random offset to the poll interval with each poll [Cameron Diver]

> ## balena-supervisor-11.4.3
> ### (2020-05-14)
> 
> * Cache service names in local log backend [Cameron Diver]

> ## balena-supervisor-11.4.2
> ### (2020-05-13)
> 
> * Update engine information in package.json [Cameron Diver]
</details>

# v2.50.0
## (2020-05-13)

* Use /tmp as bootparam_root storage [Alex Gonzalez]
* Update to libqmi v1.24.10 [Michal Toman]
* Set rust 1.36 as the preferred rust version from meta-balena-common [Zubair Lutfullah Kakakhel]
* Turn off wlan0 power save [Michal Toman]

<details>
<summary> Update os-config from 1.1.3 to 1.1.4 [Alex Gonzalez] </summary>

> ## os-config-1.1.4
> ### (2020-05-13)
> 
> * versionbot: Add changelog yml file [Alex Gonzalez]
</details>



<details>
<summary> Update balena-supervisor from v11.3.0 to v11.4.1 [Cameron Diver] </summary>

> ## balena-supervisor-11.4.1
> ### (2020-05-12)
> 
> * Correctly check if value is a valid Integer [Miguel Casqueira]

> ## balena-supervisor-11.4.0
> ### (2020-05-12)
> 
> * Added endpoint to check if VPN is connected [Miguel Casqueira]

> ## balena-supervisor-11.3.11
> ### (2020-05-11)
> 
> * Fixed stubs for test suite [Miguel Casqueira]

> ## balena-supervisor-11.3.10
> ### (2020-05-11)
> 
> * Added more documentation to help new contributors start developing [Miguel Casqueira]

> ## balena-supervisor-11.3.9
> ### (2020-05-11)
> 
> * Fix dindctl script and update balenaos-in-container [Cameron Diver]

> ## balena-supervisor-11.3.8
> ### (2020-05-08)
> 
> * Remove unnecessary config.json keys [Pagan Gazzard]

> ## balena-supervisor-11.3.7
> ### (2020-05-08)
> 
> * CI: Use node 12 for tests to match runtime version [Pagan Gazzard]
> * CI: Use docker 18 client to match remote [Pagan Gazzard]

> ## balena-supervisor-11.3.6
> ### (2020-05-07)
> 
> * Move SupervisorAPI state change logs to appropriate functions [Miguel Casqueira]

> ## balena-supervisor-11.3.5
> ### (2020-05-07)
> 
> * Add 20k-ultra to codeowners [Miguel Casqueira]

> ## balena-supervisor-11.3.4
> ### (2020-05-06)
> 
> * Don't use the openvpn alias to check VPN status [Cameron Diver]

> ## balena-supervisor-11.3.3
> ### (2020-05-06)
> 
> * Use lstat rather than stat to avoid error with symlinks in sync [Cameron Diver]

> ## balena-supervisor-11.3.2
> ### (2020-05-05)
> 
> * Move build files into build-conf and rename to build-utils [Cameron Diver]
> * Fix knex migration require translation [Cameron Diver]

> ## balena-supervisor-11.3.1
> ### (2020-05-05)
> 
> * Remove legacy fallback to DROP rule in iptables [Cameron Diver]
> * Add an ESTABLISHED flag to API iptables rules [Cameron Diver]
> * Add ESR information to repo.yml [Cameron Diver]
</details>



<details>
<summary> Update balena-supervisor from v10.11.0 to v11.3.0 [Cameron Diver] </summary>

> ## balena-supervisor-11.3.0
> ### (2020-05-04)
> 
> * Added Bearer Authorization spec [Miguel Casqueira]

> ## balena-supervisor-11.2.0
> ### (2020-04-30)
> 
> * Added explanation README for running specific tests [Miguel Casqueira]

> ## balena-supervisor-11.1.11
> ### (2020-04-28)
> 
> * Remove coverage running and modules [Cameron Diver]

> ## balena-supervisor-11.1.10
> ### (2020-04-27)
> 
> * Update balena-register-device to fix provisioning [Cameron Diver]

> ## balena-supervisor-11.1.9
> ### (2020-04-22)
> 
> * Added protocol to semver.org link [Miguel Casqueira]

> ## balena-supervisor-11.1.8
> ### (2020-04-21)
> 
> * Actually remove dbus-native dependency [Cameron Diver]

> ## balena-supervisor-11.1.7
> ### (2020-04-21)
> 
> * Fix livepush predicate for POSIX sh in entry.sh [Cameron Diver]

> ## balena-supervisor-11.1.6
> ### (2020-04-21)
> 
> * Remove double printing of API status error [Cameron Diver]

> ## balena-supervisor-11.1.5
> ### (2020-04-15)
> 
> * ⤴️ Upgrade migrations to work with knex [Cameron Diver]
> * 📄 Upgrade knex to avoid CVE-2019-10757 [Cameron Diver]

> ## balena-supervisor-11.1.4
> ### (2020-04-14)
> 
> * 🔎 Also watch js files during livepush [Cameron Diver]
> * Clear changed files after successful livepush invocation [Cameron Diver]
> * Use livepush commands for copying and running dev specific steps [Cameron Diver]

> ## balena-supervisor-11.1.3
> ### (2020-04-13)
> 
> * 🚀 Update supervisor to node12 [Cameron Diver]

> ## balena-supervisor-11.1.2
> ### (2020-04-13)
> 
> * Move from dbus-native to dbus [Cameron Diver]

> ## balena-supervisor-11.1.1
> ### (2020-04-10)
> 
> * Update copy-webpack-plugin [Pagan Gazzard]
> * Update ts-loader to 6.x [Pagan Gazzard]
> * Update fork-ts-checker-webpack-plugin to 4.x [Pagan Gazzard]

> ## balena-supervisor-11.1.0
> ### (2020-04-09)
> 
> * Support matching on device type within contracts [Cameron Diver]

> ## balena-supervisor-11.0.9
> ### (2020-04-08)
> 
> * Workaround a circular dependency [Pagan Gazzard]

> ## balena-supervisor-11.0.8
> ### (2020-04-08)
> 
> * Link sqlite with a system sqlite for quicker builds [Cameron Diver]

> ## balena-supervisor-11.0.7
> ### (2020-04-08)
> 
> * Convert application-manager.coffee to javascript [Pagan Gazzard]

> ## balena-supervisor-11.0.6
> ### (2020-04-08)
> 
> * Don't sync test files with livepush [Cameron Diver]

> ## balena-supervisor-11.0.5
> ### (2020-04-07)
> 
> * Add newTargetState event and use it for backup loading [Cameron Diver]

> ## balena-supervisor-11.0.4
> ### (2020-04-07)
> 
> * Don't wrap UpdatesLockedErrors with a detailed error [Cameron Diver]

> ## balena-supervisor-11.0.3
> ### (2020-04-07)
> 
> * Allow spaces in volume definitions [Cameron Diver]

> ## balena-supervisor-11.0.2
> ### (2020-04-06)
> 
> * Update to balena-register-device 6.0.1 [Pagan Gazzard]

> ## balena-supervisor-11.0.1
> ### (2020-04-06)
> 
> * Don't mangle names when minimising with webpack [Cameron Diver]

> ## balena-supervisor-11.0.0
> ### (2020-04-06)
> 
> * ⚡ Update synchronisation scripts for supervisor development [Cameron Diver]
> * 🔧 Move to an alpine base image and drop i386-nlp support [Cameron Diver]

> ## balena-supervisor-10.11.3
> ### (2020-04-02)
> 
> * Convert test/18-startup.coffee to typescript [Pagan Gazzard]
> * Convert test/19-compose-utils.coffee to javascript [Pagan Gazzard]
> * Convert test/18-compose-network.coffee to javascript [Pagan Gazzard]
> * Convert test/17-config-utils.spec.coffee to javascript [Pagan Gazzard]
> * Convert test/16-ports.spec.coffee to typescript [Pagan Gazzard]
> * Convert test/15-conversions.spec.coffee to javascript [Pagan Gazzard]
> * Convert test/12-logger.spec.coffee to javascript [Pagan Gazzard]

> ## balena-supervisor-10.11.2
> ### (2020-03-31)
> 
> * Pass in deviceId when fetching device tags [Cameron Diver]

> ## balena-supervisor-10.11.1
> ### (2020-03-30)
> 
> * 🔧 Update resin-lint -> balena-lint in lintstaged [Cameron Diver]
</details>



<details>
<summary> Update os-config from 1.1.1 to 1.1.3 [Zubair Lutfullah Kakakhel] </summary>

> ## os-config-1.1.3
> ### (2020-03-24)
> 
> * Reorder module dependencies [Zahari Petkov]
> * Pin serde version to v1.0.94 [Zahari Petkov]

> ## os-config-1.1.2
> ### (2020-02-04)
> 
> * Block on random until success [Zahari Petkov]
> * Use parse_filters instead of parse [Zubair Lutfullah Kakakhel]
</details>

# v2.49.0
## (2020-05-01)

* balena-host: Ignore environment file if it does not exist [Alex Gonzalez]
* Bump balena-engine to 18.09.17 [Robert Günzler]
* networkmanager: Use absolute path in drop-in [Sven Schwermer]
* Update ModemManager to v1.12.8 [Michal Toman]
* Update balena-engine to 18.09.16 [Robert Günzler]
* Add support for using udev by-state links in balenaOS [Alex Gonzalez]
* Add initramfs module to regenerate default filesystem UUIDs [Alex Gonzalez]
* Create udev state symlinks for all partitions [Alex Gonzalez]
* initramfs-framework: Add os-helpers to module prepare [Alex Gonzalez]
* Fix initramfs fsck warnings for the boot partition [Andrei Gherzan]
* Switch to built-in FAT kernel configs [Andrei Gherzan]

<details>
<summary> Update balena-supervisor from v10.8.0 to v10.11.0 [Cameron Diver] </summary>

> ## balena-supervisor-10.11.0
> ### (2020-03-30)
> 
> * Add BALENA_DEVICE_ARCH environment variable for containers [Cameron Diver]

> ## balena-supervisor-10.10.15
> ### (2020-03-30)
> 
> * Don't throw an error when getting an unhealthy state [Cameron Diver]

> ## balena-supervisor-10.10.14
> ### (2020-03-28)
> 
> * Convert src/device-api/common.coffee to javascript [Pagan Gazzard]

> ## balena-supervisor-10.10.13
> ### (2020-03-27)
> 
> * Switch to mz for the proxyvisor [Pagan Gazzard]
> * Convert proxyvisor to javascript [Pagan Gazzard]

> ## balena-supervisor-10.10.12
> ### (2020-03-26)
> 
> * Remove unnecessary code from application-manager [Pagan Gazzard]
> * Switch to a named export for application-manager [Pagan Gazzard]

> ## balena-supervisor-10.10.11
> ### (2020-03-25)
> 
> * Convert device-api/v1 to javascript [Pagan Gazzard]

> ## balena-supervisor-10.10.10
> ### (2020-03-24)
> 
> * Update livepush [Cameron Diver]

> ## balena-supervisor-10.10.9
> ### (2020-03-24)
> 
> * Add type checking for javascript files [Pagan Gazzard]

> ## balena-supervisor-10.10.8
> ### (2020-03-24)
> 
> * Pin resin-cli-visuals to avoid build error of lzma-native [Cameron Diver]
> * Update dependencies [Cameron Diver]

> ## balena-supervisor-10.10.7
> ### (2020-03-24)
> 
> * Avoid any transpilation of node_modules [Pagan Gazzard]

> ## balena-supervisor-10.10.6
> ### (2020-03-24)
> 
> * Add transpilation for javascript files to ease node 6 compatibility [Pagan Gazzard]
> * Add a precheck that linting/tests work on node 10 [Pagan Gazzard]
> * Update to balena-lint and enable javascript linting [Pagan Gazzard]

> ## balena-supervisor-10.10.5
> ### (2020-03-23)
> 
> * Tests: Add missing await [Pagan Gazzard]

> ## balena-supervisor-10.10.4
> ### (2020-03-16)
> 
> * docs: Clarify update locks for multicontainer applications [Gareth Davies]

> ## balena-supervisor-10.10.3
> ### (2020-03-16)
> 
> * logging: fix up some typos [Matthew McGinn]

> ## balena-supervisor-10.10.2
> ### (2020-03-16)
> 
> * Bump acorn from 5.7.3 to 5.7.4 [dependabot[bot]]

> ## balena-supervisor-10.10.1
> ### (2020-03-13)
> 
> * Update dependencies [Pagan Gazzard]

> ## balena-supervisor-10.10.0
> ### (2020-03-06)
> 
> * Allow semver comparison on l4t versions in contracts [Cameron Diver]
> * Allow l4t versions with three numbers as well as two [Cameron Diver]

> ## balena-supervisor-10.9.2
> ### (2020-03-05)
> 
> * config: Support loading SSDT via ConfigFS [Rich Bayliss]

> ## balena-supervisor-10.9.1
> ### (2020-02-25)
> 
> * Convert device-state module to typescript [Cameron Diver]
> * Improve application-manager typings [Cameron Diver]
> * Improve and extend internal typings [Cameron Diver]

> ## balena-supervisor-10.9.0
> ### (2020-02-24)
> 
> * Add a containerId request parameter for journal-logs api endpoint, and pass it along to journalctl process options. [Ivan]
</details>

# v2.48.0
## (2020-03-20)

* Add the linux-firmware recipe from the Poky zeus-22.0.1 release and package various iwlwifi firmware separately [Florin Sarbu]
* Add regulatory.db (Wireless Central Regulatory Domain Database) to rootfs so kernel versions >= v4.15 can load it (for Poky Thud and Warrior based board) [Florin Sarbu]
* Do not send SIGKILL directly to user containers (set KillMode=process in balena.service) [Florin Sarbu]
* Update balena-supervisor from  to v10.8.0 [Cameron Diver]
* Update config.json documentation for disabling NM connectivity checks [Gareth Davies]
* Fix a typo in a NetworkManager plugin path [Zubair Lutfullah Kakakhel]
* Remove unnecessary openvpn v2.4.4 recipe in meta-resin-pyro. [Zubair Lutfullah Kakakhel]
* Use a weak default assignment in a recipe for customer trying to override a variable in his layer [Zubair Lutfullah Kakakhel]

# v2.47.1
## (2020-02-13)

* Affects 2.45+ on all devices. Fix dangling sshd services on failed connections that would grow and cause cpu load to keep rising. See issue 1837 in meta-balena for more detail. [Zubair Lutfullah Kakakhel]

# v2.47.0
## (2020-01-29)

* Update usb-modeswitch-data to version 20191128 [Florin Sarbu]
* Update usb-modeswitch to version 2.5.2 [Florin Sarbu]
* Update to ModemManager v1.12.4 [Florin Sarbu]
* Update libmbim to version 1.22.0 [Florin Sarbu]
* Update libqmi to version 1.24.4 [Florin Sarbu]
* Add periodic vacuuming of journald log files [Alex Gonzalez]
* No user impact. Increase limit for maximum initramfs size from 12MB to 32MB. This helps reduce unnecessary overrides in integration layers. [Zubair Lutfullah Kakakhel]
* Match licenses with license files. [Alex Gonzalez]
* Enable sixaxis support in bluez5 [Alexis Svinartchouk]
* Addressing review comments [Gareth Davies]
* Update config.json documentation [Gareth Davies]
* Increase DNS clients timeout to 15 seconds [Alex Gonzalez]
* Fix supervisor nested changelogs [Zubair Lutfullah Kakakhel]
* Enable memory overcommit [Alex Gonzalez]
* Add uinput kernel module [Florin Sarbu]
* Make sure to add in rootfs the wifi firmware for wl18xx [Florin Sarbu]
* Add supported USB WiFi dongle [Vicentiu Galanopulo]

# v2.46.2
## (2020-01-17)

* Americanize the README.md [Matthew McGinn]

# v2.46.1
## (2020-01-01)

* Disable by default the option to stop u-boot autoboot by pressing CTRL+C in all OS versions [Florin Sarbu]
* Increase NTP polling time to around 4.5 hours. [Alex Gonzalez]
* Disable the option to stop u-boot autoboot by pressing CTRL+C in production OS version [Florin Sarbu]

# v2.46.0
## (2019-12-23)

* Update to ModemManager v1.12.2 [Zahari Petkov]
* Update libmbim to version 1.20.2 [Zahari Petkov]
* Update libqmi to version 1.24.2 [Zahari Petkov]
* Update balena-supervisor to v10.6.27 [Cameron Diver]
* Tweak how the flasher asserts that internal media is valid for being installed balena OS on [Florin Sarbu]
* Remove networkmanager stale temporary files at startup [Alex Gonzalez]
* networkmanager: Rework patches to remove fuzzing [Alex Gonzalez]
* Update openvpn to v2.4.7 [Will Boyce]
* Enable kernel configs for USB_SERIAL, USB_SERIAL_PL2303 and HFS for all devices [Zubair Lutfullah Kakakhel]
* image-resin.bbclass: Mark do_populate_lic_deploy with nostamp [Zubair Lutfullah Kakakhel]
* Namespace the hello-world healthcheck image [Zubair Lutfullah Kakakhel]
* Update balena-supervisor to v10.6.17 [Cameron Diver]
* Update balena-supervisor to v10.6.13 [Cameron Diver]
* Update CODEOWNERS [Zubair Lutfullah Kakakhel]

# v2.45.1
## (2019-11-21)

* Fix for a race condition where occasionally the supervisor might not be able to come up during boot. Also can be caused by using io.balena.features.balena-socket and app container restart always policy. Affects meta-balena 2.44.0 and 2.45.0. To be fixed in 2.44.1 and 2.46.0 [Zubair Lutfullah Kakakhel]
* Rename resin to balena where possible [Pagan Gazzard]
* Add leading new line for PACKAGE_INSTALL variable [Vicentiu Galanopulo]
* Set `net.ipv4.ip_local_port_range` to recommended range (49152-65535) [Will Boyce]
* No user impact, subtle fix in rollback version checks [Zubair Lutfullah Kakakhel]

# v2.45.0
## (2019-10-30)

* Increase persistent journal size to 32M [Will Boyce]
* Move persistent logs from state to data partition [Will Boyce]
* Add wpa-supplicant recipe and update to v2.9 [Will Boyce]
* Improve robustness by making variou services restart if they stop for some reason [Zubair Lutfullah Kakakhel]
* Build net/dummy as module [Alexandru Costache]

# v2.44.0
## (2019-10-03)

* Make uboot dev images autoboot delay build time configurable. Default is no delay [Zubair Lutfullah Kakakhel]
* Reduce systemd logging level from info to notice [Zubair Lutfullah Kakakhel]
* resin-supervisor: Expose container ID via env variable [Roman Mazur]
* kernel-devsrc: Copy vdso.lds.S file in source archive if available [Sebastian Panceac]
* Disable PasswordAuthentication in sshd in production images as an extra precautionary measure. [Zubair Lutfullah Kakakhel]
* Update balena-engine to 18.9.10 [Robert Günzler]
* hostapp-update-hooks: Filter out automount for inactive sysroot [Alexandru Costache]
* Add support for hooks 2.0 enabling finer granularity during HostOS updates. [Zubair Lutfullah Kakakhel]
* Update balena-supervisor to v10.3.7 [Cameron Diver]
* Add support for balena cloud SSH public keys [Andrei Gherzan]
* Map any user to root using libnss-ato [Andrei Gherzan]
* Add option to disable kernel headers from being built. [Zubair Lutfullah Kakakhel]

# v2.43.0
## (2019-09-13)

* Update NetworkManager to 1.20.2 [Andrei Gherzan]
* Update ModemManager to 1.10.6 [Andrei Gherzan]

# v2.42.0
## (2019-09-13)

* A small fix in initramfs when /dev/console is invalid due to whatever reason [Zubair Lutfullah Kakakhel]
* Add automated testing for external kernel module header tarballs [Zubair Lutfullah Kakakhel]
* Make sure correct utsrelease.h is packaged [Zubair Lutfullah Kakakhel]
* Fix a bug where application containers with new systemd versions were failing to start in cases. Switch to systemd cgroup driver in balenaEngine [Zubair Lutfullah Kakakhel]

# v2.41.1
## (2019-09-03)

* Update ModemManager to version 1.10.4 [Florin Sarbu]
* Fix for some innocous systemd tmpfile warnings /var/run -> /run ones [Zubair Lutfullah Kakakhel]
* Fix for rollbacks where the inactive partition mount was unavailable when altboot triggered [Zubair Lutfullah Kakakhel]
* kernel-resin: Enable FTDI USB-serial convertors driver [Sebastian Panceac]

# v2.41.0
## (2019-08-22)

* Fix a hang in initramfs for warrior production images [Zubair Lutfullah Kakakhel]
* Update balena-engine to 18.09.8 [Robert Günzler]
* Avoid overlayfs mounts in poky's volatile-binds [Andrei Gherzan]

# v2.40.0
## (2019-08-14)

* Update balena-supervisor to v10.2.2 [Cameron Diver]
* Workaround for a cornercase bug in PersistentLogging where journalctl filled the state partition. Vacuum the journal on boot. [Zubair Lutfullah Kakakhel]

# v2.39.0
## (2019-07-31)

* usb-modeswitch-data: Switch Huawei E3372 12d1:1f01 to mbim mode [Alexandru Costache]
* Fix rollback altboots to prevent good reboots by supervisor triggering rollback. [Zubair Lutfullah Kakakhel]
* Devices using u-boot. Remove any BOOTDELAY for production images. Add a 2 seconds delay for development images [Zubair Lutfullah Kakakhel]
* Devices using u-boot. Enable CONFIG_CMD_SETEXPR for all devices. Required for rollbacks to work [Zubair Lutfullah Kakakhel]
* Devices using u-boot. Enable rollback-altboot by handling bootcount via meta-balena. [Zubair Lutfullah Kakakhel]
* Production Devices using u-boot. Enable CONFIG_RESET_TO_RETRY to reset a device in case it drops into a u-boot shell [Zubair Lutfullah Kakakhel]
* Remove confusing networkmanager https connectivity warning [Zubair Lutfullah Kakakhel]
* Increase fs.inotify.max_user_instances to 512 [Zubair Lutfullah Kakakhel]
* Update balena-supervisor to v10.0.3 [Cameron Diver]
* Fix balena hello-world healthcheck [Zubair Lutfullah Kakakhel]
* Add nf_table kernel modules [Zubair Lutfullah Kakakhel]
* hostapp-update-hooks: Use correct source for inactive sysroot [Alexandru Costache]
* Add extra healthcheck to balena service. It will spin up a hello-world container as well [Zubair Lutfullah Kakakhel]
* Update balena-supervisor to v9.18.8 [Cameron Diver]
* image-resin.bbclass: fixed a typo [Kyle Harding]
* kernel-resin: Add support for CH340 family of usb-serial adapters [Sebastian Panceac]
* resin-proxy-config: add missing reserved ip ranges to default noproxy [Will Boyce]
* Reduce data partition size from 1G to 192M [Zubair Lutfullah Kakakhel]

# v2.38.3
## (2019-07-10)

* resin-proxy-config: fix up incorrect bash subshell command [Matthew McGinn]

# v2.38.2
## (2019-06-27)

* Update to kernel-modules-headers v0.0.20 to fix missing target modpost binary on kernel 5.0.3 [Florin Sarbu]
* Update to kernel-modules-headers v0.0.19 to fix target objtool compile issue on kernel 5.0.3 [Florin Sarbu]

# v2.38.1
## (2019-06-20)

* Add warrior to compatible layers for meta-balena-common [Florin Sarbu]
* Fix image-resin.bbclass to be able to use deprecated layers [Andrei Gherzan]
* Fix kernel-devsrc on thud when kernel version < 4.10 [Andrei Gherzan]

# v2.38.0
## (2019-06-14)

* Fix VERSION_ID os-release to be semver complient [Andrei Gherzan]
* Introduce META_BALENA_VERSION in os-release [Andrei Gherzan]
* Fix a case where changes to u-boot were not regenerating the config file at build time and using stale values. [Zubair Lutfullah Kakakhel]
* Use all.rp_filter=2 as the default value in balenaOS [Andrei Gherzan]
* Persist bluetooth storage data over reboots [Andrei Gherzan]
* Drop support for morty and krogoth Yocto versions [Andrei Gherzan]
* Add Yocto Warrior support [Zubair Lutfullah Kakakhel]
* Set both VERSION_ID and VERSION in os-release to host OS version [Andrei Gherzan]
* Bump balena-engine to 18.9.6 [Zubair Lutfullah Kakakhel]
* Downgrade balena-supervisor to v9.15.7 [Andrei Gherzan]
* Switch from dropbear to openSSH [Andrei Gherzan]
* Rename meta-resin-common to meta-balena-common [Andrei Gherzan]
* Add wifi firmware for rtl8192su [Zubair Lutfullah Kakakhel]

# v2.37.0
## (2019-05-29)

* Update balena-supervisor to v9.15.8 [Cameron Diver]
* kernel-modules-headers: Update to v0.0.18 [Andrei Gherzan]
* os-config: Update to v1.1.1 to fix mDNS [Andrei Gherzan]
* Fix busybox nslookup mdns lookups [Andrei Gherzan]
* Update balena-supervisor to v9.15.4 [Cameron Diver]
* Improve logging and version comparison in linux-firmware cleanup class [Andrei Gherzan]
* Sync ModemManager recipe with upstream [Andrei Gherzan]
* Update NetworkManager to 1.18.0 [Andrei Gherzan]

# v2.36.0
## (2019-05-20)

* Cleanup old versions of iwlwifi firmware files in Yocto Thud [Florin Sarbu]

# v2.35.0
## (2019-05-18)

* Update kernel-module-headers to version v0.0.16 [Florin Sarbu]
* Add uboot support for unified kernel cmdline arguments [Andrei Gherzan]
* Switch flasher detection in initramfs to flasher boot parameter [Andrei Gherzan]
* Update balena-supervisor to v9.15.0 [Cameron Diver]
* Improve boot speed by only mounting the inactive partition when needed [Zubair Lutfullah Kakakhel]
* Fix openssl dependency of balena-unique-key [Andrei Gherzan]
* Do not spawn getty in production images [Florin Sarbu]

# v2.34.1
## (2019-05-14)

* Update balena-supervisor to v9.14.10 [Cameron Diver]

# v2.34.0
## (2019-05-10)

* Add support to update a connectivity section in NetworkManager via config.json [Zubair Lutfullah Kakakhel]
* systemd: Fix journald configuration file [Andrei Gherzan]
* Add --max-download-attempts=10 to balenaEngine service to improve performance on shaky networks [Zubair Lutfullah Kakakhel]
* Update balena-engine to 18.09.5 [Zubair Lutfullah Kakakhel]
* Log initramfs messages to kernel dmesg to capture fsck, partition expand etc. command output [Zubair Lutfullah Kakakhel]
* kernel-resin: Add FAT fs specific configs to RESIN_CONFIGS [Sebastian Panceac]
* Update balena-supervisor to v9.14.9 [Cameron Diver]
* Introduce meta-balena yocto thud support [Andrei Gherzan]
* Update os-config to 1.1.0 [Andrei Gherzan]

# v2.33.0
## (2019-05-02)

* Fixes for sysroot symlinks creation [Andrei Gherzan]
* libmbim: Refresh patches after last update to avoid build warnings [Andrei Gherzan]
* modemmanager: Refresh patches after last update to avoid build warnings [Andrei Gherzan]
* Make security flags inclusion yocto version specific [Andrei Gherzan]
* systemd: Make directory warning patch yocto version specific [Andrei Gherzan]
* Replace wireless tools by iw [Andrei Gherzan]
* systemd: Use a conf.d file for journald configuration [Andrei Gherzan]
* Set go verison to 1.10.8 to match balena-engine requirements [Andrei Gherzan]
* Update balena-engine to 18.09.3 [Andrei Gherzan]
* Update balena-supervisor to v9.14.6 [Cameron Diver]
* resin-u-boot: make devtool-compatible [Sven Schwermer]
* docker-disk: Disable unnecessary docker pid check [Armin Schlegel]
* Update libmbim to version 1.18.0 [Zahari Petkov]
* Update libqmi to version 1.22.2 [Zahari Petkov]
* Update to ModemManager v1.10.0 [Zahari Petkov]
* Add a OS_KERNEL_CMDLINE parameter that allows BSPs to easily add extra kernel cmdline args to production images [Zubair Lutfullah Kakakhel]

# v2.32.0
## (2019-04-08)

* balena-supervisor: Update to v9.14.0 [Cameron Diver]
* readme: Replace resin with balena where appropriate [Roman Mazur]
* Add systemd-analyze to production images as well [Zubair Lutfullah Kakakhel]
* Enable dbus interface for dnsmasq [Zubair Lutfullah Kakakhel]
* Disable docker bridge while pulling the supervisor container to remove runtime balena-engine warnings [Zubair Lutfullah Kakakhel]
* Fix typo in os-networkmanager that prevented it from working [Zubair Lutfullah Kakakhel]
* Fix bug where fsck was run on the data partition on every boot even if it wasn't needed due to old system time. [Zubair Lutfullah Kakakhel]
* Fix the balena version string reported by balena-engine info [Zubair Lutfullah Kakakhel]
* Only check mmc devices for flasher image presence by default. [Zubair Lutfullah Kakakhel]
* Remove an extra redundant copy of udev rules database [Zubair Lutfullah Kakakhel]
* Un-upx mobynit and os-config to speed them up a bit. Approx 1 second boost to boot time. [Zubair Lutfullah Kakakhel]

# v2.31.5
## (2019-03-21)

* Update resin-supervisor to v9.11.3 [Andrei Gherzan]

# v2.31.4
## (2019-03-20)

* resin-supervisor: Recreate on start if config has changed [Rich Bayliss]

# v2.31.3
## (2019-03-20)

* Update resin-supervisor to v9.11.2 [Pablo Carranza Velez]

# v2.31.2
## (2019-03-19)

* Update resin-supervisor to v9.11.1 [Pablo Carranza Velez]

# v2.31.1
## (2019-03-18)

* Update resin-supervisor to v9.11.0 [Pablo Carranza Velez]

# v2.31.0
## (2019-03-08)

* README:md: Document dnsServers behaviour [Alexis Svinartchouk]
* Update resin-supervisor to v9.9.0 [Cameron Diver]
* Cleanup old versions of iwlwifi firmware files in Yocto sumo [Andrei Gherzan]
* Remove polkit dependency in balenaOS [Andrei Gherzan]
* Remove support for XFS file system [Andrei Gherzan]
* resin-init: update resin.io reference to balenaOS [Matthew McGinn]

# v2.30.0
## (2019-02-28)

* resin-supervisor: Recreate on start if config has changed [Rich Bayliss]
* Generate the temporary kernel-devsrc compressed archive in WORKDIR instead of B [Florin Sarbu]
* balena-engine: Update to include fix for signal SIGRTMIN+3 [Andrei Gherzan]
* Reduce sleeps while trying to mount partition to speed up boot [Zubair Lutfullah Kakakhel]
* resin-expand: Reduce sleep duration to speed up boot [Zubair Lutfullah Kakakhel]
* initrdscripts: Reduce sleep to speed up boot [Zubair Lutfullah Kakakhel]
* Make balena-host daemon socket activated to reduce baseline cpu/memory usage [Zubair Lutfullah Kakakhel]
* Update resin-supervisor to v9.8.6 [Cameron Diver]
* Add support for aufs 4.18.11+, 4.19, 4.20 variants and update 4.14, 4.14.56+, 4.15, 4.16, 4.17, 4.18 [Florin Sarbu]
* balena-engine: Bump to include runc patch [Andrei Gherzan]
* Improve kernel-module-headers for v4.18+ kernels [Zubair Lutfullah Kakakhel]
* Update balena-supervisor to v9.8.3 [Cameron Diver]
* Ask chrony to quickly take measurements from custom NTP servers when they are added [Zubair Lutfullah Kakakhel]
* Disable in-tree rtl8192cu driver [Florin Sarbu]
* Prevent rollbacks from running if the previous OS is before v2.30.0 [Zubair Lutfullah Kakakhel]
* Change rollbacks to accept hex partition numbers for jetsons [Zubair Lutfullah Kakakhel]
* Convert partition numbers to hex in u-boot hook. Shouldn't affect any device. [Zubair Lutfullah Kakakhel]
* Reduce default reboot/poweroff timeouts from 30 minutes to 10 minutes [Zubair Lutfullah Kakakhel]
* Configure systemd tmpfiles to ignore supervisor tmp directories [Andrei Gherzan]
* Fixed "Can't have overlapping partitions." error in flasher [Alexandru Costache]
* Define default DNS servers behaviour with and without google DNS [Andrei Gherzan]
* Update balena-supervisor to v9.4.2 [Cameron Diver]
* Fix for some warnings [Zubair Lutfullah Kakakhel]
* Fix tini filename after balena-engine rename [Andrei Gherzan]
* Fix nm dispatcher hook when there are no custom ntp servers in config.json [Zubair Lutfullah Kakakhel]
* Improve persistent logging systemd service dependencies [Zubair Lutfullah Kakakhel]
* Update balena-supervisor to v9.3.0 [Cameron Diver]
* Use the new revision for balena source code [Florin Sarbu]
* Add a workaround for a bug where the chronyc online command in network manager hook would get stuck and eat cpu cycles [Zubair Lutfullah Kakakhel]
* Fix img to rootfs dependency when img is invalidated [Andrei Gherzan]
* Have boot partition type configurable as FAT32 [Andrei Gherzan]
* Deprecate morty and krogoth [Zubair Lutfullah Kakakhel]
* Deploy kernel source as a build artifact as well for external module compilation [Zubair Lutfullah Kakakhel]
* kernel-devsrc: Tarball up the kernel source and deploy it. [Zubair Lutfullah Kakakhel]
* kernel-modules-headers: Use the build directory for artifacts [Zubair Lutfullah Kakakhel]
* docs: Add documentation on nested changelogs [Giovanni Garufi]
* VersionBot: update upstream name and url [Giovanni Garufi]

# v2.29.0
## (2018-12-19)

* OS will default apps.json to an empty json file [Andrei Gherzan]
* Update balena-engine to include low entropy fixes [Andrei Gherzan]
* Move an NM patch to the right place to reduce a warning [Zubair Lutfullah Kakakhel]
* Update balena-supervisor to v9.0.1 [Pablo Carranza Velez]
* Fix cases where RESIN_BOOT_PARTITION_FILES includes invalid entries [Andrei Gherzan]
* Enable some common linux kernel serial device drivers [Andrei Gherzan]
* Configure NetworkManager to only ignore our vpn interface but manage other tun devices [Andrei Gherzan]
* networkmanager: Add pppd to FILES [Zubair Lutfullah Kakakhel]
* networkmanager: Add balena-client-id.patch in bbappend [Zubair Lutfullah Kakakhel]
* Bump network manager from v1.12.2 to v1.14.4 [Zubair Lutfullah Kakakhel]
* Update balena-supervisor to v8.7.0 [Pablo Carranza Velez]
* Fix test cases for kernel module header compilation [Zubair Lutfullah Kakakhel]
* Add chrony v3.2 recipe in various layers to keep minimum chrony version on devices above v3.2 [Zubair Lutfullah Kakakhel]
* chrony/pyro: Add v3.2 recipe [Zubair Lutfullah Kakakhel]
* chrony/morty: Add v3.2 recipe [Zubair Lutfullah Kakakhel]
* chrony/krogoth: Bump recipe version to v3.2 [Zubair Lutfullah Kakakhel]
* Update resin-supervisor to v8.6.8 [Zubair Lutfullah Kakakhel]

# v2.28.0
## (2018-12-05)

* Update os-config to 1.0.0 [Zahari Petkov]
* Update libqmi to version 1.20.2 [Florin Sarbu]
* Update libmbim to version 1.16.2 [Florin Sarbu]
* kernel-modules-headers: Add basic sanity test [Zubair Lutfullah Kakakhel]
* Fix kernel module header generation [Zubair Lutfullah Kakakhel]
* image-resin.bbclass: Fix config.json pretty format [Andrei Gherzan]
* Allow supervisor update on unmanaged devices [Andrei Gherzan]
* Update resin-supervisor to v8.6.3 [Cameron Diver]

# v2.27.0
## (2018-11-23)

* Expose randomMacAddressScan config.json knob [Andrei Gherzan]
* Move modemmanager udev rules in /lib/udev/rules.d [Andrei Gherzan]
* Fix modemmanager bbappend files [Andrei Gherzan]
* dnsmasq: Define 8.8.8.8 as a fallback nameserver [Andrei Gherzan]
* Increase timeout for filesystem label [Vicentiu Galanopulo]
* Add support for Huawei ME936 modem in MBIM mode [Florin Sarbu]
* Backport systemd sd-shutdown improvements for sumo versions [Florin Sarbu]
* Include avahi d-bus introspection files in rootfs [Andrei Gherzan]
* Fix custom udev rules when rule is removed from config.json [Zubair Lutfullah Kakakhel]
* resin-mounts: Add NetworkManager conf.d bind mounts [Zubair Lutfullah Kakakhel]
* Add support to pass custom configuration to NetworkManager [Zubair Lutfullah Kakakhel]
* README.md: Add info about SSH and Avahi services [Andrei Gherzan]
* Avoid xtables lock in resin-proxy-config [Andrei Gherzan]
* Migrate the supervisor to balena repositories [Florin Sarbu]
* Update balena-supervisor to v8.3.5 [Cameron Diver]
* Update supported modems list [Florin Sarbu]

# v2.26.0
## (2018-11-05)

* Rename resin-unique-key to balena-unique-key [Andrei Gherzan]
* Don't let resin-unique-key rewrite config.json [Andrei Gherzan]

# v2.25.0
## (2018-11-02)

* Generate ssh host key at first boot (not at first connection) [Andrei Gherzan]
* Fix extraneous space in kernel-resin.bbclass config [Florin Sarbu]
* Drop obsolete eval from kernel-resin's do_kernel_resin_reconfigure [Florin Sarbu]
* Add SyslogIdentifier for balena and resin-supervisor healthdog services [Matthew McGinn]

# v2.24.1
## (2018-11-01)

* Update resin-supervisor to v8.0.0 [Pablo Carranza Velez]

# v2.24.0
## (2018-10-24)

* Resin-info: Small tweak for balenaCloud product [Andrei Gherzan]
* Update resin-supervisor to v7.25.8 [Pablo Carranza Velez]
* Rename resinOS to balenaOS [Andrei Gherzan]

# v2.23.0
## (2018-10-22)

* Update resin-supervisor to v7.25.5 [Cameron Diver]
* Recipes-containers: Increase healthcheck timeout to 180s [Gergely Imreh]
* .gitignore: add node_modules and package-lock files [Giovanni Garufi]

# v2.22.1
## (2018-10-20)

* Update resin-supervisor to v7.25.3 [Pablo Carranza Velez]

# v2.22.0
## (2018-10-19)

* Update resin-supervisor to v7.25.2 [Andrei Gherzan]
* Include a CONTRIBUTING.md file [Andrei Gherzan]
* Update to ModemManager v1.8.2 [Andrei Gherzan]
* Updates on contributing-device-support.md [Vicentiu Galanopulo]

# v2.21.0
## (2018-10-18)

* Improve systemd service ordering in rollbacks [Zubair Lutfullah Kakakhel]
* Update resin-supervisor to v7.24.1 [Andrei Gherzan]

# v2.20.0
## (2018-10-18)

* Avoid expander on flasher based on root kernel argument [Andrei Gherzan]
* Resin-vars: Implement custom ssh keys service [Andrei Gherzan]
* Fix redsocks interface creation when no proxy configured [Andrei Gherzan]
* Replace NM's DHCP request option "Client indentifier" with udhcpc style option [Sebastian Panceac]
* Fix for rollbacks in case of old balenaOS version [Zubair Lutfullah Kakakhel]
* Update resin-supervisor to v7.21.4 [Cameron Diver]
* Warn if rules are found in /etc/udev/rules.d [Zubair Lutfullah Kakakhel]
* Add support to load custom udev rules from config.json [Zubair Lutfullah Kakakhel]
* Aufs-util: Package auplink separately [Florin Sarbu]
* Enable kernel config dependencies for MBIM and QMI [Florin Sarbu]
* Set UPX to use LZMA compression by default [Andrei Gherzan]
* Downgrade UPX to 3.94 for ARM [Andrei Gherzan]
* Balena update for rollbacks. mobynit can now mount rootfs from sysroot. [Zubair Lutfullah Kakakhel]
* Fix proxy when using containers over bridge network [Andrei Gherzan]
* Add support for aufs 4.9.9+, 4.9.94+, 4.18 [Florin Sarbu]
* Add rollback-altboot service before balena service [Zubair Lutfullah Kakakhel]
* Add Automated Rollback recipe [Zubair Lutfullah Kakakhel]
* Add Automated Rollback support in u-boot env_resin.h [Zubair Lutfullah Kakakhel]
* Add a hook to support Automated Rollbacks [Zubair Lutfullah Kakakhel]
* Update HUP grub hook to support Automated Rollbacks [Zubair Lutfullah Kakakhel]
* Update HUP u-boot hook to support Automated Rollbacks [Zubair Lutfullah Kakakhel]
* Move kernel-image-initramfs from resin-image recipe to packagegroup-resin.inc [Zubair Lutfullah Kakakhel]
* Have 99-resin-grub hostapp-update-hook decide which grub to use [Florin Sarbu]

# v2.19.0
## (2018-09-23)

* Update Balena to fix tty console hanging in some cases [Petros Angelatos]
* Pin down cargo deps (using Cargo.lock) to versions known working with rust 1.24.1 (for sumo) [Florin Sarbu]
* Remove duplicate packaging of bcm43143 [Florin Sarbu]
* Set ModemManager to ignore Inca Roads Serial Device [Petros Angelatos]
* Add support for aufs 4.14.56+ [Florin Sarbu]
* Update resin-supervisor to v7.19.7 [Cameron Diver]

# v2.18.1
## (2018-09-14)

* Add a parsable representation of the changelog [Giovanni Garufi]

# v2.18.0
## (2018-09-12)

* Update grub hooks to prepare to load kernel from root [Zubair Lutfullah Kakakhel]
* Update resin-supervisor to v7.19.4 [Cameron Diver]
* Kernel-resin.bbclass: Enable CONFIG_IP_NF_TARGET_LOG as a module [John (Jack) Brown]
* Balena: Update to current HEAD of 17.12-resin [Andrei Gherzan]
* Compress os-config with UPX on arm64 too [Andrei Gherzan]
* Update upx to 3.95 [Andrei Gherzan]
* Add support to skip flasher detection in env_resin.h [Zubair Lutfullah Kakakhel]
* Add the kernel to the rootfs [Zubair Lutfullah Kakakhel]
* Rework resin-supervisor systemd dependency on balena [Florin Sarbu]
* Enhanced security options for dropbear - sumo [Andrei Gherzan]
* Enhanced security options for dropbear - rocko [Andrei Gherzan]
* Enhanced security options for dropbear - pyro [Andrei Gherzan]
* Enhanced security options for dropbear - morty [Andrei Gherzan]
* Enhanced security options for dropbear - krogoth [Andrei Gherzan]

# v2.17.0
## (2018-09-03)

* Resin-proxy-config: The no_proxy file fails to parse when missing EOL [Rich Bayliss]

# v2.16.0
## (2018-08-31)

* Os-config: UPX is broken on aarch64 [Theodor Gherzan]
* Allow flasher types to pin preloaded devices [Theodor Gherzan]
* Disable PIE for go [Zubair Lutfullah Kakakhel]
* Disable PIE for balena [Zubair Lutfullah Kakakhel]

# v2.15.0
## (2018-08-28)

* Bump balena version to latest 17.12-resin [Zubair Lutfullah Kakakhel]
* Update NetworkManager to 1.12.2 [Andrei Gherzan]
* Avoid os-config-devicekey / uuid service race [Andrei Gherzan]
* Move the rw copy of config.json out of /tmp for flasher [Andrei Gherzan]
* Fix dashboard feedback on fast flashing devices [Andrei Gherzan]
* Fix ucl dependency in upx [Andrei Gherzan]
* Update kernel-modules-headers to v0.0.11 [Andrei Gherzan]

# v2.14.3
## (2018-08-13)

* Update resin supervisor to v7.16.6 [Cameron Diver]

# v2.14.2
## (2018-08-13)

* Update usb-modeswitch to version 2.5.0 [Florin Sarbu]
* Fix kernel-modules-headers compile missing bio.h [Florin Sarbu]
* Enable kernel config CONFIG_USB_SERIAL_CP210X as module [Andrei Gherzan]
* Update resin supervisor to v7.16.4 [Cameron Diver]

# v2.14.1
## (2018-08-02)

* Fix ModemManager journald logs [Andrei Gherzan]
* Fix openvpn journald logs [Andrei Gherzan]
* Set maximum openvpn reconnect timeout to 2 minutes [Andrei Gherzan]
* Resin-image: Handle absolute paths in RESIN_BOOT_PARTITION_FILES [Andrei Gherzan]
* Exclude writable files from image's fingerprints file [Andrei Gherzan]
* Update resin-supervisor to v7.16.2 [Andrei Gherzan]
* Use v4 API calls, move auth token into the request header [Gergely Imreh]
* Fix no-pie variable name in tini rocko [Andrei Gherzan]
* Fix alternative builds warnings in busybox [Andrei Gherzan]
* Don't compile mobynit in rocko with PIE [Andrei Gherzan]
* Fix key replace build warnings [Andrei Gherzan]
* Update go in krogoth to v1.9.4 [Andrei Gherzan]
* Update go in morty to v1.9.4 [Andrei Gherzan]
* Update go in pyro to v1.9.4 [Andrei Gherzan]
* Update balena to version 17.12 [Andrei Gherzan]
* Fix when ntp servers passed via config.json and dhcp [Zubair Lutfullah Kakakhel]
* Disable PIE for the aufs-util package for Rocko boards [Andrei Gherzan]
* Disable PIE for the aufs-util package for Sumo boards [Florin Sarbu]
* Update resin supervisor to v7.16.0 [Andrei Gherzan]
* Document supported modems [Andrei Gherzan]

# v2.14.0
## (2018-07-17)

* Allow re-run of useradd commands in docker-disk's entry.sh [Andrei Gherzan]
* Update rust to 1.20 and cargo to 0.21.0 in Morty [Andrei Gherzan]
* Update rust to 1.20 and cargo to 0.21.0 in Krogoth [Andrei Gherzan]
* Unify managed and unmanaged images and introduce os-config [Andrei Gherzan]

# v2.13.6
## (2018-07-13)

* Update resin-supervisor v 7.14.0 [Cameron Diver]
* Fix rootfs fingerprints on poky rocko or newer [Andrei Gherzan]
* Reboot device if there is a kernel panic [Zubair Lutfullah Kakakhel]

# v2.13.5
## (2018-07-09)

* Update resin-supervisor to v7.13.2 [Cameron Diver]

# v2.13.4
## (2018-07-09)

* Avoid overwriting SECURITY_CFLAGS for tini recipe [Andrei Gherzan]
* Fix tini segfault after sumo update [Andrei Gherzan]

# v2.13.3
## (2018-07-05)

* Update ModemManager to 1.8.0 [Andrei Gherzan]
* Switch NetworkManager to using the internal DHCP client [Andrei Gherzan]
* Update NetworkManager to 1.12.0 [Andrei Gherzan]
* Update resin-supervisor to 7.13.1 [Cameron Diver]

# v2.13.2
## (2018-06-28)

* Update balena to fix boot lag [Andrei Gherzan]
* Set DHCP timeout to infinity for IPv4 [Florin Sarbu]
* Add aufs support for kernels 4.15, 4.16 and 4.17 [Florin Sarbu]

# v2.13.1
## (2018-06-15)

* Fix mobynit runtime crash when compiled with gcc 7.3.0 with static PIE support enabled [Florin Sarbu]
* Fix typo in balena systemd service [Andrei Gherzan]
* Various fixes for issues introduced by the switch to chrony [Andrei Gherzan]
* Fsck all partitions if resin-data isn't seen [Zubair Lutfullah Kakakhel]
* Remove jethro and fido yocto versions support [Andrei Gherzan]
* Update resin-supervisor to 7.11.0 [Cameron Diver]
* Replace systemd-timesyncd with chrony [Zubair Lutfullah Kakakhel]
* Set ModemManager to ignore STM32F407 devices [Andrei Gherzan]

# v2.13.0
## (2018-06-06)

* Update resin-supervisor to 7.10.0 [Cameron Diver]
* Add support for yocto sumo [Andrei Gherzan]
* Update Readme.md with more yocto versions [Zubair Lutfullah Kakakhel]
* Docker-resin-supverisor-disk: Update supervisor to version 7.9.0 [Akis Kesoglou]
* Docker-resin-supverisor-disk: Update supervisor to version 7.5.6 [Cameron Diver]

# v2.12.7
## (2018-05-04)

* Fix typo in timeinit-timestamp service [Andrei Gherzan]
* Use system clock at boot based on RTC when available [Andrei Gherzan]
* Update Network Manager to version 1.10.2 [Florin Sarbu]
* Adds Teensy udev rules [Henry Miskin]

# v2.12.6
## (2018-04-30)

* Initialize system clock using the build time [Andrei Gherzan]
* Fix typo in resin-mounts [Mans Zigher]
* Update supervisor to v7.4.3 [Pablo Carranza Velez]
* Update supervisor to v7.4.2 [Akis Kesoglou]
* Move to Supervisor v7.4.1. [Heds Simons]
* Pass self-signed CA data to the Supervisor and for Docker registry trust. [Heds Simons]
* Extract `balenaRootCA` property from `config.json` to allow interoperation with a self-signed service. [Heds Simons]
* Split resin specific changes in dnsmasq in a separate bbappend [Andrei Gherzan]
* Allow not existing supervisor.conf file [Bruno Binet]
* Remove remnants of 1.x updater, which is not needed anymore [Gergely Imreh]
* Allow update resin spervisor when API endpoint is not available [Andrei Gherzan]
* Apply upstream patch for redsocks to fix http-config regression [Gergely Imreh]
* Update supervisor to v7.1.20 [Akis Kesoglou]

# v2.12.5
## (2018-03-22)

* Fig slang configure build warning [Andrei Gherzan]
* Fix racing issue of state label existance in initramfs [Andrei Gherzan]
* Stop dependending on udev settle at boot [Andrei Gherzan]

# v2.12.4
## (2018-03-20)

* Fix persistent logging [Andrei Gherzan]
* USB Modem (CDC ACM) support enabled as kernel module [Andrei Gherzan]
* Update supervisor to v7.1.18 [Pablo Carranza Velez]
* Add support for persistent NetworkManager state directory [Andrei Gherzan]

# v2.12.3
## (2018-03-15)

* Update supervisor to v7.1.14 [Florin Sarbu]

# v2.12.2
## (2018-03-14)

* Update supervisor to v7.1.11 [Akis Kesoglou]
* Balena: Update package to include deadlock fix [Andrei Gherzan]
* Remove bashisms in resin-init-flasher recipe [Andrei Gherzan]

# v2.12.1
## (2018-03-12)

* Disable openvpn time-based tls key renegotiation [Will Boyce]

# v2.12.0
## (2018-03-09)

* Update supervisor to v7.1.7 [Theodor Gherzan]

# v2.11.2
## (2018-03-09)

* Update supervisor to v7.1.3 [Andrei Gherzan]

# v2.11.1
## (2018-03-08)

* Resin-vars: Assume VPN port 443 if 1723 is provided in config.json [Andrei Gherzan]
* Make update-resin-supervisor POSIX compliant [Andrei Gherzan]
* Add resin-openvpn.service alias for openvpn.service [Andrei Gherzan]

# v2.11.0
## (2018-03-08)

* Fix docker-disk when docker build fails to not leave root files behind [Andrei Gherzan]
* Update supervisor to v7.1.0 [Pablo Carranza Velez]
* Fix connectivity in flasher images [Andrei Gherzan]
* Add missing kernel config dependency for leds-gpio [Andrei Gherzan]

# v2.10.1
## (2018-02-28)

* Fix docker-disk when not including any docker image [Florin Sarbu]

# v2.10.0
## (2018-02-27)

* Make sure rocko update doesn't add packages resinOS doesn't depend on [Andrei Gherzan]
* Run bluetoothd with --experimental flag [Andrei Gherzan]
* Resin-image-flasher fixes for rocko support [Andrei Gherzan]
* Use the correct, full yocto CC/CXX variables when using go [Andrei Gherzan]
* Fix 8000c in PACKAGES [Andrei Gherzan]
* Always have /lib/modules directory in rootfs as supervisor requires it [Andrei Gherzan]
* Fix console output when running resinOS with systemd >= 232 [Andrei Gherzan]
* Bring back the package which includes firmware for wilwifi 8000c [Andrei Gherzan]
* Update OpenVPN to 2.4.3 [Andrei Gherzan]
* Replace deprecated variable IMAGE_DEPENDS from image_types_resin.bbclass [Florin Sarbu]
* Replace deprecated variable IMAGE_DEPENDS from resin-image-flasher.bb [Florin Sarbu]
* Adapt sysroot services/units to be used with resinOS in container [Andrei Gherzan]
* Remove deprecated firmware: 8000c [Andrei Gherzan]
* Resin-state-reset: This service now only removes the root-overlay [Andrei Gherzan]
* Fix resin-provisioner 1.0.4 compile error on Poky Rocko [Florin Sarbu]
* Make resin-provisioner only package the resulted go binary [Florin Sarbu]
* Prepare the balena recipe for Poky Rocko [Florin Sarbu]
* Use update-alternatives for deploying resolv.conf through dnsmasq [Florin Sarbu]
* Make ModemManager depend on libxslt-native at build-time for Poky Rocko [Florin Sarbu]
* Add initial structure for supporting Poky Rocko [Florin Sarbu]
* Do not apply the use_atomic_key_generation_in_all_cases patch for dropbear 2017.75 or newer [Florin Sarbu]
* Make image-resin.bbclass depend on jq-native at buildtime [Florin Sarbu]
* Fix ucl-native ACC conformance test configure error on gcc6 [Florin Sarbu]
* Update ModemManager to version 1.7.990 [Florin Sarbu]
* Rename partition mount services to <label>.service and handle stopping services [Andrei Gherzan]
* Rename openvpn-resin service to openvpn [Andrei Gherzan]
* Kernel-resin: Fix warnings about CONFIG_DEVPTS_MULTIPLE_INSTANCES [Andrei Gherzan]
* Update supervisor to v6.6.3 [Pablo Carranza Velez]
* Let systemd handle openvpn run directory [Andrei Gherzan]
* Add support for running resinOS in a docker container [Andrei Gherzan]
* Add fs check for boot partition in initramfs [Andrei Gherzan]
* Fix kernel-modules-headers when building from sstate [Andrei Gherzan]
* Avoid mount warnings when using systemd mount units on files [Andrei Gherzan]
* Add support for private docker registry [Bruno Binet]
* Docker-disk: Various improvements [Andrei Gherzan]
* Networkmanager: Use bash-completion bbclass [Andrei Gherzan]
* Use VPN port from config.json (defaulting it to 443) [Andrei Gherzan]
* Housekeeping: adding PR template [Gergely Imreh]
* Replace busybox less by GNU less [Andrei Gherzan]
* Fix BALENA_STORAGE when machine specific definition is used [Andrei Gherzan]
* Coreutils: Set uptime to use procfs for accurate uptime [Andrei Gherzan]

# v2.9.7
## (2018-01-26)

* Install os-release file in the boot partition [Andrei Gherzan]
* Update balena to include locks fix [Andrei Gherzan]
* Healthdog: Fix RPATH on newer meta-rust [Andrei Gherzan]
* Update supervisor to v6.6.0 [Pablo Carranza Velez]

# v2.9.6
## (2018-01-12)

* Update supervisor to v6.5.9 [Pablo Carranza Velez]

# v2.9.5
## (2018-01-11)

* Update supervisor to v6.5.8 [Pablo Carranza Velez]

# v2.9.4
## (2018-01-10)

* Systemd: Backport patch to fix Remote DOS of systemd-resolve service [Andrei Gherzan]
* Hostapp-update: Bind mount /dev from host so we can resolv labels [Andrei Gherzan]
* NetworkManager: Allow managing "non-balena" bridge interfaces [Andrei Gherzan]

# v2.9.3
## (2018-01-09)

* Add lsof package [Florin Sarbu]
* Bring back resin-device-progress in resin-image [Andrei Gherzan]
* Update supervisor to v6.5.7 [Pablo Carranza Velez]
* Make hostapp-update-hooks rollback on failure optional [Gergely Imreh]

# v2.9.2
## (2017-12-18)

* Activate memory/swap cgroups in kernel [Andrei Gherzan]
* Make the grub hostapp update hook also work with non-EFI grub configs [Florin Sarbu]

# v2.9.1
## (2017-12-12)

* Update supervisor to v6.5.3 [Pablo Carranza Velez]
* Pass /mnt/root/var/lib/docker as DOCKER_ROOT to the supervisor [Florin Sarbu]

# v2.9.0
## (2017-12-11)

* Update supervisor to v6.5.1 [Pablo Carranza Velez]
* Use healthcheck with systemd and healthdog for supervisor [Andrei Gherzan]
* Update supervisor to v6.5.0 [Pablo Carranza Velez]
* Fix openvpn reporting when connectivity goes out, due to a filesystem permissions issue [Pablo Carranza Velez]
* Update balena cu include healthcheck support [Andrei Gherzan]
* Add healthdog monitoring of balena [Andrei Gherzan]
* Run the update container as privileged [Florin Sarbu]
* Fix 0-bootfiles when running hooks [Andrei Gherzan]
* Add the lsblk binary to the flasher rootfs [Florin Sarbu]
* Add boot partition space check for 0-bootfiles hostapp-update hook [Andrei Gherzan]
* Fix hostapp-update to run the hooks for the OS we update to [Andrei Gherzan]
* Switch to balena [Andrei Gherzan]

# v2.8.1
## (2017-12-01)

* Kernel-modules-headers: Include aarch64 fix [Theodor Gherzan]

# v2.8.0
## (2017-11-30)

* Support for legacy bootloaders [Theodor Gherzan]
* Update NetworkManager to version 1.10.0 [Florin Sarbu]
* Update aufs for kernel versions from 4.4 to 4.13 [Florin Sarbu]

# v2.7.8
## (2017-11-17)

* Do our best to ensure we copy to internal media the config.json after resin-device-register was able to register the board [Florin Sarbu]

# v2.7.7
## (2017-11-17)

* Delete the provisioning key after registering, to fix VPN authentication in flasher images [Pablo Carranza Velez]
* Resin-image-initramfs: Include ext4 filesystem check module in our initramfs [Florin Sarbu]
* Hostapp-update-hooks: fix typos in hook [Gergely Imreh]
* Image-resin.bbclass: Add build time dependency on coreutils-native [Florin Sarbu]
* Hostapp-update-hooks: Use boot files list from the 'next' OS [Andrei Gherzan]
* Add required kernel config dependency for being able to use redsocks [Florin Sarbu]
* Check for enough space in boot partition to support atomic copy operations [Andrei Gherzan]
* Update libmbim to version 1.14.2 [Florin Sarbu]
* Update libqmi to version 1.18.0 [Florin Sarbu]

# v2.7.6
## (2017-11-06)

* Add supervisor for the intel-quark family [Theodor Gherzan]
* Update ModemManager to version 1.6.10 [Florin Sarbu]
* Update supervisor to v6.4.2 [Pablo Carranza Velez]

# v2.7.5
## (2017-10-30)

* Ensure OpenVPN is restarted when config.json changes [Will Newton]
* Support grub boards with hostapp-update-hooks [Theodor Gherzan]

# v2.7.4
## (2017-10-24)

* Update supervisor to v6.3.6 [Pablo Carranza Velez]

# v2.7.3
## (2017-10-20)

* Update API call in update-resin-supervisor for pine 5 [Gergely Imreh]
* Fix start-resin-supervisor to start even when no supervisor image present [Gergely Imreh]
* Update supervisor to v6.3.5 [Akis Kesoglou]
* Fix fsck of boot partition with dosfstools [Will Newton]
* Backport ModemManager flow control patches [Will Newton]
* Update dnsmasq to 2.78 [Will Newton]

# v2.7.2
## (2017-10-05)

* Fix mkfs.hostapp-ext4 with pyro [Andrei Gherzan]
* Fix a syntax error in image_types_resin [Andrei Gherzan]
* Add a fixed goarch.bbclass for pyro [Will Newton]
* Docker: Improved pull progress reporting [Akis Kesoglou]
* Update supervisor to v6.3.1 [Akis Kesoglou]

# v2.7.1
## (2017-10-04)

* Update docker [Theodor Gherzan]
* Ensure docker links with systemd in pyro [Will Newton]

# v2.7.0
## (2017-10-04)

* Add support for overaly2 in mobynit [Theodor Gherzan]
* GPT support [Theodor Gherzan]
* Update-resin-supervisor: device API key is substituted incorrectly [Gergely Imreh]
* Support kernel 4.13 [Will Newton]
* Update supervisor to v6.3.0 [Akis Kesoglou]

# v2.6.1
## (2017-09-27)

* Fixes for Pyro-based flasher images [Will Newton]
* Sort config.json keys [Will Newton]

# v2.6.0
## (2017-09-20)

* Provide generic hostapp update hooks [Andrei Gherzan]
* Deploy a list of boot files in root partition [Andrei Gherzan]
* Update supervisor to v6.2.9 [Pablo Carranza Velez]
* Add usbutils package [Will Newton]
* Switch docker to inherit from Go class [Will Newton]
* Enable zram kernel module by default [Will Newton]
* Make sure hci bluetooth interfaces are activated once booted [Florin Sarbu]
* Enable kernel stack protection [Will Newton]
* Enable Yocto security flags on all builds [Will Newton]
* Update gnutls to 3.5.9 in morty because of blocking NetworkManager [Robert Fritzsche]

# v2.5.1
## (2017-09-13)

* Force use of host's docker daemon for the docker-disk recipe [Florin Sarbu]
* Remove unused plymouth files to reduce size [Michal Mazurek]

# v2.5.0
## (2017-09-12)

* Remove obsolete Go recipes [Will Newton]
* Dynamically link docker [Petros Angelatos]
* Include connectivity firmwares in Pyro [Will Newton]
* Add glib-2.0-native dependencies for Pyro [Will Newton]
* Switch to hostapp enabled rootfs [Petros Angelatos]
* Update docker to 17.06 [Petros Angelatos]
* Update modem manager to 1.6.8 [Andrei Gherzan]
* Use poky go recipes for Pyro and above [Will Newton]
* Patch mtools directory creation [Will Newton]
* Enable building Docker on Yocto Pyro [Will Newton]
* Enable fsck for resin-state partition [Will Newton]
* Add host tool dependencies for Yocto Pyro [Will Newton]
* Move systemd sanity check to image recipes [Will Newton]
* Disable rarely used kernel configs for size [Will Newton]

# v2.4.2
## (2017-08-31)

* Update NetworkManager to 1.8.2 [Andrei Gherzan]
* Only install systemd-analyze in development images [Will Newton]
* Avoid removing the supervisor container when the supervisor exits [Pablo Carranza Velez]
* Update supervisor to v6.2.5 [Pablo Carranza Velez]

# v2.4.1
## (2017-08-24)

* Fix variable referencing in default variable substitution inside prepare-openvpn script [Florin Sarbu]

# v2.4.0
## (2017-08-23)

* Use separate line for version in changelog file [Andrei Gherzan]
* Run OpenVPN service as openvpn user [Andreas Fitzek]
* Update supervisor to v6.2.1 [Akis Kesoglou]
* Watch for VPN config changes in config.json [Pagan Gazzard]

# v2.3.0
## (2017-08-16)

* Resize the splash logo to full screen instead of half screen [Gergely Imreh]
* Set docker bridge subnet to 10.114.101.1/24 [Petros Angelatos]
* Re-enable UPX compression on AArch64 [Will Newton]
* Resin-device-progress: fix typos that broke script [Gergely Imreh]
* Upgrade upx to 3.94 [Will Newton]
* Set deviceType in config.json [Will Newton]
* Update supervisor to v6.1.3 [Pablo Carranza Velez]
* Fix typo in resin-persistent-logs [Will Newton]
* Use BBCLASSEXTEND rather than inherit native [Florin Sarbu]

# v2.2.0
## (2017-07-28)

* Update supervisor to v6.1.2 [Pablo Carranza Velez]
* Support building with Yocto Pyro [Will Newton]
* Disable resin-sample NetworkManager connection [Will Newton]
* Remove support for Yocto Daisy [Will Newton]

# v2.1.0
## (2017-07-19)

* Update supervisor to v6.0.1 [Pablo Carranza Velez]
* Add support for overlay2 as docker storage driver [Andrei Gherzan]
* Detect filesystem type automatically in resin mount systemd services [Michal Mazurek]
* Fix util-linux to work with ubifs [Michal Mazurek]
* Allow setting DNS servers in config.json [Will Newton]
* Make sure resin-state-reset doesn't end up in an inconsistent state [Andrei Gherzan]
* Remove latest supervisor tag as it is not used anymore [Andrei Gherzan]
* Add NTP configuration service [Will Newton]
* Use full list of resin NTP servers [Will Newton]
* Document config.json keys in README.md [Will Newton]
* Document Change-type and Changelog-entry git commit footers [Andrei Gherzan]
* Add systemd as a required distro feature [Will Newton]

# v2.0.9
## (2017-07-06)

* Fix splash image migration in flasher images [Andrei Gherzan]
* Add missing netfilter configs for our redsocks usage [Florin Sarbu]

# v2.0.8
## (2017-07-04)

* Resin-vars: Fetch all the vars in resin-vars [Pagan Gazzard]
* Add comment in supervisor.conf for clarity [Petros Angelatos]
* Prevent supervisor from killing itself [Pablo Carranza Velez]
* Store both image and tag in the temporary supervisor.conf [Pablo Carranza Velez]
* Use current changelog format with versionist [Andrei Gherzan]
* Update supervisor to v5.1.0 and use aarch64-supervisor for aarch64 [Pablo Carranza Velez]
* Validate docker config from disk to avoid panicing [Petros Angelatos]
* Versionist: add support for full versionist use [Gergely Imreh]

# v2.0.7
## (2017-06-28)

* Add support for transparent proxy redirection using redsocks [Pablo]
* Add prerequisites for ipk packages in resinOS images [Andrei]
* Update supervisor to v5.0.0 [Pablo]
* Allow downloading a missing supervisor [Will]
* Add busybox patch to fix tar unpacking [Will]
* Include support for the RT5572 wireless chipset [Theodor]
* Add a quirk for /etc/mtab [Will]
* Switch to resin.io ntp pool [petrosagg]
* Undefine backwards compatibilty variable, INITRAMFS_TASK [Theodor]
* Enable CONFIG_KEYS, docker 17 requirment [Theodor]
* Update NetworkManager to 1.8.0 [Andrei]
* Update supervisor to v4.3.1 [Andrei]
* Set NetworkManager connection attempts to infinity [petrosagg]
* Update Docker to 17.03.1 [Theodor]
* Include fsck.vfat in resinOS [Andrei]

# v2.0.6
## (2017-06-06)

* Update supervisor to v4.2.4 [Pablo]

# v2.0.5
## (2017-06-02)

* Fix dependencies for mount service in /var/lib [Andrei]
* Various build fixes when using other package formats like ipk [Andrei]
* Define IMAGE_NAME_SUFFIX, needed for resinhup, for Yocto versions older than Morty [Florin]
* Add support for modifying the regulatory domain for wifi interfaces [Michal]
* Add support for qmi and mbim cell modems [Joshua]
* Disable all password logins on production images, rather than just root logins - this gets rid of the password prompt dialog that users have seen. [Page]

# v2.0.4
## (2017-05-16)

* Enable the resin-uboot implementation to also boot flasher images from USB media [Florin]
* Use supervisor tag as supervisor recipe PV [Andrei}

# v2.0.3
## (2017-05-10)

* Copy resinOS_uEnv.txt from external to internal media [Theodor]
* Fix resin-state-conf copying mechanism [Theodor]
* Don't fingerprint config.json [Andrei]
* Prevent resin-unique-key from running concurrently [Michal]
* Add iwlwifi 8265 firmware [Florin]
* Disable coredumps [Jon]
* Add bind mounts for systemd persistent data [Jon]
* Update supervisor to v4.2.2 [Page]
* Explicitly set CONFIG_HIDRAW=y [Michal]
* Fix symlink creation in resinhup_backwards_compatible_link() [Michal]

# v2.0.2
## (2017-04-24)

* Fix build of kernel-modules-headers on kernel 4.8+ [Andrei]
* Use ondemand as default governor [Andrei]
* Do not force fsck on the data partition [Theodor]
* Switch to the new device register endpoint which exchanges the provisioning key for a device api key [Page]
* Switch to using a device api key for api calls and vpn authentication if it is present [Page]

# v2.0.1
## (2017-04-19)

* Don't use getty generator even for development images [Andrei]
* Fix resinos-img image compression [Theodor]
* Revert 05288ce19781f9ab3b8c528f49537516b58db050 [Theodor]
* Update NetworkManager to version 1.6.2 [Florin]
* Update supervisor to v4.1.2 [Pablo]
* Add aufs hashes for more kernel versions [fboudra]
* Calculate IMAGE_ROOTFS_MAXSIZE dynamically [fboudra]
* Don't attempt UPX compression on aarch64 [fboudra]
* Tidy arch detection in kernel-modules-headers [fboudra]

# v2.0.0
## (2017-03-31)

# v2.0.0-rc6
## (2017-03-31)

* Update supervisor to v4.1.1 [Pablo]
* Replace echo with info in the resindataexpander initramfs script [Florin]
* Don't stop plymouth at boot [Andrei]

# v2.0.0-rc5
## (2017-03-24)

* Fix busybox switch_root when console=null [Andrei]
* Make the initrams framework also parse root=LABEL= params [Florin]
* Fix audit disable dependencies [Theodor]
* Properly implement the ro_rootfs script [Theodor]
* Make rootfs identical to resinhup packages [Andrei]

# v2.0.0-rc4
## (2017-03-17)

* Enable by-partuuid symlinks for our DOS partition scheme also for Poky Jethro and Poky Krogoth based boards [Florin]
* Ship with e2fsprogs-tune2fs [Michal]

# v2.0.0-rc3
## (2017-03-14)

* Fix flasher detection in initramfs scripts [Andrei]
* Fix initramfs-framework build on morty [Andrei]

# v2.0.0-rc2
## (2017-03-14)

* Fix initramfs-framework for non-morty boards [Theodor]
* Fix flasher when it might corrupt the internal device [Andrei]

# v2.0.0-rc1
## (2017-03-10)

* Use stateless flasher partitions [Andrei]
* Refactor persistent logging [Theodor]
* Add support for RDT promote [Andrei]
* Fix image flag files on non uboot boards [Andrei]
* Update supervisor to v4.0.0 [Pablo]
* Change "test -z" with "test -n" in the U-Boot MMC scanning procedure [Florin]
* Implement MMC scanning for U-Boot [Andrei]
* Resin-info should not be present in our production images [Theodor]
* Implement resin-uboot based on v2.0 specification [Andrei]

# v2.0.0-beta13
## (2017-02-27)

* Fix a compile error on krogoth boards [Andrei]

# v2.0.0-beta12
## (2017-02-27)

* Disable audit subsystem [Theodor]
* Run openvpn on flasher too [Andrei]
* Add VARIANT/VARIANT_ID in os-release [Andrei]
* Modify partitions label, define entire resinOS space used to 700MiB and other minor changes [Andrei]
* Update supervisor to v3.0.1 [Pablo]
* Configure an armv7ve repository for the Resin Supervisor [Michal]
* Fix the location where to create the resinhup bundles when using poky morty [Florin]
* Introduce debug tools package group add mkfs.ext4 in resin-image [Andrei]
* Halve the UUID length to 16 bytes [Michal]

# v2.0.0-beta11
## (2017-02-15)

* Fix sectors per track for targets smaller than 512 MB [Andrei]

# v2.0.0-beta10
## (2017-02-13)

* Introduce new host OS versioning scheme [Andrei]
* Add jethro support [Andrei]
* Fix missing quotes when testing for IMGDEPLOYDIR [Florin]

# v2.0-beta.9
## (2017-02-07)

* Use static resolv.conf [Andrei]
* Switch rootfs to ext4 [Andrei]
* Adapt resinhup for poky morty migration [Florin]
* Add support for multiple entries in INTERNAL_DEVICE_KERNEL [Andrei]
* Fix bug with the .docker mountpoint [Theodor]
* Remove the supervisor container in the update script [Pablo]
* Do not remove the supervisor container in every start [Pablo]
* Update supervisor to v3.0.0 [Pablo]

# v2.0-beta.8
## (2017-01-27)

* Add xt_set kernel module for all of our devices [Theodor]
* Make /home/root/.docker writable [Theodor]
* Prevent docker from thrashing the page cache using posix_fadvise [petrosagg]
* Introduce meta-resin-morty for using meta-resin with poky morty [Florin]
* Add resinhup machine independent support in U-Boot [Andrei]
* Remove BTRFS support from the kernel [Michal]
* Backport dropbear atomic hostkey generation patch [Florin]
* Update supervisor to v2.9.0 [Pablo]
* Rewrite prepare-openvpn (style) and make it fail on error [Michal]
* Ensure prepare-openvpn.service starts after var-volatile.mount [Michal]

# v2.0-beta.7
## (2016-12-05)

* Fix supervisor.conf's SUPERVISOR_TAG variable [Florin]

# v2.0-beta.6
## (2016-12-05)

* Deactivate CONFIG_WATCHDOG_NOWAYOUT to make sure we can shutdown [Andrei]

# v2.0-beta.5
## (2016-11-30)

* Add inode tuning (1 inode for 8192 bytes ) in mkfs.ext4 for the resin-data partition [Praneeth]
* Fix missing [Manager] section for systemd watchdog setting [Florin]
* Add missing dependency for the resin-supervisor.service [Theodor]
* Specify the supervisor tag with a local variable [Theodor]
* Update supervisor to v2.8.3 [Pablo]
* Activate kernel configs for supporting iptables REJECT, MASQUERADE targets [Florin]
* systemd: enable watchdog at 10 seconds [Florin]
* Allow resin-init-flasher to also flash both MLO and regular u-boot at the same time [Florin]
* Fix page size detection in go for arm64 boards [Andrei]

# v2.0-beta.4
## (2016-11-09)

* Update supervisor to v2.8.2 [Pablo]

# v2.0-beta.3
## (2016-11-04)

* Generate SUPERVISOR_REPOSITORY dynamically so no need to define it in `resin-<board>` anymore [Andrei]
* Fix container name conflict when creating a docker container [petrosagg]
* Don't compress docker binary anymore with UPX [Andrei]
* Fix /var/lib/docker corruption after power cut [petrosagg]
* Truncate hostname to 7 characters [Michal]
* Fix aufs patching on non git kernel sources [Andrei]
* Update supervisor to v2.8.1 [Pablo]

# v2.0-beta.2
## (2016-10-25)

* Update supervisor to v2.7.1 [Pablo]
* Move supervisor.conf from /etc to /etc/resin-supervisor [Theodor]
* Update supervisor to v2.7.0 [Pablo]
* Add guide for new board adoption [Florin]
* Update supervisor to v2.6.2 [Pablo]

# v2.0-beta.1
## (2016-10-11)

* Configure kernel with CONFIG_SECCOMP [Andrei]
* Update kernel-module-headers to v0.0.7 [Lorenzo]
* Implement persistent logging functionality [Andrei]
* Increase the root filesystem size to 300M [Andrei]
* Bump supervisor to 2.5.2 [Andrei]
* Added a warning when skipping pulling the supervisor [Page]
* Achieve read-only root filesystem [Theodor]
* Implement aufs fetch and unpack functionality in kernel-resin.bbclass [Florin]
* Use aufs as docker storage driver with ext4 as backing filesystem instead of btrfs [Florin]
* Replace connman with NetworkManager [Michal]
* Generate config.json from the build system [Theodor]
* Add usb-modeswitch [Michal]
* Allow hostname to be defined through config.json [Theodor]
* Expose docker socket over TCP on development images [Andrei]
* Integrate and configure avahi [Andrei]
* Start using gzip archives for kernel module headers [Andrei]
* Replace DEBUG_IMAGE with DEVELOPMENT_IMAGE [Theodor]
* Update supervisor to v2.5.0 [Pablo]

# v1.16
## (2016-09-27)

* Update supervisor to v2.3.0 [Pablo]

# v1.15
## (2016-09-24)

* Update supervisor to v2.2.1 [petrosagg]

# v1.14
## (2016-09-23)

* Update supervisor to v2.2.0 [Kostas]

# v1.13
## (2016-09-23)

# v1.12
## (2016-09-21)

* Update supervisor to v2.1.1 [Pablo]
* Add device-type.json file to the boot partitions of our images [Florin]
* Enable kernel modules ip6table_nat, nf_nat_ipv6 and subset of ip_set [Florin]
* Change openvpn to use config file from /run [Florin]
* Change partition type of resin-conf from vfat to ext4 [Theodor]
* Move config.json to resin-boot partition [Theodor]
* Change resin-boot mount point from /boot to /mnt/boot [Theodor]
* Make dropbear host key generation atomic [Michal]
* Change the TUN device used by OpenVPN to resin-vpn to minimize conflict with user applications using tun0 [Praneeth]
* Update supervisor to v2.1.0 [Pablo]
* Use FHS structure in the root of resinhup packages [Andrei]

# v1.11
## (2016-08-31)

* Backport STOPSIGNAL fix for docker [petrosagg]
* Make Docker log to journald [Michal]

# v1.10
## (2016-08-24)

# v1.9
## (2016-08-24)

* Provide custom splash logo for our flasher type [Theodor]
* Update supervisor to v1.14.0 [Pablo]
* Set the default supervisor tag in /etc/supervisor.conf to the bundled supervisor tag. [Page]
* Update firmware: iwlwifi-7265D-10 -> iwlwifi-7265D-13 [Michal]

# v1.8
## (2016-08-02)

* Fix plymouth output to tty1 [Theodor]
* Use FAT16 filesystems as we do for partitions [Andrei]
* Fix boltdb alignment issue for armv5 in docker, fixes docker 1.10.3 on armv5 devices [Lorenzo]
* Include firmware for iwlwifi-8000C-13 - 6th generation Intel NUC [Andrei]
* Disable DHCP server functionality from dnsmasq [Florin]
* Update supervisor to v1.13.0 [Andrei]
* Start dropbearkey.service at boot and don't wait for first connection [Andrei]
* Both remove systemd-serialgetty symlinks and disable systemd-getty-generator for non-debug builds [Florin]
* Disable ntp from connman and rely only on systemd-timesyncd with selected timeservers [Florin]

# v1.7
## (2016-07-14)

* Various meta-resin layer tweaks [Andrei]
* Add support for resinhup when running kernel modules operations [Andrei]
* Update supervisor to 1.12.1 [Pablo]

# v1.6
## (2016-07-06)

# v1.5
## (2016-07-04)

* Update resin supervisor to v1.11.6 [Florin]
* Refactor openvpn dependencies [Florin]

# v1.4
## (2016-06-27)

* Replace STAGING_BUILD by DEBUG_IMAGE and various refactorings [Andrei]
* Update to latest kernel-modules-headers [Florin]

# v1.3
## (2016-06-24)

* Implement mechanism for compressed kernel modules [Andrei]
* Fix connman multiple IP over DHCP [Andrei]
* Have the ability to inject custom docker images for connectable builds [Andrei]
* Integrate resin-provisioner [Andrei]
* Include slug and machine in os-release [Andrei]
* Define and implement resin connectable builds [Andrei]
* Split the registration and uuid generation, of a device, into separate packages [Theodor]
* Sanitize target arch for x86 machines [Florin]
* Ensure kernel build artefacts are present for kernel-modules-headers [Florin]
* Add "set -e" to resin-init-flasher [Florin]
* Add recipe for deploying an archive with kernel modules headers [Florin]
* Have the ability at build time to configure the preloaded docker image in the BTRFS partition [Andrei]

# v1.2
## (2016-06-08)

* Remove board specific bootloader handling from the flasher [Florin]
* Provide script to inject board specific flashing procedures [Theodor]
* Implement and document host OS new versioning scheme [Andrei]
* Set PreferredTechnologies to "wifi,ethernet" [Florin]
* Do not add nameserver routes in the kernel IP routing table [Florin]
* Add support for migration to docker engine 1.10 in resinhup [Andrei]
* Move resin-image sdcard file in the rootfs instead of the boot partition [Florin]
* Add compression mechanism for binaries, using upx [Theodor]
* Switch to docker 1.10.3 [Theodor]
* Remove deprecated mmcroot from flasher init script [Andrei]
* Deploy license.manifest [Andrei]

# v1.1.4
## (2016-04-20)

* Add build information in the target rootfs [Florin]
* Don't bind mount /etc/resolv.conf anymore [Florin]
* Have dnsmasq listen on 127.0.0.2 instead of 127.0.0.1 [Florin]

# v1.1.3
## (2016-04-13)

* Add resin-init-board as a runtime dependency to resin-init-flasher [Florin]

# v1.1.2
## (2016-04-13)

* Execute resin-init-board from the flasher also [Florin]
* Use realpath from coreutils-native for generating SD images [Andrei]
* Add rsync to our image [Theodor]
* Add p2p to NetworkInterfaceBlacklist in connman main.conf file [Florin]
* Add dnsmasq and do changes to connman so dnsmasq is used according to our platform needs [Florin]
* Define "rce" as a provider for the "docker" package [Florin]

# v1.1.1
## (2016-03-03)

* Make resin-supervisor-disk's PV variable not contain the ':' character [Florin]
* Workaround for "docker images" behavior - https://bugzilla.redhat.com/show_bug.cgi?id=1312934 [Florin]
* Have device registration provided by supervisor in resin-image and resin-device-register in resin-image-flasher [Andrei]
* Include crda in resin images [Andrei]
* Add support for hid-multitouch - available as kernel module [Andrei]
* Simplify os-release version and add some resin specific info [Andrei]
* Set IMAGE_ROOTFS_SIZE to zero as default [Florin]
* Update layer with the ability to use jethro [Theodor]

# v1.1.0
## (2016-02-16)

* Migrate repositories to github [Florin]
* Add resinhup package for running hostOS updates [Andrei]
* Export deltaEndpoint as DELTA_ENDPOINT [Andrei]

# v1.0.6
## (2016-02-03)

* Upgrade systemd to version 216 and add volatile-binds dependency [Florin]
* Fix racing issue on edison [Andrei]
* Add support ts7700 [Theodor]
* Remove obsolete pseudo patch. This patch is now in poky [Florin]
* Remove obsolete bash patches. These patches are now in poky [Florin]
* Ensure connman systemd service is enabled on boot [Florin]
* Change OOM Adjust Score of RCE to -900 [Praneeth]
* Change OOM Adjust Score of Connman to -1000 [Praneeth]
* Change OOM Adjust Score of OpenVPN to -1000 [Praneeth]

# v1.0.5
## (2016-01-20)

# v1.0.4

* Add mechanism for user loading custom splash logo. [Theodor]
* Add splash screen for all our images. [Theodor]
* Make connman an optional network manager [Andrei]
* Always restart openvpn service [Andrei]
* Include distribution information file in rootfs [Andrei]
* Mechanism for generating resinhup-tar packages. [Andrei]
* Implement fingerprints for resin-boot and resin-root [Andrei]
* Explicitly configure kernel with config.gz built in support [Andrei]

# v1.0.3
## (2016-01-05)

* Removed the global bblayers.conf.sample and local.conf.sample [Jon]
* Removed the append from the BBMASK declaration in meta-resin-toradex layer.conf [Jon]
* Fix ${S} and ${DEPLOY_DIR_IMAGE} variables for zc702-zynq7 [Jon]
* Make resin-supervisor.service restartable on failures [Jon]
* Fix supervisor preloading [Andrei]

# 2015-10-29 - apalis-imx6 colibri-imx6

* Added apalis-imx6 and colibri-imx6 support [Theodor]

# 2015-09

* Add firmware for Intel Wireless 7265 chipsets [Jon]
* Added support for specifying the supervisor tag to include. [Page]
* Changed flasher to shutdown instead of reboot [Jon]

# 2015-11-02

* Fix DNS issues with openvpn [Andrei]
* Add support for booting from internal device on vab820-quad [Jon]

# 2015-10-28 - beaglebone cubox-i edison nitrogen6x nuc odroid-c1 odroid-ux3 parallella-hdmi-resin raspberrypi raspberrypi2 ts4900 vab820-quad zc702-zynq7

* Update the supervisor.conf supervisor image when updating the supervisor so that switching image/registry can work. [Page]
* Use armv7hf-supervisor for rpi2 [Page]
* Change update-resin-supervisor.timer to run every 24 hours instead of 5 mins [Praneeth]
* Remove any service that might start getty on the production images [Theodor]
* Move to common code the resin-sdcard addition for flasher boards [Jon]
* Fixed supervisor update not running new image due to invalid comment. [Andrei]
* Change git repo used for VIA arm boards [Jon]
* Removed resolved. [Jon]

# 2015-10-08 - beaglebone cubox-i edison nitrogen6x nuc odroid-c1 odroid-ux3 parallella-hdmi-resin raspberrypi raspberrypi2 vab820-quad zc702-zynq7
# 2015-09-29 - ts4900

* Fix supervisor update missing dependencies [Andrei]
* Added ts4900 support [Andrei]

# 2015-09-13

* Add support for C1+ and XU4 ODROID boards [Andrei]
* Remove device registration in resin-image [Andrei]
* Add support for r8188eu [Andrei]
* Add support for Ralink RT5370 [Jon]
* Make openvpn report connected status by creating a file [Praneeth]
* Add support for ZC702 boards [Andrei]
* config.json doesn't change anymore on flasher images [Andrei]
* Add support for VIA VAB820 boards [Jon]
* Fetch resin instance variables from config.json (eg API endpoint) [Theodor]
* We don't load 1-wire driver at boot anymore [Andrei]
* WiFi can now be configured from config.json - at every boot connman configuration will be redone based on config.json [Andrei]
* Bring in support for capemgr on beaglebone black [Andrei]
* Add firmware files for iwlwifi wireless chipsets [Jon]
* Removed unused package management features [Andrei]
* Add support for multiple yocto versions [Andrei]

# 2015-07-26

* Add Intel NUC support - tested on model D34010WYKH [Jon]
* Switched supervisor caching to be package.json version + docker image id. [Page]
* Increased supervisor update poll interval to once per day (and on reboot)
* meta-resin switched to systemd now instead of sysvinit [Theodor]
* Edison unification. [Theodor]
* Moved parallella bitstreams and DTS into the image. [Theodor]
* Added support for edison phone flash tool. [Praneeth]
* Forcefully remove supervisor container to avoid some issues where a normal remove won't work even though the container is stopped [Page]
* Fixed fat config partition not mounting on mac. [Theodor]
* Cache supervisor based upon package.json version. [Theodor]
* Updated edison BSP. [Praneeth]
* Added hummingboard support. [Andrei]
* Some device registration fixes. [Page]
* Switched to fido. [Theodor]
* Beaglebone refactor. [Andrei]

# 2015-05-20

* Stop spawning getty in production builds [Theodor]
* Add iozone to staging build [Theodor]
* Add support for unprotected WiFi Tethering with Connman [Praneeth]
* Add support for Adafruit Touch Screen - Switches to using adafruits fork of fbtft [Praneeth]
* Add support for Parallella [Theodor]

# 2015-05-07

* Fix beaglebone connman not starting [Praneeth]

# 2015-05-05

* Fix the DNS bug occurring because of docker/rce copying resolv.conf before network connectivity. [Praneeth]
* Change Staging API url to api.staging.resin.io from staging.resin.io [Praneeth]

# 2015-04-27

* Fix resin-net-config to honour network.config and ethernet.config as per the changes in resin-image-maker. [Praneeth]
* Add tun to NetworkInterfaceBlacklist of connman. [Praneeth]
* Add --nodnsproxy to connmand startup in both systemd services and init scripts, This disables the internal dns proxy of connman. [Praneeth]
* Wait for docker to terminate before calling unmount in resin-supervisor-disk [Praneeth]

# 2015-04-19

* Allowed concurrent building on the resin-supervisor recipe.
* Fixed first boot connectivity.
* Added a script to balance the btrfs partition on boot and every 24 hours at midnight
