#!/bin/sh
set -e

REPO_URL="https://github.com/raspberrypi/rpi-eeprom.git"
CLONE_DIR="/tmp/rpi-eeprom"
OUTPUT_DIR="/firmware"

# Skip clone if firmware is already present (container restart)
if [ -f "${OUTPUT_DIR}/.done" ]; then
    echo "Firmware already available, skipping clone"
    exec "$@"
fi

echo "Sparse-cloning firmware-2711/stable from ${REPO_URL}..."
git clone --filter=blob:none --no-checkout https://github.com/raspberrypi/rpi-eeprom.git
cd rpi-eeprom

git sparse-checkout init --no-cone
# stable is a symlink to latest
git sparse-checkout set firmware-2711/latest

git checkout

echo "Copying firmware binaries to ${OUTPUT_DIR}..."
cp firmware-2711/stable/pieeprom-*.bin "${OUTPUT_DIR}/"

# Clean up clone to save space
rm -rf "${CLONE_DIR}"

# Signal that firmware is ready
touch "${OUTPUT_DIR}/.done"
echo "Firmware ready"

exec "$@"
