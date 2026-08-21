# Building hostapp extensions

## Overview

This document covers how a hostapp extension that ships with balenaOS is built: the classes in meta-balena, the recipes a new extension needs, and how it reaches a device type's release.

It assumes the runtime contract described in [Hostapp extensions support](host-extensions.md): the labels an extension image carries, how mobynit layers it, and what happens to it across a HUP. Read that first if the terms `io.balena.image.class`, `io.balena.image.override` or kernel override are new.

Two kinds of extension are covered, each with a guide at the end of the document:

* A userspace extension, which adds files to the root filesystem. `balena-tracing-extension` is the in-tree example.
* A kernel override extension, which additionally replaces the running kernel. `balena-ebpf-extension` is the in-tree example.

Extensions built outside a balenaOS release are plain container images and need none of this; they only have to carry the labels described in the runtime document.

The two in-tree extensions are the working reference for everything below. Rather than reproducing their recipes here, this document says what each piece is responsible for and where it lives; the recipes themselves carry comments explaining the decisions that are not obvious from the code.

## Build infrastructure

Extensions that ship with balenaOS are Yocto image recipes. The build infrastructure is split so that a recipe only states what its extension is for, and the classes handle packaging, labelling and, for kernel overrides, the second kernel.

| Class | Inherited by | Role |
| --- | --- | --- |
| `balena-hostapp-extension` | image recipe | Turns an image into an extension: rootfs tarball, labels, OCI import |
| `kernel-extension-image` | image recipe | The above plus the extension kernel, its modules, device trees and initramfs |
| `kernel-extension` | kernel recipe | Brands a kernel recipe as the extension kernel (`virtual/kernel-extension`) |
| `kernel-balena-override` | kernel recipe | Late kernel config fragment merge, with verification |
| `kernel-ebpf` | kernel recipe | Capability class: BTF, BPF LSM and the tracing surface |
| `balena-tracing` | image recipe | Capability class: the userspace tracing payload |

All of them live in `meta-balena-common/classes/`. Capability classes carry the "why" of an extension and nothing else, so the same payload can be attached to more than one device type or recipe without duplication.

## The extension image class

`balena-hostapp-extension.bbclass` is the only class a userspace-only extension needs. It inherits `image`, so the recipe declares its payload through `IMAGE_INSTALL` and nothing else.

The class then:

* Forces a `tar.gz` rootfs with no init manager, no locales and no initramfs. An extension is a rootfs tarball, not a bootable image.
* Removes the paths in `HOSTAPP_EXTENSION_REMOVE_PATHS` from the assembled rootfs, `/etc`, `/run` and `/var` by default. An overlay contributes its own content only; state directories come from the hostapp underneath it.
* Installs `kernel-override-hooks`, which lays down `/hooks/{create,start,deactivate}`. The hooks self-detect kernel content at runtime and no-op for a userspace extension.

### Hooks take their helpers from the host

The hooks run as host processes, not inside the extension: the runtime `exec`s them with a scrubbed environment, so their root is the mobynit overlay and their `PATH` resolves against the running system. They therefore source `/usr/libexec/os-helpers-*` by absolute path, and `kernel-override-hooks` deliberately carries no `RDEPENDS` on those packages.

That is a correctness decision, not only a packaging one. Two things consume what the hooks produce, and the running OS owns both: mobynit decides whether to mount an extension by comparing `sha256` of the kernel image it ships against the activated id, and the rollback path reads back the bootenv keys the `start` hook writes. A helper carried inside the extension would freeze both at the extension's build, so an extension mounted under a newer OS, which happens after a rollback or when a superseded release's extension is still on disk, would arm an id the running mobynit refuses.

It also keeps the guard in `extension_kernel_override_prelude` meaningful. That guard fails the activation when the id computed on the device disagrees with the `io.balena.image.kernel-abi-id` label, which only detects anything while the two come from different places: the scheme from the OS, the claim from the build.

The consequence to design for: **the os-helpers function set is a contract between the OS build and the extension build.** An extension whose hooks call a helper function a later OS renames fails its activation with exit 127, which surfaces as an aborted release. In-tree extensions build from the same meta-balena as the hostapp they ship with, so this cannot happen within a release.

An extension must not install anything under `/usr/libexec/os-helpers-*`. Setting `HOSTAPP_EXTENSION_LABEL_OVERRIDE` makes every path the image ships shadow the hostapp's for the whole running system, so shipping those would replace the OS's own helpers for every host process that sources them, `rollback-health` and `extension-rollback` included.
* Imports the tarball with `docker import --change`, adding the labels below, and saves the result as a `.docker` archive in the deploy directory.

