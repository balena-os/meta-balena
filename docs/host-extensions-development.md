# Building hostapp extensions

## Overview

This document covers how a hostapp extension that ships with balenaOS is built: the classes in meta-balena and how an extension reaches a device type's release.

It assumes the runtime contract described in [Hostapp extensions support](host-extensions.md): the labels an extension image carries, how mobynit layers it, and what happens to it across a HUP. Read that first if the terms `io.balena.image.class`, `io.balena.image.override` or kernel override are new.

Two kinds of extension have examples in-tree:

* A userspace extension, which adds files to the root filesystem: `balena-tracing-extension`.
* A kernel override extension, which additionally replaces the running kernel: `balena-ebpf-extension`.

Extensions built outside a balenaOS release are plain container images and need none of this. They only have to carry the labels described in the runtime document.

## Build infrastructure

Extensions that ship with balenaOS are Yocto image recipes. The build infrastructure is split so that a recipe only states what its extension is for, and the classes handle packaging, labelling and, for kernel overrides, the second kernel.

| Class | Inherited by | Role |
| --- | --- | --- |
| `balena-hostapp-extension` | image recipe | Turns an image into an extension: rootfs tarball, labels, OCI import |
| `kernel-extension-image` | image recipe | The above plus the extension kernel, its modules, device trees and initramfs |
| `kernel-extension` | kernel recipe | Brands a kernel recipe as the extension kernel (`virtual/kernel-extension`) |
| `kernel-balena-override` | kernel recipe | Late kernel config fragment merge, with verification |
| `kernel-ebpf` | kernel recipe | BTF, BPF LSM and the tracing surface |
| `balena-tracing` | image recipe | The userspace tracing payload |

All of them live in `meta-balena-common/classes/`. Capability classes carry the "why" of an extension and nothing else, so the same payload can be attached to more than one device type or recipe without duplication.

## The extension image class

`balena-hostapp-extension.bbclass` is the only class a userspace-only extension needs. It inherits `image`, so the recipe declares its payload through `IMAGE_INSTALL` and nothing else.

The class then:

* Forces a `tar.gz` rootfs with no init manager, no locales and no initramfs. An extension is a rootfs tarball, not a bootable image.
* Removes `HOSTAPP_EXTENSION_REMOVE_PATHS` (`etc run var` by default) from the assembled rootfs. An overlay contributes its own content only; state directories come from the hostapp underneath it.
* Installs `kernel-override-hooks`, which lays down `/hooks/{create,start}`. The hooks self-detect kernel content at runtime and no-op for a userspace extension.
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

Contribute to `HOSTAPP_EXTENSION_REMOVE_PATHS` with `:append`, as the kernel extension image class does for `bin` and `sbin`. Entries are matched literally, so an entry that escapes the rootfs (`/`, `.`, `..`, or anything containing `..`) fails the build rather than deleting outside the image.

Because the OS version label is the exact version being built, an in-tree extension image is retained only for that release. See [image retention across HUPs](host-extensions.md#image-retention-across-hups) for what that means on a device.

An extension must not ship `/usr/libexec/os-helpers-*`. Those files are sourced by every host process that uses them, `rollback-health` and `extension-rollback` included.

## Kernel override build support

A kernel override extension needs a second kernel: same device, different configuration, delivered as an overlay rather than in the rootfs. Three classes cover it.

`kernel-extension.bbclass` is inherited by the kernel recipe and brands it as that second kernel. It:

* Renames the kernel package and provides `virtual/kernel-extension` instead of `virtual/kernel`, which also moves its artifacts into their own deploy subdirectory.
* Bundles the initramfs in a single compile pass instead of the stock `do_bundle_initramfs`, which would build the whole kernel a second time. Single-pass bundling is safe for an extension kernel only, which consumes just the initramfs-bundled image.

The class must be inherited below the device recipe's `require` chain: `kernel.bbclass` adds `virtual/kernel` to `PROVIDES` unconditionally, and only a plain assignment evaluated afterwards drops it.

`kernel-balena-override.bbclass` merges kernel config fragments late, after `do_kernel_resin_checkconfig` and before `do_compile`, so an extension fragment wins over the `BALENA_CONFIGS` processing that the base kernel shares. Fragments are listed explicitly in `KERNEL_BALENA_OVERRIDE_FRAGMENTS` and resolved on `FILESPATH`; `SRC_URI` is deliberately not used, because that merges too early. A verification task then asserts that every positively-set symbol from every fragment survived the merge, and re-asserts the secure boot posture when signing is enabled. Fragment contents are folded into the task hashes, so editing a fragment re-runs the merge and the check.

Always contribute fragments to `KERNEL_BALENA_OVERRIDE_FRAGMENTS` with `:append`. A plain assignment from one class silently drops another's fragment, and the loss is invisible: the verification task derives its required symbols from the same variable it merges from, so a dropped fragment is neither merged nor missed.

`kernel-extension-image.bbclass` is the image side. It inherits `balena-hostapp-extension` and:

* Installs the extension kernel's modules, the initramfs-bundled kernel image, and the device trees when the machine defines any.
* Sets the override priority to 100.
* Disables `USE_DEPMOD`, a kirkstone-era limitation with multiple compiled kernels.
* Removes the `/bin` and `/sbin` compatibility symlinks, which would otherwise shadow the hostapp's.

## Automatic kernel-override detection

Nothing in a recipe declares "this is a kernel override". The class decides from the assembled rootfs, which must contain both:

* a `Module.symvers` under `/lib/modules/<release>/` (or `/usr/lib/modules/<release>/`), and
* a kernel image under `/boot/`.

When both are present, the import adds `io.balena.image.kernel-version`, `io.balena.image.kernel-abi-id` (the sha256 of the kernel image itself) and declares `/boot` as a volume. When neither is present the image is imported with the common labels only.

Anything in between is a build failure rather than a silently degraded image: a kernel image without `Module.symvers`, a `Module.symvers` without a kernel image, more than one `Module.symvers` (the ABI claim would be ambiguous), or an empty or symlinked kernel image that cannot identify a build.

`Module.symvers` is normally not in any runtime package, so the class copies it in from the matching kernel build in the deploy directory during image preprocessing, matching by the kernel version recorded in the deployed `.config`.

The extension kernel is a separate recipe with its own source revision, so the two kernels can differ: out-of-tree modules destined for a kernel override extension have to be built against the extension's `Module.symvers`, not the hostapp kernel's.

## Wiring an extension into a device type build

The build pipeline reads a Docker Compose composition. The base composition in `layers/meta-balena/hostapp.yml` declares the hostapp service; a device repo adds its extensions in `${MACHINE}.hostapp.yml`, and the two are deep-merged with the device overlay winning.

An extension service declares:

* `image: __BUILD_OUTPUT__` and an `x-build.recipe` naming the bitbake image target.
* A `labels` block, which `balena deploy` applies to the image.
* A `profiles` entry, marking the extension as selectively activated.

A device type opts out of a base-composition service by nulling it.
