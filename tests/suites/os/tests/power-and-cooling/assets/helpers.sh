#!/bin/sh

TARGET_POWER_MODE="0"
CONFIG_JSON="/mnt/boot/config.json"

target_fan_profile="quiet"

get_power_mode_index() {
    applied_power_mode=$(/usr/sbin/nvpmodel -q)
    if [[ "$applied_power_mode" == null ]] || [[ -z "$applied_power_mode" ]]; then
        echo "failed"
    else
        power_mode_index=$(echo "${applied_power_mode}" | sed -n 2p)
        echo "$power_mode_index"
    fi

}

get_fan_profile() {
    running_profile=$(/usr/sbin/nvfancontrol -q | grep FAN_PROFILE | cut -d ":" -f3)
    if [[ "$running_profile" == null ]] || [[ -z "$running_profile" ]]; then
        echo "failed"
    else
        echo "$running_profile"
    fi
}

set_power_mode() {
    tmp=$(mktemp)
    jq --arg TARGET_POWER_MODE $TARGET_POWER_MODE '.os.power.mode |= $TARGET_POWER_MODE' $CONFIG_JSON > ${tmp}
    mv ${tmp} ${CONFIG_JSON}

    added_mode=$(jq -c -M -e '.os.power.mode' $CONFIG_JSON)
    if [[ "$added_mode" == "\"0\"" ]]; then
        echo "set"
    fi
}

set_fan_profile() {
    tmp=$(mktemp)
    jq --arg target_fan_profile $target_fan_profile '.os.fan.profile |= $target_fan_profile' $CONFIG_JSON > ${tmp}
    mv ${tmp} ${CONFIG_JSON}
}

test_fan_profile() {
    current_fan_profile=$(get_fan_profile)
    if [[ "$current_fan_profile" == "$target_fan_profile" ]]; then
        target_fan_profile="cool"
    fi

    set_fan_profile
    sleep 5
    applied_fan_profile=$(get_fan_profile)
    if [[ "$applied_fan_profile" == "$target_fan_profile" ]]; then
        echo "passed"
    else
        echo "failed"
    fi
}

test_power_mode() {
    current_power_mode=$(get_power_mode_index)
    if [[ "$current_power_mode" == "$TARGET_POWER_MODE" ]]; then
        echo "passed"
    else
        echo "failed"
    fi
}
