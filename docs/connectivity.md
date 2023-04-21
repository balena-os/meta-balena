# Network failover and interface recovery

balenaOS monitors the health of the system's primary network connection and
automatically falls back to the next-available network connection on failure.

balenaOS also provides mechanisms to recover a failed interface in the
background, and switch back to it when the connection is restored.

## Establishing network interface priority

Each network interface is assigned a metric in the kernel's routing table, and
this metric establishes the interface priority order. The primary interface will
be that with the lowest metric.

The metric for a specific interface can be configured in its connection profile
as follows:
```
[ipv4]
route-metric=40

[ipv46]
route-metric=40
```

## Network interface failover

A network interface is monitored for different events, notably:

* Loss of physical link
* Upstream connectivity check

### Physical link loss

In case of the loss of the physical link, the interface is brought down and
removed from the routing table so it is no longer being used. When the link
comes up again, the interface is automatically brough up and re-added to the
routing table with its configured metric.

### Connectivity check

NetworkManager performs connectivity checks over each interface in the routing
table by sending an HTTP request to a given URL and waiting for the response
specified in the configuration.

The default connectivity endpoint is `api.balena-cloud.com` but this as well
as the response can be configured in `config.json` as described [here](https://github.com/balena-os/meta-balena#connectivity).

When the connectivity check fails on a specific interface, its metric in the
routing table is penalized so the system switches to using the next available
route.

The connectivity change events are reported to the dispatcher scripts and
can be used to perform custom operations on the interface to recover them.
As soon as the connectivy is restored for an interface, the routing table's
metric goes back to its normal state so the system switches back to using it.

### DNS resolution and per-interface connectivity checks

An important consideration when configuring connectivity checks is that
DNS resolutions is using the system resolver and it defauls to always using
the default network connection. For per-interface connectivity checks not to
fail in group when the primary interface fails, the system needs to have been
configured with per-interface DNS resolvers.

If using the default configuration, balenaOS adds Google public nameservers
that are accessed through the primary interface. For DNS resolution to work
on other interfaces, a different DNS server needs to be binded to them by
using the `dnsServers` entry in `config.json` as described [here](https://github.com/balena-os/meta-balena#dnsservers).

For example, the following entry in `config.json` would add an extra DNS
server that resolves over a `wwan0` interface:
```
dnsServers: '1.1.1.1@wwan0'
```

## Network interface recovery

Custom recovery actions can be added to the `dispatcher.d` folder in the boot
partition of the device, in the same way that network configuration can be
added to the `system-connections` folder.

NetworkManager's [dispatcher scripts](https://networkmanager.dev/docs/api/latest/NetworkManager-dispatcher.html) executes scripts under the `dispatcher.d` folder
and subfolders in alphabetical order, and passes both the interface name and the
event that happened on that interface.

The default `dispatcher.d` folder has one sub-folder for each of the following
event types:

* **up / down**: A network connection has come up or down.
* **device-connectivity-change**: A network interface has changed from full.
  The device might still have full connectivity through an alternative
  interface.
* **connectivity-change**: The system connectivity state has changed from full
  and the device no longer has network connectivity through any interface.

Custom recovery actions can be executed by placing custom scripts into any
of the above subfolders.
