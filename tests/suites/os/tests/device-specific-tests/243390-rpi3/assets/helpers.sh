#!/bin/sh

nm_cus_connection="
[connection]
id=hotspot
uuid=60e385b1-6b4f-49be-9fcf-7548b3f4949b
type=wifi
interface-name=wlan1
permissions=

[wifi]
mac-address-blacklist=
mode=ap
ssid=test_cus

[wifi-security]
group=ccmp;
key-mgmt=wpa-psk
pairwise=ccmp;
proto=rsn;
psk=test1234

[ipv4]
dns-search=
method=shared

[ipv6]
addr-gen-mode=stable-privacy
dns-search=
method=ignore
"

nm_eus_connection="
[connection]
id=hotspot
uuid=5169a8ec-2bae-490b-b091-d7163c10e30f
type=wifi
interface-name=wlan1
permissions=

[wifi]
band=bg
channel=6
driver=nl80211
beacon_int=100
cloned-mac-address=permanent
powersave=2
mac-address-randomization=1
mac-address-blacklist=
mode=ap
ssid=test_eus

[wifi-security]
auth-alg=open
group=ccmp;
key-mgmt=wpa-psk
pairwise=ccmp;
proto=rsn
psk=Test123456

[ipv4]
address1=10.11.0.1/24,10.11.0.1
dns-search=
method=manual

[ipv6]
addr-gen-mode=stable-privacy
dns-search=
method=ignore
"

CUS_ADAPTER="0bda:8176"
EUS_ADAPTER="0bda:8179"
get_adapter() {
	if lsusb | grep -q "${CUS_ADAPTER}" ; then
		echo "cus"
	elif lsusb | grep -q "${EUS_ADAPTER}" ; then
		echo "eus";
	else
		echo "unknown";
	fi;
}

wifi_adapter=$(get_adapter)

cleanup_hotspot_connections() {
	rm -rf /mnt/boot/system-connections/*hotspot* || true
	rm -rf /etc/NetworkManager/system-connections/*hotspot* || true
}

add_hotspot_connection() {
	cleanup_hotspot_connections

	connection_file="/mnt/boot/system-connections/nm-${wifi_adapter}-hotspot.conf"
	declare -n connection_contents="nm_${wifi_adapter}_connection"
	echo "$connection_contents" > ${connection_file}
	if [[ -f "${connection_file}" ]]; then echo "added"; else echo "failed"; fi;
}

test_hotspot() {
	case ${wifi_adapter} in
		eus)
			;&
		cus)
			if nmcli dev wifi list ifname wlan0 | grep -q "test_${wifi_adapter}" ; then echo "passed"; else echo "failed"; fi
			;;
		*)
			echo "unsupported or no adapter connected - failed"
	esac
}

# wlan0 should always correspond to the internal wifi, while
# wlan1 should always correspond to the usb adapter.
test_interface_naming() {
	if udevadm info -a /sys/class/net/wlan0 | grep -q brcmfmac ; then
		case ${wifi_adapter} in
			cus)
				if udevadm info -a /sys/class/net/wlan1 | grep -q rtl8192 ; then echo "passed"; else echo "failed"; fi
				;;
			eus)
				if udevadm info -a /sys/class/net/wlan1 | grep -q rtl8188 ; then echo "passed"; else echo "failed"; fi
				;;
			*)
				echo "unsupported or no adapter connected - failed"
		esac
	else
		echo "failed"
	fi;
}