Labels are set from variables, so a recipe overrides only what it needs:

| Variable | Label | Default |
| --- | --- | --- |
| `HOSTAPP_EXTENSION_LABEL_STORE` | `io.balena.image.store` | `data` |
| `HOSTAPP_EXTENSION_LABEL_CLASS` | `io.balena.image.class` | `overlay` |
| `HOSTAPP_EXTENSION_LABEL_REQUIRES_REBOOT` | `io.balena.update.requires-reboot` | `1` |
| `HOSTAPP_EXTENSION_LABEL_OVERRIDE` | `io.balena.image.override` | unset, meaning extend-only |
| not configurable | `io.balena.image.os-version` | the version of the OS being built |

Two escape hatches cover anything else the image needs: `HOSTAPP_EXTENSION_LABELS` for extra `LABEL` changes and `HOSTAPP_EXTENSION_CHANGES` for other `docker import` changes such as `VOLUME` or `ENV`.

The stripped paths are a variable too:

| Variable | Meaning | Default |
| --- | --- | --- |
| `HOSTAPP_EXTENSION_REMOVE_PATHS` | rootfs-relative paths deleted before import | `etc run var` |

Contribute to it with `:append`, as the kernel extension image class does for `bin` and `sbin`. Entries are matched literally, so an entry that escapes the rootfs (`/`, `.`, `..`, or anything containing `..`) fails the build rather than deleting outside the image.

