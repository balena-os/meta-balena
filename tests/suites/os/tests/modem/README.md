# Modem test suite

This suite will check any modems attached to the device under test (DUT), for compatibility with the version of Modem Manager in the OS.
If a modem is undetected, the tests will pass gracefully; this is intentionally designed to allow this test to run on test rigs that do not have modems attached.

## Requirements

- One or more supported modems
- A standard size SIM card with data plan
- Cellular network coverage for the specified network (i.e. the DUT can connect to the internet via cellular)

## Configuration

In order to configure the suite for the modems attached, update the `modems.json` config file to include the APN settings for the SIM card.

For example:

```json
{
    "network": {
        "apn": "soracom.io",
        "ipType": "ipv4",
        "user": "sora",
        "password": "sora",
        "testUrl": "8.8.8.8"
    },
    "skip": []
}
```

`skip` can be configured to bypass a specified modem by name.
`network.testUrl` is the target URL (or IP address) used to check network connectivity.
