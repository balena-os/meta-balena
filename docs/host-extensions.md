# Hostapp extensions support

## Overview

BalenaOS supports layering the root filesystem with content from hostapp extension containers. In essence, hostapp extensions are container images flagged with the `io.balena.image.class=overlay` label that are overlayed during the early boot process.

Hostapp extension containers are meant to extend or modify the root filesystem in a managed way, and to house content that cannot be placed on an application container.

When deciding whether to use a hostapp extension for your content, first consider whether there is any reason why it could not be added to a standard application container.

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

    FROM scratch

    LABEL io.balena.image.class=overlay

    COPY --from=builder /hostext /

The example Dockerfile above starts with an empty container, then adds the `io.balena.image.class=overlay` label so that BalenaOS can identify it and overlay it at boot, and finally the desired content is copied from a space holder directory to the root of this container.

By default, extensions are mounted to the right of the hostapp in the overlayfs lowerdir stack, meaning they can only contribute new files — they cannot replace existing hostapp content.

## Mount ordering

Extensions can define a mount order using the `io.balena.image.override=N` label, where N is a numeric priority. Extensions with this label are mounted to the left of the hostapp in the overlayfs lowerdir stack, enabling them to replace existing hostapp files. Lower N values have higher overlayfs precedence. Equal priorities sort by container name for deterministic behavior.

    FROM scratch

    LABEL io.balena.image.class=overlay
    LABEL io.balena.image.override=10

    COPY --from=builder /hostext /

In overlayfs terminology, `lowerdir=A:B:C` means A has the highest lookup priority. The resulting lowerdir is: `lowerdir=<extensions with override sorted by N>:<hostapp>:<extensions without override>`.

Care should be taken not to shadow root filesystem content which is essential for BalenaOS to function.

## Kernel ABI compatibility

Extensions that ship kernel modules or BTF-sensitive content should declare the kernel they were built against. Mobynit uses these labels at boot to skip extensions whose kernel does not match the running one, preventing module load failures and mitigating ABI drift across HUPs.

* `io.balena.image.kernel-version=M.m.p` — coarse userspace-visible kernel version (e.g. `6.12.61`). Checked against the running kernel's stripped `uname -r`. Missing label is fail-open (extension is mounted).
* `io.balena.image.kernel-abi-id=<sha256>` — precise kernel ABI fingerprint, typically the sha256 of `Module.symvers`. Provides exact module-ABI matching. Optional; mobynit can derive the value from the extension's `Module.symvers` if the label is absent.

<!-- -->

    FROM scratch

    LABEL io.balena.image.class=overlay
    LABEL io.balena.image.kernel-version=6.12.61
    LABEL io.balena.image.kernel-abi-id=<sha256 of Module.symvers>

    COPY --from=builder /lib/modules /lib/modules

The engine-side cleanup service complements this by removing extension containers whose `kernel-version` label no longer matches the running kernel after a HUP.

## Image retention across HUPs

Extension images declare which OS versions they are valid for via the `io.balena.image.os-version` label. At the post-HUP commit (the rollback-health boundary), the engine-side cleanup runs `balena-extension-manager cleanup --stale-os`, which removes extension images whose label no longer satisfies the new OS version, and preserves the ones that do.

* `io.balena.image.os-version=<pattern>[,<pattern>...]` — a comma-separated list of shell-style globs (`filepath.Match` semantics) matched against `/etc/os-release` `VERSION_ID`. Any match retains the image. A missing or empty label is a legacy-safe retain.

<!-- -->

    FROM scratch

    LABEL io.balena.image.class=overlay
    LABEL io.balena.image.os-version=2.119.*

    COPY --from=builder /hostext /

Common choices:

* Exact version (`2.119.0`) — drops on any patch or suffix bump. Use for extensions that pin tightly (e.g. signed kernel modules whose ABI guarantees don't extend across patches).
* Minor-line glob (`2.119.*`) — survives patch-level HUPs and suffixed variants like `2.119.0-staging`. Recommended default.
* Minor-list glob (`2.119.*,2.120.*`) — builder opts in to one minor version of forward compatibility.

Because `filepath.Match`'s `*` matches `.`, `2.119.*` also matches `2.119.0-staging`, `2.119.1+rev1`, and similar suffixed versions — this is intentional.

At HUP commit, an image that fails the predicate is removed; the same HUP has already reconciled containers via the `kernel-version` and `kernel-abi-id` filters above, so no running extension is disrupted. Before the commit, during the rollback window, no image or container retention decisions are altered.

## Reboot-requiring extensions

* `io.balena.update.requires-reboot=1` — marks the extension as needing a host reboot after install/update. The supervisor sets a reboot breadcrumb when creating a container with this label; the host reboots on the next reconcile tick and mobynit layers the extension on the subsequent boot. This is the same label the supervisor already honors on regular services (via the `io.balena.update.*` namespace of update-time directives).

## Managing hostapp extensions

Extensions are meant to be managed by the supervisor or as part of a hostOS update. Manually installing, removing or updating hostapp extensions is neither advised nor supported.

## Disabling hostapp extension overlays

An incorrect hostapp extension can leave your system in a non-working state. Balena advises against deploying custom made hostapp extensions and recommends to either use the hostapp extensions included as part of BalenaOS releases, or let the supervisor manage the installation, update and removal of production ready hostapp extensions.

The overlaying of hostapp extensions can be disabled by specifying either of the following kernel command line arguments:

* `mobynit.no_overlays`
* `emergency`

## Caveats

* The root filesystem is intrinsically read-only when hostapp extensions are layered.
* Hostapp extensions require the overlay2 storage driver.