Because the OS version label is the exact version being built, an in-tree extension image is retained only for that release. See [image retention across HUPs](host-extensions.md#image-retention-across-hups) for what that means on a device.

## Automatic kernel-override detection

Nothing in a recipe declares "this is a kernel override". The class decides from the assembled rootfs, which must contain both:

* a `Module.symvers` under `/lib/modules/<release>/` (or `/usr/lib/modules/<release>/`), and
* a kernel image under `/boot/`.

When both are present, the import adds `io.balena.image.kernel-version`, `io.balena.image.kernel-abi-id` (the sha256 of the kernel image itself) and declares `/boot` as a volume. When neither is present the image is imported with the common labels only.

Anything in between is a build failure rather than a silently degraded image: a kernel image without `Module.symvers`, a `Module.symvers` without a kernel image, more than one `Module.symvers` (the ABI claim would be ambiguous), or an empty or symlinked kernel image that cannot identify a build.

`Module.symvers` is normally not in any runtime package, so the class copies it in from the matching kernel build in the deploy directory during image preprocessing, matching by the kernel version recorded in the deployed `.config`.

## Kernel override build support

A kernel override extension needs a second kernel: same device, different configuration, delivered as an overlay rather than in the rootfs. Three classes cover it.

`kernel-extension.bbclass` is inherited by the kernel recipe and brands it as that second kernel. It renames the kernel package and provides `virtual/kernel-extension` instead of `virtual/kernel`, which also moves its artifacts into their own deploy subdirectory, and it bundles the initramfs in a single compile pass instead of the stock `do_bundle_initramfs`, which would build the whole kernel a second time. The single-pass bundling is safe for an extension kernel only, which consumes just the initramfs-bundled image.

The class must be inherited below the device recipe's `require` chain: `kernel.bbclass` adds `virtual/kernel` to `PROVIDES` unconditionally, and only a plain assignment evaluated afterwards drops it.

`kernel-balena-override.bbclass` merges kernel config fragments late, after `do_kernel_resin_checkconfig` and before `do_compile`, so an extension fragment wins over the `BALENA_CONFIGS` processing that the base kernel shares. Fragments are listed explicitly in `KERNEL_BALENA_OVERRIDE_FRAGMENTS` and resolved on `FILESPATH`; `SRC_URI` is deliberately not used, because that merges too early. A verification task then asserts that every positively-set symbol from every fragment survived the merge, and re-asserts the secure boot posture when signing is enabled. Fragment contents are folded into the task hashes, so editing a fragment re-runs the merge and the check.

Always contribute fragments to `KERNEL_BALENA_OVERRIDE_FRAGMENTS` with `:append`. A plain assignment from one class silently drops another's fragment, and the loss is invisible: the verification task derives its required symbols from the same variable it merges from, so a dropped fragment is neither merged nor missed.

`kernel-extension-image.bbclass` is the image side. It inherits `balena-hostapp-extension` and installs the extension kernel's modules, the initramfs-bundled kernel image, and the device trees when the machine defines any. It also sets the override priority to 100, disables `USE_DEPMOD` (a kirkstone-era limitation with multiple compiled kernels) and removes the `/bin` and `/sbin` compatibility symlinks, which would otherwise shadow the hostapp's.

## Independent kernel version pinning

The extension kernel is a separate recipe, so it carries its own source revision. That is the point of the split: an extension can move to a newer kernel without moving the machine kernel that every device of that type boots.

In meta-balena-raspberrypi the versioned extension recipe requires the base kernel's version include and then restates the version and source revisions. Two details make that work: plain assignments rather than defaults, so the values beat the ones the `require` brought in; and an `SRC_URI` restated with `nobranch=1` in the extension include, because pinning by revision alone needs it.

Because the two kernels can differ, out-of-tree modules destined for a kernel override extension have to be built against that extension's `Module.symvers`, which is why the image ships it.

## Wiring an extension into a device type build

The build pipeline reads a Docker Compose composition. The base composition in `layers/meta-balena/hostapp.yml` declares the hostapp service; a device repo adds its extensions in `${MACHINE}.hostapp.yml`, and the two are deep-merged with the device overlay winning. See `raspberrypi4-64.hostapp.yml` in balena-raspberrypi for a composition carrying both in-tree extensions, and the hostapp composition spec in balena-yocto-scripts for the full contract.

An extension service declares:

* `image: __BUILD_OUTPUT__` and an `x-build.recipe` naming the bitbake image target. The pipeline builds that target per machine and matches the resulting `${recipe}-${MACHINE}.docker` archive back to the service when it substitutes the placeholder.
* A `labels` block, which `balena deploy` applies to the image. It overlaps with what the recipe already stamps at import time, and keeping both in sync is deliberate: the composition is what a reader of the device repo sees, and it is the only place where workflow-time substitutions can happen.
* Optionally a `profiles` entry, marking the extension as selectively activated. The build pipeline passes profiles through untouched; the supervisor decides at deploy time which ones apply to a device.

A device type opts out of a base-composition service by nulling it.

To build one extension on its own, name the recipe as the bitbake target:

```console
$ balena-yocto-scripts/build/balena-build.sh -d raspberrypi4-64 -i balena-ebpf-extension
```

The artifact lands in `build/tmp/deploy/images/${MACHINE}/${recipe}-${MACHINE}.docker`, next to the rootfs tarball it was imported from.

## Guide: adding a userspace extension

This is the shape used by `balena-tracing-extension`: a payload of ordinary packages, no kernel involved. Work through it in order.

**1. Package the payload.** Everything the extension installs must be a normal Yocto package, and it must build for the target. Cross-compilation gaps are the usual first obstacle, and the fix belongs in a bbappend next to the payload, not in the extension recipe. `meta-balena-common/recipes-kernel/perf/perf.bbappend` is the in-tree example: it exists only because the tracing extension ships `perf`.

**2. Put the payload in a capability class** if it is worth reusing or worth naming; otherwise set `IMAGE_INSTALL` in the recipe directly. `balena-tracing.bbclass` is nothing more than an `IMAGE_INSTALL:append` with the tracing tools. Use `:append` there, so inherit order cannot clobber an `IMAGE_INSTALL` set by the recipe.

**3. Write the image recipe** under `recipes-core/images/`. It needs a description, a license, and an `inherit` of `balena-hostapp-extension` plus whatever capability class carries the payload. `balena-tracing-extension.bb` is four lines of substance.

**4. Decide the two labels that change behaviour.**

* `HOSTAPP_EXTENSION_LABEL_OVERRIDE`: leave it unset for an extension that only adds files. Set it to a priority when the extension has to shadow hostapp content, and pick the number relative to the extensions already deployed on that device type. The tracing extension sits at 200, behind the kernel extension at 100.
* `HOSTAPP_EXTENSION_LABEL_REQUIRES_REBOOT`: the default is `1`, which makes the supervisor reboot the host so the extension is layered straight away. Set it to `0` for a payload that can wait for whenever the device next boots.

Most extensions need nothing beyond those two. Reach for `HOSTAPP_EXTENSION_REMOVE_PATHS` only when the payload does not fit the default assumption: append a path the extension must not carry into the overlay, or drop `etc` when the extension genuinely has to ship configuration, which also means setting an override priority so the shadowing is deliberate.

**5. Add the service to `${MACHINE}.hostapp.yml`** as described in [Wiring an extension into a device type build](#wiring-an-extension-into-a-device-type-build).

**6. Build and check the result.** Build the recipe on its own, load the `.docker` archive and inspect its labels:

```console
$ balena-yocto-scripts/build/balena-build.sh -d raspberrypi4-64 -i balena-tracing-extension
$ docker load < build/tmp/deploy/images/raspberrypi4-64/balena-tracing-extension-raspberrypi4-64.docker
$ docker inspect --format '{{json .Config.Labels}}' <loaded image> | jq
```

Expect the overlay class, the data store, the OS version, and the override priority if you set one. There must be no `kernel-version` or `kernel-abi-id` label: their presence means kernel content leaked into the rootfs.

## Guide: adding a kernel override extension

This is the shape used by `balena-ebpf-extension`: a kernel built with a different configuration, plus the userspace that needs it. It builds on the previous guide, with the kernel work in front.

**1. Write the kernel config fragment.** Put it where the capability class can find it; `meta-balena-common/recipes-kernel/linux/files/` holds `ebpf.cfg`, the fragment shared across device types. State symbols explicitly even when the defconfig already has them: the verification task turns every positively-set symbol into a required one, which is what makes the fragment robust against a base config change.

**2. Write the capability class.** It is inherited by the kernel recipe and holds everything the capability needs from the kernel build. `kernel-ebpf.bbclass` shows the pattern and is worth reading in full before writing a new one. It inherits `kernel-balena-override`, appends its fragment to `KERNEL_BALENA_OVERRIDE_FRAGMENTS`, and puts the fragment's directory on `FILESEXTRAPATHS`.

Three of its decisions generalise:

* Restrict `COMPATIBLE_HOST` when the capability does not work on an architecture, rather than shipping a kernel that builds cleanly and fails at runtime. BPF LSM on arm32 is the case that forced this.
* Append to `FILESEXTRAPATHS` rather than prepending, so a device fragment of the same name still wins.
* Pull in whatever the config symbols need at build time. `CONFIG_DEBUG_INFO_BTF` is gated on a recent pahole, so the class depends on `pahole-native`; without it the symbol is silently dropped and the verification task is what catches the result.

**3. Give the BSP an extension kernel recipe.** This lives in the device layer, next to the machine kernel: see `linux-raspberrypi-extension.inc` and `linux-raspberrypi-extension_6.12.bb` in meta-balena-raspberrypi. Splitting it in two keeps the version-independent parts out of the per-version recipe.

The include restates `SRC_URI` so the kernel can be pinned by revision, requires the machine kernel's shared include, and inherits `kernel-extension` and `kernel-balena-override` below that require. The versioned recipe adds the version and revision pins and inherits the capability class.

Two things to keep in mind. The extension kernel does not inherit the machine kernel's bbappends, so local patches carried there do not apply to it; anything the extension needs must be in its own require chain. And the pins are what make the extension kernel independent, as described in [Independent kernel version pinning](#independent-kernel-version-pinning).

**4. Write the image recipe.** Same as a userspace extension, except it inherits `kernel-extension-image` for the kernel payload and appends the userspace the capability exists to deliver. `balena-ebpf-extension.bb` adds `bpftool` and `libbpf` on top of the kernel. Use `:append` for `IMAGE_INSTALL` so the class's own assignment cannot clobber it.

**5. Make the userspace payload available for the target.** Upstream layers sometimes restrict a recipe more than the extension needs; `bpftool` is limited to x86-64 by meta-oe, so `balena-os.inc` widens its `COMPATIBLE_HOST` to cover aarch64.

**6. Add the service to `${MACHINE}.hostapp.yml`** with an override priority matching the class default of 100, and `io.balena.update.requires-reboot` set. A kernel only takes effect after a reboot, so this one is not optional.

**7. Build and check the result.** The rootfs tarball is the input the class inspects, so it is the quickest place to see whether the kernel image and the single `Module.symvers` both made it in:

```console
$ balena-yocto-scripts/build/balena-build.sh -d raspberrypi4-64 -i balena-ebpf-extension
$ cd build/tmp/deploy/images/raspberrypi4-64
$ tar -tzf balena-ebpf-extension-raspberrypi4-64.tar.gz | grep -E 'boot/|Module.symvers'
$ docker load < balena-ebpf-extension-raspberrypi4-64.docker
$ docker inspect --format '{{json .Config.Labels}}' <loaded image> | jq
```

The image must carry `io.balena.image.kernel-version` and `io.balena.image.kernel-abi-id`, and declare `/boot` as a volume. If the build failed instead, the message names which half of the pair was missing.

A kernel override cannot be validated from the build alone. On a device, confirm that `/mnt/data/boot-by-abi/<abi-id>` was created after the extension is installed, that `kernel_override_abi` is set in the boot environment, and that `uname -r` after the reboot reports the extension's kernel. A kernel that fails to boot falls back to the stock one, so a silent fallback looks like an extension that did nothing. See [kernel override extensions](host-extensions.md#kernel-override-extensions) for the activation path in full.
