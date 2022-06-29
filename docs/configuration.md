# `balenaOS` configuration

`balenaOS` has a central configuration database in the form of a `config.json` file in the boot partition. This configuration file is modified mostly by the supervisor and is not meant to be user editable.

## Runtime configuration changes

There is a watcher service on `config.json` that reacts to file modifications and parses the configuration file into service configuration units.

The database file that maps service units with configuration entries in `config.json` is `unit-conf.json`. Each configurable service needs to add an entry to this file as follows:

```
"ServiceName": {
    "description": "Service unit description",
    "configuration": "configEntry1 configEntry2 ..."
}
```

Each service configuration file is another json file in volatile memory that contains just the existing configuration entries that affect a given service. The service configuration files also have a watcher unit so that when they are modified the attached service is restarted. This allows for runtime re-configuration of services without the need for a device reboot.

## Adding configuration capabilities to a systemd service unit

In order to make a service unit configurable it just needs to inherit the `balena-configurable` class, as well as exteding the `unit-conf.json` file as explained above.

By default only a service configuration unit with the same name of the package is configured, but this can be configured using the `SYSTEMD_UNIT_NAMES` variable.

A service unit that inherits the `balena-configurable` class is extended to generate a service unit configuration with the service unit configuration at start time, as well as setting the appropriate watcher units on the service unit configuration files.
