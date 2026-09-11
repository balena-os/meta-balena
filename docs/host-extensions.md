# Hostapp extensions support

## Overview

BalenaOS supports layering the root filesystem with content from hostapp extension containers. In essence, hostapp extensions are container images flagged with the `io.balena.image.class=overlay` label that are overlayed during the early boot process.

Hostapp extension containers are meant to extend or modify the root filesystem in a managed way, and to house content that cannot be placed on an application container.

When deciding whether to use a hostapp extension for your content, first consider whether there is any reason why it could not be added to a standard application container.

This document describes the runtime contract: the labels an extension image carries and what the OS does with them. For how the extensions that ship with balenaOS are built, including step by step guides for both kinds, see [Building hostapp extensions](host-extensions-development.md).

## How it works

Mobynit runs as PID 1 and discovers container overlay filesystems by reading overlay2 metadata directly, without relying on Docker packages. During boot, it:

1. Mounts the hostapp container (identified via a `current` symlink)
2. Layers OS block containers marked with `io.balena.image.class=overlay`
3. Relocates existing mounts into the new root filesystem
4. Executes `pivot_root` to switch the system root
5. Execs `/sbin/init`

The rootfs is mounted as overlayfs lowerdirs and is intrinsically read-only.

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

The extensions built in-tree pick their priorities from the same scale: the kernel extension sits at 100 and the tracing extension at 200, so the kernel extension shadows the tracing one, and both leave room on either side for overlays added later.

## Number of layered extensions

The number of total extensions is capped by the page size (typically 4KiB or 16KiB). Each extension adds its overlay path to a string that is passed into the kernel, so the exact number depends on the page size and the length of those paths.

When the layered set exceeds the page size, mobynit still boots dropping extensions to fit the page length with a log. Override (left) extensions are packed first, highest precedence first, so additive (right) extensions are dropped before any override, and among overrides the lowest-precedence (highest `N`) ones are dropped first.

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

Mount-time filtering keeps an incompatible extension out of the root filesystem; it does not remove it.

Reaping is done by the extension manager:

* `balena-extension-manager cleanup` runs on every boot. It drops the containers the engine calls garbage, whose runtime create failed or that it reports as dead, and the fabricated `ext_*` volumes no container claims.
* `balena-extension-manager cleanup --stale-os` runs at the HUP commit hook. It additionally drops the containers and images whose labels no longer match the running system.

