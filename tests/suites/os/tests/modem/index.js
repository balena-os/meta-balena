/*
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

const fsPromises = require('fs').promises;
const CONFIG_FILE = `${__dirname}/modems.json`;

const SCAN_ATTEMPTS = 5;
const PING_ATTEMPTS = 3;

module.exports = {
    title: 'Cellular tests',
    run: async function (test) {
        test.comment('starting modem tests...');

        async function getConfig() {
            const data = await fsPromises
                .readFile(CONFIG_FILE)
                .catch((err) => console.error('Failed to read config file', err));

            return JSON.parse(data.toString());
        }

        const config = await getConfig();

        let modemCheck = true;

        // scan for modems that are attached to the device
        await this.utils.waitUntil(async () => {
            const modems = await this.worker.executeCommandInHostOS(
                `mmcli --scan-modems && mmcli --list-modems`,
                this.link,
            );
            test.comment(modems)
            return !modems.includes('No modems were found');
        },
            false,
            SCAN_ATTEMPTS,
            1000
        )
            .catch(() => {
                test.comment(`timeout after ${SCAN_ATTEMPTS} attempts`)
                modemCheck = false;
            });

        test.comment(`modems found? ${modemCheck}`);

        // list modems and extract hardware identity
        const modemStore = (
            await this.worker.executeCommandInHostOS(
                `mmcli --list-modems | awk '{printf "%s ",$NF}' | sed 's/ *$//g'`,
                this.link,
            )
        ).split(' ');

        const testModems = async () => {
            return Promise.all(
                modemStore.map(async (modemType) => {
                    if (config.skip.find((modem) => modem === modemType)) {
                        test.comment(`skipping ${modemType}`);
                        return;
                    }

                    test.comment(`running tests with ${modemType}`);

                    const dbusAddress = await this.worker
                        .executeCommandInHostOS(
                            `mmcli --list-modems -J | jq '."modem-list"'`,
                            this.link,
                        )
                        .then((data) => {
                            return JSON.parse(data);
                        });

                    const hwMap = await Promise.all(
                        dbusAddress.map(async (address) => {
                            const hw = await this.worker.executeCommandInHostOS(
                                `mmcli -m ${address} -J | jq '.modem.generic.model' -r`,
                                this.link,
                            );
                            return { addr: address, hardware: hw };
                        }),
                    );

                    let targetAddress;

                    hwMap.some((modem) => {
                        test.comment(
                            `hardware: ${modem.hardware}, address: ${modem.addr}`,
                        );
                        if (modem.hardware.includes(modemType)) {
                            targetAddress = modem.addr;
                            return true;
                        }
                    });

                    // Check for SIM - and skip the remainder of the test if not present
                    // Contains the following if there is a missing sim:
                    /*
                      Status   |           state: failed
                               |           failed reason: sim-missing
                               |           power state: on
                    */
                    const checkSim = await this.worker.executeCommandInHostOS(
                        `mmcli --modem=${targetAddress}`,
                        this.link,
                    );
                    console.log(checkSim)
                    if (checkSim.includes('sim-missing')){
                        test.comment(`No SIM card detected in modem ${targetAddress} - skipping test`)
                        return true
                    }

                    // enable modem
                    await this.worker.executeCommandInHostOS(
                        `mmcli --modem=${targetAddress} --enable`,
                        this.link,
                    );

                    // attempt to connect modem to network
                    await this.worker.executeCommandInHostOS(
                        `mmcli -m ${targetAddress} --simple-connect='apn=${config.network.apn},ip-type=${config.network.ipType},user=${config.network.user},password=${config.network.password}'`,
                        this.link,
                    );

                    // list modem status
                    const modemData = await this.worker
                        .executeCommandInHostOS(`mmcli -m ${targetAddress} -J`, this.link)
                        .then((data) => {
                            return JSON.parse(data);
                        });

                    test.is(
                        modemData.modem.generic.state,
                        'connected',
                        'check modem is connected to network',
                    );

                    // gather modem bearer info
                    const bearers = await Promise.all(
                        modemData.modem.generic.bearers.map(async (bearer) => {
                            const connected = await this.worker.executeCommandInHostOS(
                                `mmcli -m ${targetAddress} -b ${bearer} -J | jq '.bearer.status.connected' -r`,
                                this.link,
                            );
                            return { bearer: bearer, conn: connected };
                        }),
                    );

                    let targetBearer;

                    // list current bearer
                    bearers.some((bearer) => {
                        test.comment(
                            `connected: ${bearer.conn}, bearer: ${bearer.bearer}`,
                        );
                        if (bearer.conn.includes('yes')) {
                            targetBearer = bearer.bearer;
                            return true;
                        }
                    });

                    // gather ipv4 address
                    const ipAddress = await this.worker.executeCommandInHostOS(
                        `mmcli -m ${targetAddress} -b ${targetBearer} -J | jq '.bearer."ipv4-config".address' -r`,
                        this.link,
                    );

                    // gather cellular network interface
                    const iface = await this.worker.executeCommandInHostOS(
                        `mmcli -m ${targetAddress} -b ${targetBearer} -J | jq '.bearer.status.interface' -r`,
                        this.link,
                    );

                    // set modem target bearer
                    await this.worker.executeCommandInHostOS(
                        `mmcli --modem=${targetAddress} --bearer=${targetBearer}`,
                        this.link,
                    );

                    // bring up cellular network interface
                    await this.worker.executeCommandInHostOS(
                        `ip link set ${iface} up`,
                        this.link,
                    );

                    // add ipv4 address to cellular interface
                    await this.worker.executeCommandInHostOS(
                        `ip addr add ${ipAddress}/32 dev ${iface}`,
                        this.link,
                    );

                    // configure ipv4
                    await this.worker.executeCommandInHostOS(
                        `ip link set dev ${iface} arp off`,
                        this.link,
                    );
                    // configure ipv4 cont.
                    await this.worker.executeCommandInHostOS(
                        `ip route add default dev ${iface} metric 200`,
                        this.link,
                    );

                    test.comment(`signal-quality: ${modemData.modem.generic['signal-quality'].value}, state: ${modemData.modem.generic.state}`)

                    // curl test endpoint over cellular network interface
                    // Using curl to perform a non ICMP ping for compatiblity with GitHub Actions
                    let curl;

                    await this.utils.waitUntil(async () => {
                        curl = await this.worker.executeCommandInHostOS(
                            `curl -I -sS -o /dev/null -w "%{http_code}" --keepalive-time 5 --connect-timeout 5 --interface ${iface} ${config.network.testUrl}`,
                            this.link,
                        );
                        return curl.includes(200);
                    },
                        false,
                        PING_ATTEMPTS,
                        5000
                    )
                        .catch(() => {
                            test.comment(`timeout after ${PING_ATTEMPTS} attempts`)
                        });

                    test.ok(
                        curl.includes(200),
                        `ip address ${config.network.testUrl} should respond over ${iface}`,
                    );

                    test.teardown(async () => {
                        test.comment('Disconnecting the modem');
                        await this.worker.executeCommandInHostOS(
                            `mmcli -m ${targetAddress} --simple-disconnect && mmcli -m ${targetAddress} --disable`,
                            this.link,
                        );

                        await this.worker.executeCommandInHostOS(
                            `route del -net default netmask 0.0.0.0 dev ${iface}`,
                            this.link,
                        );
                    });
                }),
            );
        };

        if (modemCheck) {
            await testModems();
        }
        else {
            test.comment('skipping tests')
        }
    },
};
