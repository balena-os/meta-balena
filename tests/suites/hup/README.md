
# Hostapp UPdate tests

Test the transition between balenaOS releases via the `hostapp-update` mechanism.

## setup

1. Download the latest production release of balenaOS for the device type of the DUT
2. set up the test networking environment
3. configure the downloaded OS image
4. provision the DUT with this image
5. power on the DUT with this image
6. send the hostapp file to the DUT
7. trigger a HUP on the DUT, to this new hostapp


## Current tests

- `rollbacks`: tests `rollback-health`, `rollback-altboot`, functionality works as expected. Docs about this framework are [here](https://www.balena.io/docs/reference/OS/updates/rollbacks/)
- `smoke`: tests that the latest production OS release can successfully HUP to the new OS without any rollbacks occuring