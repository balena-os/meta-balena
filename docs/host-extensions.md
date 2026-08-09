# Hostapp extensions support

## Overview

BalenaOS supports layering the root filesystem with content from hostapp extension containers. In essence, hostapp extensions are container images flagged with the `io.balena.image.class=overlay` label that are overlayed during the early boot process.

Hostapp extension containers are meant to extend or modify the root filesystem in a managed way, and to house content that cannot be placed on an application container.

When deciding whether to use a hostapp extension for your content, first consider whether there is any reason why it could not be added to a standard application container.

This document describes what an extension is and how balenaOS treats one: the labels an image carries, how they are layered at boot, and how the OS validates a kernel it did not ship. It stays at that level deliberately.

Two documents hold the detail. `balena-extension-runtime`'s [extension lifecycle](https://github.com/balena-os/balena-extension-runtime/blob/master/docs/extension-lifecycle.md) owns the on-device contract: the container lifecycle, volume fabrication, activation and the verdict rules. [Building hostapp extensions](host-extensions-development.md) covers how the extensions that ship with balenaOS are built.

### The balena-bootloader is a requirement

A device type must ship the balena-bootloader to support kernel overrides in hostapp extensions.

## How it works

Mobynit runs as PID 1 and discovers container overlay filesystems by reading overlay2 metadata directly, without relying on Docker packages. During boot, it:

1. Mounts the hostapp container (identified via a `current` symlink)
2. Layers OS block containers marked with `io.balena.image.class=overlay`
3. Relocates existing mounts into the new root filesystem
4. Executes `pivot_root` to switch the system root
5. Execs `/sbin/init`

The composed root is an overlay of container layers with no upperdir, so it is read-only. Layering extensions adds lowerdirs and does not change that.

## Building a hostapp extension container

The last stage of a hostapp extension container is shown next:

```dockerfile
FROM scratch

LABEL io.balena.image.class=overlay

COPY --from=builder /hostext /
```

The example Dockerfile above starts with an empty container, then adds the `io.balena.image.class=overlay` label so that BalenaOS can identify it and overlay it at boot, and finally the desired content is copied from a space holder directory to the root of this container.

By default, extensions are mounted to the right of the hostapp in the overlayfs lowerdir stack, meaning they can only contribute new files: they cannot replace existing hostapp content.

The labels are the whole contract; how the image is produced is not constrained. Extensions that ship as part of a balenaOS release are built from Yocto image recipes instead of a Dockerfile, and the classes described in [Building hostapp extensions](host-extensions-development.md) emit the same labels at import time.

## Mount ordering

Extensions can define a mount order using the `io.balena.image.override=N` label, where N is a numeric priority. Extensions with this label are mounted to the left of the hostapp in the overlayfs lowerdir stack, enabling them to replace existing hostapp files. Lower N values have higher overlayfs precedence, so `override=0` is the highest-precedence override, not "no override". Equal priorities sort by container name for deterministic behavior.

Shadowing is opt-in through the presence of the label, not its value. Omit the label entirely for an extend-only extension that only contributes new files; there is no numeric value that means "extend only".

```dockerfile
FROM scratch

LABEL io.balena.image.class=overlay
LABEL io.balena.image.override=10

COPY --from=builder /hostext /
```

In overlayfs terminology, `lowerdir=A:B:C` means A has the highest lookup priority. The resulting lowerdir is: `lowerdir=<extensions with override sorted by N>:<hostapp>:<extensions without override>`.

Care should be taken not to shadow root filesystem content which is essential for BalenaOS to function.

Of the extensions built in-tree, only the kernel extension takes a priority, at 100, leaving room on either side for overlays added later. The tracing extension declares none, so it is extend-only.

## Number of layered extensions

The total is capped by the kernel's page size, typically 4KiB or 16KiB. Every extension adds its overlay path to a single mount option string, so the limit depends on the page size and on how long those paths are.

When the set does not fit, mobynit drops extensions rather than refusing to boot, and logs what it dropped. Additive extensions go first, then the lowest-precedence overrides.

## Kernel ABI compatibility

Extensions that ship kernel modules or BPF-sensitive content should declare the kernel they were built against. Mobynit uses these labels at boot to skip extensions whose kernel does not match the running one, preventing module load failures and mitigating ABI drift across HUPs.

* `io.balena.image.kernel-version=M.m.p`: coarse userspace-visible kernel version (e.g. `6.12.61`). Checked against the running kernel's stripped `uname -r`. Missing label is fail-open (extension is mounted).
* `io.balena.image.kernel-abi-id=<sha256>`: precise kernel build fingerprint. For kernel extensions the build sets it to the sha256 of the extension's kernel image.

```dockerfile
FROM scratch

LABEL io.balena.image.class=overlay
LABEL io.balena.image.kernel-version=6.12.61
LABEL io.balena.image.kernel-abi-id=<sha256 of the kernel image>

COPY --from=builder /lib/modules /lib/modules
```