See [Managing hostapp extensions](#managing-hostapp-extensions).

## Extension hooks

An extension can ship executable scripts at `hooks/create`, `hooks/start` and `hooks/delete` in its rootfs.

`balena-extension-runtime` runs each one at the matching point of the OCI lifecycle and skips any that is absent, so hooks are entirely optional. They run with a fixed `PATH`, `EXTENSION_ROOTFS` pointing at the extension's merged rootfs, every `io.balena.image.*` label forwarded as `EXTENSION_IMAGE_<NAME>`, and every mount forwarded as `EXTENSION_VOLUME_<DESTINATION>`. The runtime's own environment is not inherited.

`hooks/start` is the only place an extension can decline to activate. A non-zero exit there records the container as `Exited (1)` while reporting the `start` call itself as successful, so the caller stops rather than retrying a decision that will not change. A non-zero exit from `hooks/create` fails the create call instead, because at that point there is no container status to carry a verdict.

`hooks/delete` runs when the container is deleted. Note this is the wrong place for teardown as an extension can be reaped by a path that never reaches an orderly delete.

Teardown needs no hook of its own. Withdrawing an extension is a plain container removal, and the state a kernel override publishes outside its rootfs is converged at the next boot; see [Withdrawing a kernel override](#withdrawing-a-kernel-override). `hooks/delete` remains available for extension only cleanup.

## Kernel override extensions

A hostapp extension can replace the running kernel rather than only adding files to the root filesystem. Such an extension carries a kernel image in a `/boot` volume, plus the matching modules and their `Module.symvers` under `/usr/lib/modules/<release>/`.

The kernel image is booted directly; the modules are layered into the read-only rootfs like any other extension content.

A kernel override extension declares:

* `io.balena.image.kernel-abi-id` and `io.balena.image.kernel-version` as above, identifying the kernel it provides.
* `io.balena.update.requires-reboot=1`, recording that the extension only takes effect after a reboot.

Installing the extension publishes its kernel under `/mnt/data/boot-by-abi/<kernel-abi-id>`; activating it arms that build id for the next boot. If the armed kernel is missing, or the initramfs cannot load it, the boot falls back to the stock kernel shipped with the OS.

The activation path is driven by the `/hooks/{create,start}` scripts that `kernel-override-hooks` installs into every extension rootfs:

* `create`, invoked by `balena-extension-runtime`, symlinks `/mnt/data/boot-by-abi/<abi>` to the extension's `/boot` volume, using a path relative to the data partition so the link resolves the same way in the initramfs and in the running OS.
* `start`, also invoked by `balena-extension-runtime`, verifies that the symlink resolves to a real kernel image, refuses to re-arm an ABI that boot-time validation has already rejected, records whether the VPN was reachable before the change, and then writes `kernel_override_abi` into the boot environment. That write comes last, and it is what opens the validation window described below.
* The initramfs `kexec` script reads `kernel_override_abi`, boots `/mnt/data/boot-by-abi/<abi>/<kernel image>` when it exists and falls back to the stock kernel otherwise. It publishes the kernel it loaded on the command line as `balena_kernel_abi=<abi>`, and that token is how the rest of the system knows which kernel is running.

Each hook starts by testing whether the rootfs it was handed is a kernel override at all, so the same hooks are harmless in a userspace-only extension.

### Validating a kernel override

An armed override is on trial until a boot ratifies it. Three boot environment keys carry that state:

* `kernel_override_abi`: the live intent, the ABI the next boot should load.
* `kernel_override_abi_committed_<slot>`: the ABI that root filesystem slot has already proven healthy. An empty value means the slot is known good on the stock kernel.
* `kernel_override_abi_rejected`: written by a rollback to tell the next boot which ABI it must undo.

A boot whose live value matches the running slot's committed value is an ordinary boot and costs three reads. Anything else is a pending verdict, reached down one of two paths.

Inside a HUP, `rollback-health` owns the verdict. Healthchecks passing commit the running ABI for the slot. Healthchecks failing restore the other slot's committed override and roll the root filesystem back with it, so the kernel and the rootfs move together.

Outside a HUP, `extension-rollback.service` owns it. The unit runs on every boot, because an override can be armed with no update in progress and so leaves no breadcrumb to gate on. It stands aside while a HUP is in flight, then settles, runs the same healthchecks, and either commits the ABI for the running slot or rejects it.

### Withdrawing a kernel override

Withdrawal is a container removal and nothing else. Whoever manages the extension removes its container.

What the removal does not touch is the state the override published outside the container: the armed `kernel_override_abi`, the committed snapshot in every slot that ratified it, and the `boot-by-abi` symlink. Those are converged at the next boot by `extension-rollback.service`, which reconciles before it reads any of the state its own validation depends on. The `/boot` volume is converged in the same boot by `balena-extension-manager cleanup`, which collects it once no container claims it. Losing the volume costs a refill: its content is a function of the image id it is named after, so a redeploy reproduces it locally.

## Image retention across HUPs

Extension images declare which OS versions they are valid for via the `io.balena.image.os-version` label. At the post-HUP commit (the rollback-health boundary), the engine-side cleanup runs `balena-extension-manager cleanup --stale-os`, which removes extension images whose label no longer satisfies the new OS version, and preserves the ones that do.

* `io.balena.image.os-version=<pattern>[,<pattern>...]`: a comma-separated list of shell-style globs (`filepath.Match` semantics) matched against `/etc/os-release` `VERSION_ID`. Any match retains the image. A missing or empty label is a legacy-safe retain.

```dockerfile
FROM scratch

LABEL io.balena.image.class=overlay
LABEL io.balena.image.os-version=2.119.*

COPY --from=builder /hostext /
```

Common choices:

* Exact version (`2.119.0`): drops on any patch or suffix bump. Use for extensions that pin tightly (e.g. signed kernel modules whose ABI guarantees don't extend across patches).
* Minor-line glob (`2.119.*`): survives patch-level HUPs and suffixed variants like `2.119.0-staging`. Recommended default.
* Minor-list glob (`2.119.*,2.120.*`): builder opts in to one minor version of forward compatibility.

Because `filepath.Match`'s `*` matches `.`, `2.119.*` also matches `2.119.0-staging`, `2.119.1+rev1`, and similar suffixed versions; this is intentional.

Extensions built in-tree take the exact-version end of that scale: the build stamps the version of the OS being built, so the image is retained only for that OS version. This is the intended behaviour for an extension that ships with, and is rebuilt by, each release.

The `--stale-os` pass applies one predicate to containers and images alike: any claim among `kernel-abi-id`, `kernel-version` and `os-version` that the running system violates makes the object stale. A stale container is removed outright, with no hook and no rejection recorded: the removal is a withdrawal rather than a verdict, and whatever a kernel override left armed behind it is swept at the next boot by `extension-rollback.service`. Before the commit, during the rollback window, no image is pruned: a stale image is what a rollback returns to.

Volumes are not in that pass. A fabricated `ext_*` volume is collected on every boot by the plain `cleanup`, on the claim predicate rather than the staleness one. Gated on staleness it leaked: withdraw an override on a device that stays on its current OS and its volume is never stale, so nothing ever took it.

## Extensions that require a reboot

* `io.balena.update.requires-reboot=1`: records that the extension needs a host reboot to take effect. The label carries no behaviour of its own today. Mobynit composes the root filesystem once, at boot, so the device agent treats every overlay as reboot-activated and schedules the reboot whether or not the label is present. It is reserved in the extension contract for a future runtime-activated class, and remains useful as a declaration of intent; extensions built in-tree set it to `1`.

## Managing hostapp extensions

Extensions are meant to be managed by the supervisor or as part of a hostOS update. Manually installing, removing or updating hostapp extensions is neither advised nor supported.

On-host lifecycle is handled by the `balena-extension-runtime` recipe, which ships two binaries: `balena-extension-runtime` (the OCI runtime) and `balena-extension-manager` (the lifecycle helper).

Three sweepers converge what an extension leaves behind. Each collects what it can reach at the moment it must run, and only what its own claim source can prove is unreferenced. That rule, rather than the object type or the update window, is what decides who owns what:

| Sweeper | When | Claim source | Predicate | Owns |
|---|---|---|---|---|
| `extension-rollback.service` | every boot, before the armed override is judged, with the engine possibly down | mobynit, reading the container store off the disk | no container claims this ABI | boot environment keys, the `boot-by-abi` symlink |
| `balena-extension-manager cleanup` | every boot, with the engine up | the engine's container list | the engine calls the container garbage; no container claims this volume | containers, fabricated `ext_*` volumes |
| `balena-extension-manager cleanup --stale-os` | HUP commit | the engine plus the running system's identity | a declared compatibility claim is violated | containers, images |

Two consequences are worth stating:

* The first two key on the same fact, that no container claims the object, so they need no ordering between them. `hostapp-extensions-cleanup.service` and `extension-rollback.service` are unordered, and stay that way.
* `--stale-os` is not the primary convergence path for containers. The device agent already drops a container whose claim the running kernel did not honour, at its next poll and with no window gating. The manager's stale-container pass is the orphan net for extensions the agent cannot see: a manual deploy, or a release it no longer tracks. Images are the part only `--stale-os` can do, and that is what the `os-version` label was designed for.

The call sites: `hostapp-extensions-cleanup.service` is a oneshot ordered after `balena.service` and before the supervisor; the `85-fwd_commit_os-blocks-extensions` forward-commit hook adds `--stale-os` (see [Image retention across HUPs](#image-retention-across-hups)).

Removal is a plain container removal, issued by whatever manages the extension. The image is kept until the commit, so a rollback still finds it on disk. The `ext_*` volume is not: it is collected at the next boot once no container claims it, and a redeploy refills it from the image. There is no separate disarm step and the manager carries no verb for one; see [Withdrawing a kernel override](#withdrawing-a-kernel-override) for what the next boot does with the state a kernel override left behind.

## Disabling hostapp extension overlays

An incorrect hostapp extension can leave your system in a non-working state. Balena advises against deploying custom made hostapp extensions and recommends to either use the hostapp extensions included as part of BalenaOS releases, or let the supervisor manage the installation, update and removal of production ready hostapp extensions.

The overlaying of hostapp extensions can be disabled by specifying either of the following kernel command line arguments:

* `mobynit.no_overlays`
* `emergency`

## Caveats

* The root filesystem is intrinsically read-only when hostapp extensions are layered.
* Hostapp extensions require the overlay2 storage driver.
