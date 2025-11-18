/* Copyright 2019 balena
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';

// Minimal helpers to verify file/dir existence in container or host
const verifyFileOrDirExists = async (context, link, test, path, testFlag, location = 'disk-watchdog') => {
    const exec = location === 'host'
        ? (cmd) => context.get().worker.executeCommandInHostOS(cmd, link)
        : (cmd) => context.get().worker.executeCommandInContainer(cmd, location, link);
    const out = await exec(`test ${testFlag} ${path} && echo exists || echo missing`);
    test.is(out.trim(), 'exists', `${path} should exist (${location})`);
};

const verifyFileExists = async (context, link, test, path, location = 'disk-watchdog') => {
    await verifyFileOrDirExists(context, link, test, path, '-f', location);
};

const verifyDirExists = async (context, link, test, path, location = 'disk-watchdog') => {
    await verifyFileOrDirExists(context, link, test, path, '-d', location);
};

const verifyBlockDeviceExists = async (context, link, test, path, location = 'disk-watchdog') => {
    await verifyFileOrDirExists(context, link, test, path, '-b', location);
};

// Retry helpers: try N times with delay to detect existence
const waitForExists = async (
    context,
    link,
    path,
    testFlag = '-f',
    attempts = 60,
    delaySeconds = 0.5,
    location = 'host',
) => {
    const exec = location === 'host'
        ? (cmd) => context.get().worker.executeCommandInHostOS(cmd, link)
        : (cmd) => context.get().worker.executeCommandInContainer(cmd, location, link);
    const cmd = `sh -lc 'for i in $(seq 1 ${attempts}); do if test ${testFlag} ${path}; then echo exists; exit 0; fi; sleep ${delaySeconds}; done; echo missing'`;
    return (await exec(cmd)).trim();
};

const createDeviceMapper = async (context, link, test, deviceName = 'dm-disk-watchdog') => {
    const containerMount = '/tmp/mnt';
    const containerImage = '/tmp/disk-image';

    await context
        .get()
        .worker.executeCommandInContainer(
            `sh -lc 'bash -x /usr/bin/create-device-mapper.sh ${containerMount} ${containerImage} ${deviceName} 2>&1 | tee /logs/device-mapper.log'`,
            'disk-watchdog',
            link,
        );

    test.comment(await context
        .get()
        .worker.executeCommandInContainer(
            `sh -lc 'cat /logs/device-mapper.log'`,
            'disk-watchdog',
            link,
        ));

    const testBinExists = await waitForExists(context, link, `${containerMount}/test.bin`, '-f', 10, 1, 'disk-watchdog');
    test.is(testBinExists, 'exists', `${containerMount}/test.bin should exist in container`);
    await verifyFileExists(context, link, test, "/bin/bash", 'disk-watchdog');
    await verifyFileExists(context, link, test, `${containerImage}`, 'disk-watchdog');
    await verifyDirExists(context, link, test, `/dev/mapper/`, 'disk-watchdog');
    await verifyBlockDeviceExists(context, link, test, `/dev/mapper/${deviceName}`, 'disk-watchdog');
    await verifyBlockDeviceExists(context, link, test, `/dev/mapper/${deviceName}`, 'host');

    await context
        .get()
        .worker.executeCommandInContainer(
            `sh -lc 'umount ${containerMount}'`,
            'disk-watchdog',
            link,
        );
};

const mountDeviceMapper = async (context, link, test, deviceName, hostMount) => {
    await context
        .get()
        .worker.executeCommandInHostOS(
            `mkdir -p ${hostMount} && mount /dev/mapper/${deviceName} ${hostMount}`,
            link,
        );
    const mp = await context
        .get()
        .worker.executeCommandInHostOS(
            `mountpoint -q ${hostMount} && echo mounted || echo not`,
            link,
        );
    test.is(mp.trim(), 'mounted', `${hostMount} should be a mount point on host`);

    const wait = await waitForExists(context, link, `${hostMount}/test.bin`);
    test.is(wait, 'exists', `${hostMount}/test.bin should eventually exist on host`);
};

const activate_dm_error = async (context, link, test, deviceName) => {
    test.comment('Activating error mode on the device mapper...');
    const sectors = await context
        .get()
        .worker.executeCommandInContainer(
            `blockdev --getsz /dev/mapper/${deviceName}`,
            'disk-watchdog',
            link,
        );
    await context
        .get()
        .worker.executeCommandInContainer(
            `sh -lc 'dmsetup suspend ${deviceName} && echo "0 ${sectors.trim()} error" | dmsetup reload ${deviceName} && dmsetup resume ${deviceName}'`,
            'disk-watchdog',
            link,
        );
    test.comment('Error mode activated - all I/O will now fail');
};

const modify_disk_watchdogd_systemd = async (context, link, test) => {
    await context
        .get()
        .worker.executeCommandInHostOS(
            `mkdir -p /run/systemd/system/disk-watchdogd.service.d`,
            link,
        );

    await context.get().worker.sendFile(
        `${__dirname}/disk-watchdog-override.conf`,
        `/run/systemd/system/disk-watchdogd.service.d/override.conf`,
        link,
    );

    await verifyFileExists(context, link, test, `/run/systemd/system/disk-watchdogd.service.d/override.conf`, 'host');

    test.comment('Restarting disk-watchdogd...');
    await context
        .get()
        .worker.executeCommandInHostOS(
            `systemctl daemon-reload && systemctl restart disk-watchdogd`,
            link,
        );
};

const expectRebootSoon = async (context, link, test, timeoutSeconds = 120, pollSeconds = 2) => {
    // Create a marker in /tmp that should disappear after reboot
    await context
        .get()
        .worker.executeCommandInHostOS(
            `touch /tmp/reboot-check`,
            link,
        );

    const start = Date.now();
    let rebooted = false;
    while ((Date.now() - start) / 1000 < timeoutSeconds) {
        test.comment(`Waiting for device to reboot... ${Math.floor((Date.now() - start) / 1000)} / ${timeoutSeconds} seconds`);
        const status = await context
            .get()
            .worker.executeCommandInHostOS(
                `[[ ! -f /tmp/reboot-check ]] && echo gone || echo present || true`,
                link,
            );
        if (status.trim() === 'gone') {
            test.comment('Device rebooted (marker in /tmp disappeared)');
            rebooted = true;
            break;
        }
        await new Promise((r) => setTimeout(r, pollSeconds * 1000));
    }
};

const verify_boot_count = async (context, link, test, expectedCount = '2') => {
    const bootLines = await context
        .get()
        .worker.executeCommandInHostOS(
            `sh -lc 'wc -l < /mnt/state/disk-watchdog/boot-history'`,
            link,
        );

    test.is(bootLines.trim(), String(expectedCount), `boot-history should have ${expectedCount} lines`);
};

const verify_service_disabled = async (context, link, test) => {
    // Reset boot-history and add 3 controlled timestamps: now, now-60s, now-120s
    await context
        .get()
        .worker.executeCommandInHostOS(
            `sh -lc 'n=$(date +%s); printf "%s\n%s\n%s\n" "$n" "$((n-60))" "$((n-120))" > /mnt/state/disk-watchdog/boot-history'`,
            link,
        );

    // Ensure the count matches expectation after reset
    await verify_boot_count(context, link, test, String(3));

    // Restart service; ExecStartPre should prevent start and create disabled marker
    await context
        .get()
        .worker.executeCommandInHostOS(
            `systemctl restart disk-watchdog-boot-history disk-watchdogd || true`,
            link,
        );

    // Verify service is not active (failed or inactive is acceptable)
    const state = (await context
        .get()
        .worker.executeCommandInHostOS(
            `systemctl is-active disk-watchdogd || true`,
            link,
        )).trim();
    test.is(state == 'active', false, 'disk-watchdogd should not be active after disable threshold');

    // Verify disabled file exists
    await verifyFileExists(context, link, test, '/mnt/state/disk-watchdog/disabled', 'host');
};

const verify_service_wont_restart = async (context, link, test) => {
    // Ensure disabled marker exists and clear boot history to simulate fresh boots
    await context
        .get()
        .worker.executeCommandInHostOS(
            `sh -lc 'touch /mnt/state/disk-watchdog/disabled && : > /mnt/state/disk-watchdog/boot-history'`,
            link,
        );

    // Attempt to start the service explicitly
    await context
        .get()
        .worker.executeCommandInHostOS(
            `systemctl restart disk-watchdog-boot-history disk-watchdogd || true`,
            link,
        );

    // It should not become active if disabled
    const state = (await context
        .get()
        .worker.executeCommandInHostOS(
            `systemctl is-active disk-watchdogd || true`,
            link,
        )).trim();
    test.is(state == 'active', false, 'disk-watchdogd should not start when disabled file exists');
};

const verify_reboot_with_io_error_disk = async (context, link, test) => {

    // Push service
    const ip = await context.get().worker.ip(link);
    await context
        .get()
        .worker.pushContainerToDUT(ip, __dirname, 'disk-watchdog');
    test.comment('Service pushed');

    // Create device mapper and mount on host
    const deviceName = 'dm-disk-watchdog';
    await createDeviceMapper(context, link, test, deviceName);
    const hostMount = '/mnt/state/io-error-mount';
    await mountDeviceMapper(context, link, test, deviceName, hostMount);

    // Install systemd override on host and restart disk-watchdogd
    test.comment('Installing disk-watchdogd systemd override on host...');
    await modify_disk_watchdogd_systemd(context, link, test);

    // Activate error mode: switch device from linear to error target
    await activate_dm_error(context, link, test, deviceName);

    // Expect device to reboot shortly (watchdog triggers reboot)
    await expectRebootSoon(context, link, test, 120, 2);

    // Verify that boot history is now 2
    test.comment('Verifying boot history is now 2...');
    await verify_boot_count(context, link, test, '2');
};

const cleanup_disk_watchdog_vars = async (context, link, test) => {
    test.comment('Setting up clean test environment...');

    // Remove disabled marker if it exists
    await context
        .get()
        .worker.executeCommandInHostOS(
            `rm -f /mnt/state/disk-watchdog/disabled && : > /mnt/state/disk-watchdog/boot-history`,
            link,
        );
    // Restart services to ensure clean state
    await context
        .get()
        .worker.executeCommandInHostOS(
            `systemctl restart disk-watchdog-boot-history disk-watchdogd || true`,
            link,
        );

    test.comment('Clean test environment ready');
};

const verify_service_enabled_and_active = async (context, link, test) => {
    const enabled = await context
        .get()
        .worker.executeCommandInHostOS(
            `systemctl is-enabled disk-watchdogd || true`,
            link,
        );
    test.is(enabled.trim(), 'enabled', 'disk-watchdogd should be enabled');

    // Retry checking service state in case it's still activating
    let active = '';
    for (let i = 0; i < 10; i++) {
        active = await context
            .get()
            .worker.executeCommandInHostOS(
                `systemctl is-active disk-watchdogd || true`,
                link,
            );
        if (active.trim() === 'active') {
            break;
        }
        await new Promise(r => setTimeout(r, 2000));
    }
    test.is(active.trim(), 'active', 'disk-watchdogd should be active');
};

module.exports = {
    title: 'Disk watchdog test',
    run: async function(test) {
        // Setup clean test environment first, as it might have been tempered by previous tests
        await cleanup_disk_watchdog_vars(this.context, this.link, test);

        // Sanity: service should be enabled and active before inducing failures
        await verify_service_enabled_and_active(this.context, this.link, test);

        test.comment('Verifying boot history is 1 at boot...');
        await verify_boot_count(this.context, this.link, test, '1');

        test.comment('Verifying reboot with I/O error disk...');
        await verify_reboot_with_io_error_disk(this.context, this.link, test);

        test.comment('Verifying service is disabled after 3 boots...');
        await verify_service_disabled(this.context, this.link, test, '3');

        test.comment('Verifying service can\'t be started when it has been disabled...');
        await verify_service_wont_restart(this.context, this.link, test);
    },
};

