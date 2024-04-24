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

module.exports = {
    title: 'Internet connection sharing tests',
    tests: [
        {
            title: 'Internet sharing iptables rules test',
            run: async function(test) {
                // Test for the NetworkManager patch done in
                // https://github.com/balena-os/meta-balena/pull/2963
                //
                // A racing condition between balenaEngine and NetworkManager led to
                // some Internet connection sharing iptables rules not being applied
                // when NM connection profile with Internet sharing was activated at boot.
                //
                // This test checks whether all necessary iptables rules are added by
                // artificially blocking iptables for 1 second and then for 3 seconds
                // while a connection profile with Internet sharing is activated.
                //
                // The patch for NetworkManager ported from upstream adds 2 seconds wait
                // for the iptables lock to be released. Previously it failed immediately
                // if the lock was held. Thus we test first with 1 second (< 2 secs) and
                // all rules are added, and then we test with 3 seconds (> 2 secs), which
                // will make one rule to not be added - that is the racing condition will
                // be met. If the wait is for 5 seconds, two rules would fail and so on.

                // Counts all iptables rules set for Internet sharing by NM
                async function countSharedIptables(that) {
                    // Executes a command that returns an integer
                    async function execInt(command, that) {
                        const output = await that.worker.executeCommandInHostOS(
                            command,
                            that.link
                        );
                        return parseInt(output);
                    }

                    let count = await execInt(
                        'iptables -S | grep -c nm-shared-dummy0 || true',
                        that,
                    );
                    count += await execInt(
                        'iptables -S -t nat | grep -c nm-shared-dummy0 || true',
                        that,
                    );
                    count += await execInt(
                        'iptables -S nm-sh-fw-dummy0 | wc -l',
                        that,
                    );
                    count += await execInt(
                        'iptables -S nm-sh-in-dummy0 | wc -l',
                        that,
                    );

                    return count;
                }

                // Create a dummy NM connection with Internet sharing enabled. 
                // Assigned 10.42.1.1/32 as unused by qemu and testbot - so no ip conflicts 
                await this.worker.executeCommandInHostOS(
                    `nmcli c add type dummy ifname dummy0 con-name dummy \
                    autoconnect no ipv4.method shared ipv6.method disabled ipv4.addresses "10.42.1.1/32"`,
                    this.link,
                );

                // Lock iptables for 1 second and activate the connection with sharing
                // enabled in parallel. NM waits for 2 seconds for the lock to be released
                // and at the end of the one second artificial lock it will be able to 
                // set successfully all iptables rules. Previously that would fail.
                await this.worker.executeCommandInHostOS(
                    'flock /run/xtables.lock sleep 1 & nmcli c up dummy & wait',
                    this.link
                );
                
                // Check more than once that all iptables rules are set - some device types it takes longer
                // for them to appear, and having a single check can lead to a false negative
				await this.utils.waitUntil(async () => {
                    test.comment(`Checking iptables rules are set`);
					return (await countSharedIptables(this) === 14);
				}, false, 5, 1000);
                // if we fail to see the approprate number of iptables rules the above will fail, and cause the tests to fail
                test.pass('Internet sharing iptables rules are all set');

                // Now deactivate the connection - all iptables rules should be deleted.
                await this.worker.executeCommandInHostOS(
                    'nmcli c down dummy',
                    this.link
                );
                let count = await countSharedIptables(this);
                test.equal(count, 0, 'All Internet sharing iptables rules are deleted');

                // Cleanup
                await this.worker.executeCommandInHostOS(
                    'nmcli c delete dummy',
                    this.link
                );
            },
        },
    ],
};