Recipes built with `balena-hostapp-extension.bbclass` do not hand-write these two labels: the class derives them from the assembled rootfs, as described in [automatic kernel-override detection](host-extensions-development.md#automatic-kernel-override-detection).

Mount-time filtering keeps an incompatible extension out of the root filesystem; it does not remove it. Removal belongs to the extension manager, described in [Managing hostapp extensions](#managing-hostapp-extensions).

## Kernel override extensions

A hostapp extension can replace the running kernel rather than only adding files. It carries a kernel image under `/boot` plus the matching modules and their `Module.symvers` under `/usr/lib/modules/<release>/`. The kernel image is booted directly; the modules are layered in like any other extension content.

It declares `io.balena.image.kernel-abi-id` and `io.balena.image.kernel-version` as above, and `io.balena.update.requires-reboot=1`.

Publishing the kernel and arming it are separate steps, with a reboot between the arm and its effect:

* The runtime publishes the kernel under `/mnt/data/boot-by-abi/<abi>` during `start`, then arms it by writing `kernel_override_abi`. Arming comes last, and it opens the validation window.
* The initramfs `kexec` script boots the armed ABI when its link resolves and a deployed extension still claims it. It stamps `balena_kernel_abi=<abi>` on the command line, which is how the rest of the system knows which kernel is running.

Anything that does not check out falls back to the stock kernel shipped with the OS: a missing kernel, no extension claiming the ABI, a failed load, or a pending purge.

What the runtime checks before it arms, and how it distinguishes an extension it refuses from a machine condition it retries, is in the [extension lifecycle](https://github.com/balena-os/balena-extension-runtime/blob/master/docs/extension-lifecycle.md) document.

### Validating a kernel override

An armed override is on trial until a boot ratifies it. The state lives in the boot environment, as `kernel_override_abi`, `kernel_override_abi_committed_<slot>`, `kernel_override_abi_rejected` and `kernel_override_trial`, alongside the rejection record at `/mnt/state/override-rejected`.

A boot whose armed value matches the running slot's committed value is an ordinary boot. Anything else is a pending verdict, and which of the OS's two paths reaches it depends on whether a host OS update is in flight:

* Inside a HUP, `rollback-health` owns it, delegating to `balena-extension-manager hup commit` or `hup reject` so the kernel and the rootfs move together.
* Outside one, `extension-rollback.service` owns it, running `balena-extension-manager validate` on every boot. It runs unconditionally because an override can be armed with no update in progress, and stands aside while a HUP is in flight.

The rules each verdict follows are the manager's; see the [extension lifecycle](https://github.com/balena-os/balena-extension-runtime/blob/master/docs/extension-lifecycle.md) document.

A kernel that never reaches userspace is the initramfs's problem, and the only part of validation that is not the manager's. Stage 2 counts each boot of an armed override the slot has not committed and adds `panic=30`, so a kernel that dies before userspace resets the board rather than hanging. After three such boots it stops offering the armed kernel and falls back, and the manager turns the spent count into a rejection.

The count is boots without a verdict, not boots that failed, so an operator reboot or a power cut also spends one. That bounds a crash loop as well as a dead kernel. It does not reach a kernel that boots and then sits there degraded without rebooting, which still needs manual intervention.

### Withdrawing a kernel override

Withdrawal is a container removal and nothing else. Nothing disarms the override inline: the next boot reconciles what the extension published, and `extension-rollback.service` does that before it reads any state its own validation depends on.

## Image retention across HUPs

Extension images declare which OS versions they are valid for via the `io.balena.image.os-version` label. At the post-HUP commit (the rollback-health boundary), the engine-side cleanup runs `balena-extension-manager cleanup --stale-os`, which removes extension images whose label no longer satisfies the new OS version, and preserves the ones that do.

* `io.balena.image.os-version=<pattern>[,<pattern>...]`: a comma-separated list of globs matched against `/etc/os-release` `VERSION_ID`. Any match retains the image; a missing or empty label always retains.

```dockerfile
FROM scratch

LABEL io.balena.image.class=overlay
LABEL io.balena.image.os-version=2.119.*

COPY --from=builder /hostext /
```

The pattern grammar, and what `--stale-os` treats as stale, are in the [extension lifecycle](https://github.com/balena-os/balena-extension-runtime/blob/master/docs/extension-lifecycle.md) document. In-tree extensions take the exact-version end of the scale: the build stamps the version of the OS being built, so the image is retained only for that release.

## Extensions that require a reboot

* `io.balena.update.requires-reboot=1`: records that the extension needs a host reboot to take effect. The label carries no behaviour of its own today. Mobynit composes the root filesystem once, at boot, so the device agent treats every overlay as reboot-activated and schedules the reboot whether or not the label is present. It is reserved in the extension contract for a future runtime-activated class, and remains useful as a declaration of intent; extensions built in-tree set it to `1`.

## Managing hostapp extensions

Extensions are meant to be managed by the supervisor or as part of a hostOS update. Manually installing, removing or updating hostapp extensions is neither advised nor supported.

On-host lifecycle is handled by the `balena-extension-runtime` recipe, which ships the `extension` OCI runtime and the `balena-extension-manager` lifecycle helper. The manager's verbs and when each runs are listed in that repository's README.

meta-balena owns where they are called from:

* `hostapp-extensions-cleanup.service`, a oneshot ordered after `balena.service` and before the supervisor, runs `cleanup` on every boot.
* `extension-rollback.service` runs `validate` on every boot.
* The `85-fwd_commit_os-blocks-extensions` forward-commit hook runs `cleanup --stale-os` once a host OS update commits.
* `rollback-health` runs `hup commit` or `hup reject` inside an update window.

The first two are unordered with respect to each other and stay that way, since both key on the same fact: that nothing claims the object.

## Disabling hostapp extension overlays

An incorrect hostapp extension can leave your system in a non-working state. Balena advises against deploying custom made hostapp extensions and recommends to either use the hostapp extensions included as part of BalenaOS releases, or let the supervisor manage the installation, update and removal of production ready hostapp extensions.

The overlaying of hostapp extensions can be disabled by specifying either of the following kernel command line arguments:

* `mobynit.no_overlays`
* `emergency`
