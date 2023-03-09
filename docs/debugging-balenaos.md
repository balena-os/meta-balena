# balenaOS Debugging

## Journal Logs

balenaOS uses [systemd](https://www.freedesktop.org/wiki/Software/systemd/) as
its [init system](https://en.wikipedia.org/wiki/Init), and as such almost all
the fundamental components in balenaOS run as systemd services. systemd builds
a dependency graph of all of its unit files (in which services are defined) to
determine the order that these should be started/shutdown in. This is
generated when systemd is run, although there are ways to rebuild this after
startup and during normal system execution.

Possibly the most important command is `journalctl`, which allows you to read
the service's journal entries. This takes a variety of switches, the most
useful being:

- `--follow`/`-f` - Continues displaying journal entries until the command is halted
  (eg. with Ctrl-C)
- `--unit=<unitFile>`/`-u <unitFile>` - Specifies the unit file to read journal
  entries for. Without this, all units entries are read.
- `--pager-end`/`-e` - Jump straight to the final entries for a unit.
- `--all`/`-a` - Show all entries, even if long or with unprintable
  characters. This is especially useful for displaying the service container
  logs from user containers when applied to `balena.service`.

A typical example of using `journalctl` might be following a service to see
what's occuring. Here's it for the Supervisor, following journal entries in
real time:

```shell
root@9294512:~# journalctl --follow --unit=balena-supervisor
-- Journal begins at Fri 2021-08-06 14:40:59 UTC. --
Aug 18 16:56:55 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
Aug 18 16:57:05 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
Aug 18 16:58:17 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
Aug 18 16:58:27 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
Aug 18 16:58:37 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
Aug 18 16:58:48 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
Aug 18 16:58:58 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
Aug 18 16:59:19 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
Aug 18 16:59:40 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
Aug 18 17:00:00 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
```

Any systemd service can be referenced in the same way, and there are some common
commands that can be used with services:

- `systemctl status <serviceName>` - Will show the status of a service. This
  includes whether it is currently loaded and/or enabled, if it is currently
  active (running) and when it was started, its PID, how much memory it is
  notionally (and beware here, this isn't always the amount of physical
  memory) using, the command used to run it and finally the last set of
  entries in its journal log. Here's example output from the OpenVPN service:

  ```shell
  root@9294512:~# journalctl --follow --unit=balena-supervisor
  -- Journal begins at Fri 2021-08-06 14:40:59 UTC. --
  Aug 18 16:56:55 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
  Aug 18 16:57:05 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
  Aug 18 16:58:17 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
  Aug 18 16:58:27 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
  Aug 18 16:58:37 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
  Aug 18 16:58:48 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
  Aug 18 16:58:58 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
  Aug 18 16:59:19 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
  Aug 18 16:59:40 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
  Aug 18 17:00:00 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
  Aug 18 17:00:11 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
  Aug 18 17:00:31 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
  Aug 18 17:00:42 9294512 balena-supervisor[6890]: [info]    Reported current state to the cloud
  Aug 18 17:00:49 9294512 balena-supervisor[6890]: [api]     GET /v1/healthy 200 - 3.272 ms
  ```

- `systemctl start <serviceName>` - Will start a non-running service. Note that
  this will _not_ restart a service that is already running.
- `systemctl stop <serviceName>` - Will stop a running service. If the service
  is not running, this command will not do anything.
- `systemctl restart <serviceName>` - Will restart a running service. If the
  service is not running, this will start it.
- `systemctl daemon-reload` - Will essentially run through the startup process
  systemd carries out at initialisation, but without restarting services or
  units. This allows the rebuild of the system dependency graph, and should be
  carried out if any of the unit files are changed whilst the system is
  running.

This last command may sound a bit confusing but consider the following. Imagine
that you need to dynamically change the `balena-supervisor.service` unit file
to increase the healthcheck timeout on a very slow system. Once that change has
been made, you'll want to restart the service. However, first, you need to
reload the unit file as this has changed from the loaded version. To do this,
you'll run `systemctl daemon-reload` and then
`systemctl restart balena-supervisor.service` to restart the Supervisor.

In general, there are some core services that need to execute for a device to
come online, connect to the balenaCloud VPN, download releases and then run
them:

- `chronyd.service` - Responsible for NTP duties and syncing 'real' network
  time to the device. Note that balenaOS versions less than v2.13.0 used
  `systemd-timesyncd.service` as their NTP service, although inspecting it is
  very similar to that of `chronyd.service`.
- `dnsmasq.service` - The local DNS service which is used for all host OS
  lookups (and is the repeater for user service containers by default).
- `NetworkManager.service` - The underlying Network Manager service, ensuring
  that configured connections are used for networking.
- `os-config.service` - Retrieves settings and configs from the API endpoint,
  including certificates, authorized keys, the VPN config, etc.
- `openvpn.service` - The VPN service itself, which connects to the balenaCloud
  VPN, allowing a device to come online (and to be SSHd to and have actions
  performed on it). Note that in balenaOS versions less than v2.10.0 this
  was called `openvpn-resin.service`, but the method for inspecting and
  dealing with the service is the same.
- `balena.service` - The balenaEngine service, the modified Docker daemon fork
  that allows the management and running of service images,
  containers, volumes and networking.
- `balena-supervisor.service` - The {{ $names.company.short }} Supervisor service,
  responsible for the management of releases, including downloading updates of the app and
  self-healing (via monitoring), variables (fleet/device), and exposure of these
  services to containers via an API endpoint.
- `dbus.service` - The DBus daemon socket can be used by services if the
  `io.balena.features.dbus` label is applied. This exposes the DBus daemon
  socket in the container which allows the service to control several
  host OS features, including the Network Manager.

Additionally, there are some utility services that, whilst not required
for a barebones operation, are also useful:

- `ModemManager.service` - Deals with non-Ethernet or Wifi devices, such as
  LTE/GSM modems.
- `avahi-daemon.service` - Used to broadcast the device's local hostname
  (useful in development mode, responds to `balena scan`).

We'll go into several of these services in the following sections, but generally
these are the first points to examine if a system is not behaving as it should,
as most issues will be associated with these services.

Additionally there are a large number of utility services that facilitate the
services above, such as those to mount the correct partitions for data storage,
configuring the Supervisor and running it should it crash, etc.


## Using the Kernel Logs

There are occasionally instances where a problem arises which is not immediately
obvious. In these cases, you might see services fail 'randomly', perhaps
attached devices don't behave as they should, or maybe spurious reboots occur.

If an issue isn't apparent fairly soon after looking at a device, the
examination of the kernel logs can be a useful check to see if anything is
causing an issue.

To examine the kernel log on-device, simply run `dmesg` from the host OS:

```shell
root@debug-device:~# dmesg
[    0.000000] Booting Linux on physical CPU 0x0000000000 [0x410fd083]
[    0.000000] Linux version 5.10.95-v8 (oe-user@oe-host) (aarch64-poky-linux-gcc (GCC) 11.2.0, GNU ld (GNU Binutils) 2.37.20210721) #1 SMP PREEMPT Thu Feb 17 11:43:01 UTC 2022
[    0.000000] random: fast init done
[    0.000000] Machine model: Raspberry Pi 4 Model B Rev 1.2
[    0.000000] efi: UEFI not found.
[    0.000000] Reserved memory: created CMA memory pool at 0x000000001ac00000, size 320 MiB
[    0.000000] OF: reserved mem: initialized node linux,cma, compatible id shared-dma-pool
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000000000-0x000000003fffffff]
[    0.000000]   DMA32    [mem 0x0000000040000000-0x000000007fffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000000000-0x000000003e5fffff]
[    0.000000]   node   0: [mem 0x0000000040000000-0x000000007fffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000000000-0x000000007fffffff]
[    0.000000] On node 0 totalpages: 517632
[    0.000000]   DMA zone: 4096 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 255488 pages, LIFO batch:63
[    0.000000]   DMA32 zone: 4096 pages used for memmap
[    0.000000]   DMA32 zone: 262144 pages, LIFO batch:63
[    0.000000] On node 0, zone DMA32: 512 pages in unavailable ranges
[    0.000000] percpu: Embedded 32 pages/cpu s92376 r8192 d30504 u131072
[    0.000000] pcpu-alloc: s92376 r8192 d30504 u131072 alloc=32*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3
[    0.000000] Detected PIPT I-cache on CPU0
[    0.000000] CPU features: detected: Spectre-v2
[    0.000000] CPU features: detected: Spectre-v4
[    0.000000] CPU features: detected: ARM errata 1165522, 1319367, or 1530923
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 509440
[    0.000000] Kernel command line: coherent_pool=1M 8250.nr_uarts=0 snd_bcm2835.enable_compat_alsa=0 snd_bcm2835.enable_hdmi=1  smsc95xx.macaddr=DC:A6:32:9E:18:DD vc_mem.mem_base=0x3f000000 vc_mem.mem_size=0x3f600000  dwc_otg.lpm_enable=0 rootfstype=ext4 rootwait dwc_otg.lpm_enable=0 rootwait vt.global_cursor_default=0 console=null cgroup_enable=memory root=UUID=ba1eadef-20c9-4504-91f4-275265fa5dbf rootwait
[    0.000000] cgroup: Enabling memory control group subsystem
[    0.000000] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes, linear)
[    0.000000] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes, linear)
[    0.000000] mem auto-init: stack:off, heap alloc:off, heap free:off
[    0.000000] software IO TLB: mapped [mem 0x000000003a600000-0x000000003e600000] (64MB)
[    0.000000] Memory: 1602680K/2070528K available (11392K kernel code, 2022K rwdata, 4460K rodata, 14208K init, 1284K bss, 140168K reserved, 327680K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] ftrace: allocating 44248 entries in 173 pages
[    0.000000] ftrace: allocated 173 pages with 5 groups
[    0.000000] rcu: Preemptible hierarchical RCU implementation.
[    0.000000] rcu: 	RCU event tracing is enabled.
[    0.000000] rcu: 	RCU restricting CPUs from NR_CPUS=256 to nr_cpu_ids=4.
[    0.000000] 	Trampoline variant of Tasks RCU enabled.
[    0.000000] 	Rude variant of Tasks RCU enabled.
[    0.000000] 	Tracing variant of Tasks RCU enabled.
[    0.000000] rcu: RCU calculated value of scheduler-enlistment delay is 25 jiffies.
[    0.000000] rcu: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=4
[    0.000000] NR_IRQS: 64, nr_irqs: 64, preallocated irqs: 0
[    0.000000] GIC: Using split EOI/Deactivate mode
[    0.000000] irq_brcmstb_l2: registered L2 intc (/soc/interrupt-controller@7ef00100, parent irq: 10)
[    0.000000] random: get_random_bytes called from start_kernel+0x3a4/0x570 with crng_init=1
[    0.000000] arch_timer: cp15 timer(s) running at 54.00MHz (phys).
[    0.000000] clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0xc743ce346, max_idle_ns: 440795203123 ns
[    0.000007] sched_clock: 56 bits at 54MHz, resolution 18ns, wraps every 4398046511102ns
[    0.000332] Console: color dummy device 80x25
[    0.000405] Calibrating delay loop (skipped), value calculated using timer frequency.. 108.00 BogoMIPS (lpj=216000)
[    0.000443] pid_max: default: 32768 minimum: 301
[    0.000643] LSM: Security Framework initializing
[    0.000891] Mount-cache hash table entries: 4096 (order: 3, 32768 bytes, linear)
[    0.000939] Mountpoint-cache hash table entries: 4096 (order: 3, 32768 bytes, linear)
...
```

The rest of the output is truncated here. Note that the time output is in
seconds. If you want to display a human readable time, use the `-T` switch.
This will, however, strip the nanosecond accuracy and revert to chronological
order with a minimum granularity of a second.

Note that the 'Device Diagnostics' tab from the 'Diagnostics' section of a
device also runs `dmesg -T` and will display these in the output window.
However, due to the sheer amount of information presented here, it's sometimes
easier to run it on-device.

Some common issues to watch for include:

- Under-voltage warnings, signifying that a device is not receiving what it
  requires from the power supply to operate correctly (these warnings
  are only present on the Raspberry Pi series).
- Block device warnings, which could signify issues with the media that balenaOS
  is running from (for example, SD card corruption).
- Device detection problems, where devices that are expected to show in the
  device node list are either incorrectly detected or misdetected.
