# Host extensions support

## Overview

BalenaOS supports layering the root filesystem with content from host extension containers that are managed by the supervisor. In essence, host extensions are container images flagged with the `balena.io.features.host-extension` label that are overlayed during the early boot process.

Host extension containers are meant to extend or modify the root filesystem in a managed way, and to house content that cannot be placed on an application container.

When deciding whether to use a host extension for your content, first consider whether there is any reason why it could not be added to a standard application container.

## Building a host extension container

The last stage of a host extension container is shown next:

    FROM k8s.gcr.io/pause-${ARCH}:3.1

    LABEL io.balena.features.host-extension=1

    COPY --from=builder /hostext /

The Dockerfile above is based on the `pause` container which contains a statically built `pause` application that just sleeps. This allows to run the container without a shell or extra libraries.

The next step adds the `io.balena.features.host-extension` label so that BalenaOS can identify it and overlay it at boot.

Finally, the desired content is copied from a space holder directory to the root of this container. Care should be taken not to shadow root filesystem content which is essential for BalenaOS to function.

## Disabling host extension overlays

An incorrect host extension can leave your system in a non-working state. Balena advises against deploying custom made host extensions and recommends to let the supervisor manage the installation, update and removal of production ready host extension.

The overlaying of host extensions can be disabled by specifying a `balena.nohostext` argument to the kernel command line.

## Caveats

* Once BalenaOS has overlayed a host extension the root filesystem cannot be remounted read-write.
* Host extensions are only supported for overlay2 filesystems
* The numbers of extensions that can be mounted is capped by the length of the options passed to the kernel's do_mount() function which is currently the system's page size. For the typical paths in BalenaOS this is around 20 containers.
