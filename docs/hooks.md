# Introduction

Host OS update hooks run on devices to configure the device before a Host OS Update. They usually handle the boot partition or any migrations between various OS versions.

# Hooks v2.0 flow
Hooks v2.0 improve hooks v1.0 and allow trigging hooks from the new OS at various points in the host OS update process. The main improvement is the ability to run selected hooks from the newOS in the old OS environment.

Hook v2.0 Flow diagram

```
+------+       +---------------------+    +---------------------------+ +----------------------+ +--------------------+   +----------------------------------+
|OLD OS+------>+ before              +--->+ forward                   +-> after                +-> reboot into new OS +-->+rollback tests mark new OS healthy|
+------+       | fetched from new OS |    | fetched from new OS       | | fetched from new OS  | +--------------------+   |commit_hooks are run              |
               | run in old OS       |    | run in new OS container   | | run in old OS        |                          |                                  |
               +---------------------+    +---------------------------+ +----------------------+                          +----------------------------------+
```

- Hooks in the v2.0 format will exist as a folder in `/etc/hostapp-update-hooks.d/`. The folder can contain several hooks that are related to each other.

An example Hooks 2.0 file name format inside the folder.

- _/etc/hostapp-update-hooks.d/50-testhook/before_:
 - During HUP, these hooks from the new OS are run in the previous OS environment
 - They run 'before' all the main forward hooks and 1.0.
 - e.g. Before hup, we’d like to save the vpn state for rollbacks
 - The working directory and environment of this hook requires extra cautions while writing. The working directory is a long mount in the sysroot inactive partition. The HOOKS_DIR environment variable contains the path of the base of the new rootfs.

- _/etc/hostapp-update-hooks.d/50-testhook/forward_:
 - These are pretty much the same as old Hooks 1.0
 - e.g. aufs to overlay migration hook. The part that makes the overlay metadata
 - During HUP, these hooks are in the new OS container.

- _/etc/hostapp-update-hooks.d/50-testhook/fwd_cleanup_:
 - In case any HUP hook fails to run, the fwd_cleanup hooks are run in the same new OS container where the forward hooks were running.
 - e.g. Clean up overlay folder as aufs to overlay migration hasn’t worked out.

- _/etc/hostapp-update-hooks.d/50-testhook/after_:
  - During HUP, this runs in previous OS environment
  - They run 'after' all the main forward hooks and 1.0 have run.
  - The working directory and environment of this hook requires extra cautions while writing. Similar to before hook.
  - For future extension.

- _/etc/hostapp-update-hooks.d/50-testhook/fwd_commit_:
 - In the new OS, when rollbacks marks the OS as healthy, these are run by rollbacks. - Any backwards incompatible destructive non-reversible steps can be done here
 - e.g. Clean up aufs folder as aufs to overlay migration is complete


- Note: `before` `after` `commit` `cleanup` `forward` are now keywords and HOOKNAME cannot contain those.

# Potential Issues/Cautionary statements
- __If a device is migrating from an OS version that doesn't support v2 hooks, 'before' and 'after' wont run!__
- If a power failure happens, next attempt at HUP will run hooks again, so hooks need to be idempotent.
- Existing OS will be running the previous version of `hostapp-update` up until the point when it downloads the new os and then it will run the new version of `hostapp-update-hooks` in a container in the new OS environment.
- Please take extra precaution about what environment a hook is running in. particularly, what OS environment, the DURING_UPDATE environment variable and if we are running during a normal HUP or a failover path such as rollbacks or failed hup. Rollbacks(health or altboot) makes it more confusing. A rough idea/question to ask about DURING_UPDATE is that are the correct healthy files in the inactive partition or in the active partition. If the correct files are in the inactive partition, DURING_UPDATE is 1. If the correct files are in the active partition, DURING_UPDATE=0.

# Possible Future Extensions
Currently we aren’t writing hooks that properly ‘roll’ things back. i.e. forward hooks should be complemented by proper backward hooks so that a proper roll back can happen.
That can be added in the future.

## Legacy Hooks v1.0 flow
- Hooks are scripts in the folder `/etc/hostapp-update-hooks.d/XX-YYYY` where XX is usually a number for sorting hooks sensibly
