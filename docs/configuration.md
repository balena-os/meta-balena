# `balenaOS` configuration

`balenaOS` has a central configuration database in the form of a `config.json` file in the boot partition. This configuration file is modified mostly by the supervisor and is not meant to be user editable.

## Runtime configuration changes

There is a watcher path unit on `config.json` that reacts to file modifications and parses the configuration file into service configuration unit files, that is, another json file usually in volatile memory that contains just the existing configuration entries that affect a given service.

The service configuration files also have a watcher unit so that when they are modified the attached service is restarted. This allows for runtime re-configuration of services without the need for a device reboot.

The database file that maps service units with configuration entries in `config.json` is `unit-conf.json`.

## Adding configuration capabilities to a systemd service unit

In order to make a service unit configurable it just needs to inherit the `balena-configurable` class, as well as extending the `unit-conf.json` file by adding an entry to this file as follows:

```
"ServiceName": {
    "description": "Service unit description",
    "configuration": "configEntry1 configEntry2 ..."
}
```
