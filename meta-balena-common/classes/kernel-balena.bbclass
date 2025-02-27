#
# In order to be able to configure kernel in a specific way for all the resin
# platforms, we define three tasks and inject them in between configure and
# compile tasks.
#
#        *
#        |
#  +-----v------+
#  |do_configure|
#  +-----+------+
#        |
#        <-----------------------------+
#        |                             |
#        +-----------------------+     | depends
#        |                       |     |
#        |         +-------------v-----+--------+
#        |         |do_kernel_resin_injectconfig|
#        |         +-------------+-----^--------+
#        |                       |     | depends
# ++-----v-----++  +-------------+-----+--------+
# |>other tasks<|  |do_kernel_resin_reconfigure |
# ++-----+-----++  +-------------+-----^--------+
#        |                       |     | depends
#        |         +-------------+-----+--------+
#        |         |do_kernel_resin_checkconfig |
#        |         +-------------+-----^--------+
#        |                       |     |
#        <-----------------------+     | depends
#        |                             |
#        |                             |
#        |                             |
#   +----v-----+                       |
#   |do_compile+-----------------------+
#   +----+-----+
#        |
#        v
#        *
#
#   This flow exdends a kernel recipe with the ability to:
#       a) Inject a specific kernel configuration
#       b) Reconfigure kernel
#       c) Check that the defined/requested configuration was actually
#          activated by the kernel reconfiguration mechanism
#
#   The Resin specific kernel configuration can be done in two different ways:
#   1. Defining configuration blocks and activating the specific flag
#       a) Define a new kernel configuration block using
#          BALENA_CONFIGS[mynewconfigblock].
#       b) [optional] Define a kernel configuration block which is a dependency
#          for BALENA_CONFIGS[mynewconfigblock] using
#          BALENA_CONFIGS_DEPS[mynewconfigblock]. This block won't be checked at
#          do_kernel_resin_checkconfig but will be configured before the configs
#          in BALENA_CONFIGS[mynewconfigblock].
#       c) Activate the new block appending the config block name to
#          BALENA_CONFIGS.
#          Ex: BALENA_CONFIGS:append = " mynewconfigblock"
#          Mind the space!
#   2. Using a special filename defined as BALENA_DEFCONFIG_NAME
#       a) [optional] Define BALENA_DEFCONFIG_NAME. Default: "resin-defconfig"
#       b) Add BALENA_DEFCONFIG_NAME to SRC_URI.

inherit kernel-balena-noimage sign-efi sign-gpg

BALENA_DEFCONFIG_NAME ?= "resin-defconfig"

def get_kernel_version(d):
    import os, re
    kernelsource = d.getVar('S', True)

    # get the kernel version from the top Makefile in the kernel source tree
    topmakefile = kernelsource + "/Makefile"
    if not os.path.exists(topmakefile):
        return None
    with open(topmakefile, 'r') as makefile:
        lines = makefile.readlines()

    kernelversion = ""
    for s in lines:
        m = re.match(r"VERSION = (\d+)", s)
        if m:
            kernelversion = kernelversion + m.group(1)
        m = re.match(r"PATCHLEVEL = (\d+)", s)
        if m:
            kernelversion = kernelversion + '.' + m.group(1)
        m = re.match(r"SUBLEVEL = (\d+)", s)
        if m:
            kernelversion = kernelversion + '.' + m.group(1)
        m = re.match(r"EXTRAVERSION = (\d+)", s)
        if m:
            kernelversion = kernelversion + '.' + m.group(1)
    return kernelversion

# Return passed value if the kernel version is equal or above the one provided
def configure_from_version(version, passvalue, failvalue, d):
    kv = get_kernel_version(d)
    if kv is None:
        return failvalue
    kv_major = kv.split('.')[0]
    kv_minor = kv.split('.')[1]
    major =  version.split('.')[0]
    minor = version.split('.')[1]
    if int(kv_major) > int(major):
        return passvalue
    elif int(kv_major) == int(major):
        if int(kv_minor) >= int(minor):
            return passvalue
    return failvalue

BALENA_CONFIGS ?= " \
    ad5446 \
    balena \
    brcmfmac \
    cdc-acm \
    ralink \
    rtl8192cu \
    r8188eu \
    systemd \
    leds-gpio \
    proc-config \
    no-logo \
    hid-multitouch \
    ip6tables_nat \
    ip_set \
    seccomp \
    wd-nowayout \
    wd \
    xtables \
    audit \
    governor \
    mbim \
    qmi \
    misc \
    panic \
    redsocks \
    reduce-size \
    security \
    usb-serial \
    zram \
    ${BALENA_STORAGE} \
    fatfs \
    nfsfs \
    apple_hfs \
    nf_tables \
    dummy \
    uinput \
    no-debug-info \
    uprobes \
    task-accounting \
    ipv6_mroute \
    disable_hung_panic \
    ${RAID} \
    no_gcc_plugins \
    ${FIRMWARE_COMPRESS} \
    ${MODULE_COMPRESS} \
    ${WIREGUARD} \
    "

#
# Balena specific kernel configuration
# Keep these updated with
# https://raw.githubusercontent.com/balena-os/balena-engine/master/contrib/check-config.sh
#
# False negatives:
#
# CONFIG_NF_NAT_NEEDED was removed in v5.2 (sha1 f319ca6557c10a711facc4dd60197470796d3ec1)
# CONFIG_NF_NAT_IPV4 was merged with NF_NAT in v5.1 (sha1 3bf195ae6037e310d693ff3313401cfaf1261b71)
#
BALENA_CONFIGS_DEPS[balena] ?= " \
    CONFIG_IP_NF_NAT=y \
    CONFIG_IPV6=y \
    CONFIG_IP_NF_IPTABLES=y \
    CONFIG_NF_CONNTRACK=y \
    CONFIG_NF_CONNTRACK_IPV4=y \
    CONFIG_NETFILTER=y \
    CONFIG_IP_VS=y \
    CONFIG_NETFILTER_XT_MATCH_IPVS=y \
    CONFIG_NF_NAT_NEEDED=y \
    CONFIG_DEVPTS_MULTIPLE_INSTANCES=y \
    CONFIG_NF_NAT_IPV4=y \
    "
BALENA_CONFIGS[balena] ?= " \
    CONFIG_ADVISE_SYSCALLS=y \
    CONFIG_MEMCG=y \
    CONFIG_NAMESPACES=y \
    CONFIG_NET_NS=y \
    CONFIG_PID_NS=y \
    CONFIG_IPC_NS=y \
    CONFIG_UTS_NS=y \
    CONFIG_USER_NS=y \
    CONFIG_CGROUPS=y \
    CONFIG_CGROUP_CPUACCT=y \
    CONFIG_CGROUP_DEVICE=y \
    CONFIG_CGROUP_FREEZER=y \
    CONFIG_CGROUP_SCHED=y \
    CONFIG_CPUSETS=y \
    CONFIG_MACVLAN=y \
    CONFIG_VETH=y \
    CONFIG_BRIDGE=y \
    CONFIG_IP_NF_FILTER=y \
    CONFIG_IP6_NF_FILTER=m \
    CONFIG_IP_NF_TARGET_REJECT=m \
    CONFIG_IP6_NF_TARGET_REJECT=m \
    CONFIG_IP_NF_TARGET_MASQUERADE=m \
    CONFIG_IP6_NF_TARGET_MASQUERADE=m \
    CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y \
    CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y \
    CONFIG_NETFILTER_XT_MATCH_COMMENT=y \
    CONFIG_NF_NAT=y \
    CONFIG_POSIX_MQUEUE=y \
    CONFIG_TUN=y \
    CONFIG_EXT4_FS=y \
    CONFIG_EXT4_FS_POSIX_ACL=y \
    CONFIG_EXT4_FS_SECURITY=y \
    CONFIG_KEYS=y \
    CONFIG_MEMCG=y \
    CONFIG_OVERLAY_FS=y \
    "


BALENA_CONFIGS:append = " ${@configure_from_version("6.1", "", " memcfg_swap", d)}"
BALENA_CONFIGS[memcfg_swap] = "CONFIG_MEMCG_SWAP=y"
FIRMWARE_COMPRESS = "${@configure_from_version("5.3", "firmware_compress", "", d)}"
BALENA_CONFIGS[firmware_compress] = " \
    CONFIG_FW_LOADER_COMPRESS=y \
"

MODULE_COMPRESS = "${@configure_from_version("5.13", "module_compress", "", d)}"
BALENA_CONFIGS[module_compress] = " \
    CONFIG_MODULE_COMPRESS_ZSTD=y \
"

WIREGUARD = "${@configure_from_version("5.10", "wireguard", "", d)}"
BALENA_CONFIGS[wireguard] = " \
    CONFIG_WIREGUARD=m \
"

KERNEL_ZSTD = "${@configure_from_version("5.9", "kernel_zstd", "", d)}"
BALENA_CONFIGS:append = "${@bb.utils.contains('MACHINE_FEATURES','efi'," ${KERNEL_ZSTD}",'',d)}"
BALENA_CONFIGS[kernel_zstd] = " \
    CONFIG_KERNEL_ZSTD=y \
    CONFIG_CRYPTO_ZSTD=y \
"

BALENA_CONFIGS[aufs] = " \
    CONFIG_AUFS_FS=y \
    CONFIG_AUFS_XATTR=y \
    "

BALENA_CONFIGS[apple_hfs] = " \
    CONFIG_HFS_FS=m \
    CONFIG_HFSPLUS_FS=m \
    "

BALENA_CONFIGS[nfsfs] = " \
    CONFIG_NFS_FS=m \
    CONFIG_NFS_V2=m \
    CONFIG_NFS_V3=m \
    CONFIG_NFS_V4=m \
    CONFIG_NFSD=m \
    CONFIG_NFSD_V4=y \
"

BALENA_CONFIGS:append = " ${@configure_from_version("5.18", "", " nfsd_v3", d)}"
BALENA_CONFIGS[nfsd_v3] = "CONFIG_NFSD_V3=y"
#
# systemd specific kernel configuration options
# see https://github.com/systemd/systemd/blob/master/README for an up-to-date list
#
BALENA_CONFIGS_DEPS[systemd] ?= " \
    CONFIG_DMIID=y \
    CONFIG_DEVPTS_MULTIPLE_INSTANCES=y \
    "
BALENA_CONFIGS[systemd] ?= " \
    CONFIG_DEVTMPFS=y \
    CONFIG_CGROUPS=y \
    CONFIG_INOTIFY_USER=y \
    CONFIG_SIGNALFD=y \
    CONFIG_TIMERFD=y \
    CONFIG_EPOLL=y \
    CONFIG_NET=y \
    CONFIG_SYSFS=y \
    CONFIG_PROC_FS=y \
    CONFIG_FHANDLE=y \
    CONFIG_SYSFS_DEPRECATED=n \
    CONFIG_UEVENT_HELPER=n \
    CONFIG_FW_LOADER_USER_HELPER=n \
    CONFIG_FW_LOADER_USER_HELPER_FALLBACK=n \
    CONFIG_BLK_DEV_BSG=y \
    CONFIG_NET_NS=y \
    CONFIG_IPV6=y \
    CONFIG_AUTOFS4_FS=y \
    CONFIG_TMPFS_POSIX_ACL=y \
    CONFIG_TMPFS_XATTR=y \
    CONFIG_SECCOMP=y \
    CONFIG_CGROUP_SCHED=y \
    CONFIG_FAIR_GROUP_SCHED=y \
    CONFIG_CFS_BANDWIDTH=y"

#
# We use an out-of-tree kernel module for RTL8192CU WiFi devices
# Deactivate in-tree driver and add all the dependencies of the out-of-the tree
# one
#
BALENA_CONFIGS[rtl8192cu] ?= "\
    CONFIG_RTL8192CU=n \
    CONFIG_HOSTAP=m \
    CONFIG_WIRELESS=y \
    CONFIG_USB=y \
    CONFIG_MAC80211=m \
    CONFIG_CFG80211=m \
    CONFIG_CFG80211_WEXT=y \
    CONFIG_WIRELESS_EXT=y \
    CONFIG_WEXT_PRIV=y \
    "

# Activate R8188EU driver
BALENA_CONFIGS_DEPS[r8188eu] ?= "\
    CONFIG_STAGING=y \
    "
BALENA_CONFIGS[r8188eu] ?= "\
    CONFIG_R8188EU=m \
    "

BALENA_CONFIGS:append = " ${@configure_from_version("5.16", "", " 88eu_ap_mode", d)}"
BALENA_CONFIGS[88eu_ap_mode] = "CONFIG_88EU_AP_MODE=y"

# rt53xx wireless chipset family to the rt2800usb driver.
# Supported chips: RT5370 RT5572
BALENA_CONFIGS_DEPS[ralink] ?= "\
    CONFIG_CFG80211=m \
    CONFIG_MAC80211=m \
    CONFIG_RT2X00=m \
    CONFIG_RT2800USB=m \
    "
BALENA_CONFIGS[ralink] ?= "\
    CONFIG_RT2800USB_RT53XX=y \
    CONFIG_RT2800USB_RT55XX=y \
    "

#
# Official RPI WiFi adapter
# http://thepihut.com/collections/new-products/products/official-raspberry-pi-wifi-adapter
#
BALENA_CONFIGS_DEPS[brcmfmac] ?= " \
    CONFIG_CFG80211=m \
    CONFIG_BRCMFMAC_USB=y \
    "
BALENA_CONFIGS[brcmfmac] ?= " \
    CONFIG_BRCMFMAC=m \
    "

#
# Most of the resin supported boards have user controllable LEDs
#
BALENA_CONFIGS_DEPS[leds-gpio] ?= " \
    CONFIG_NEW_LEDS=y \
    CONFIG_LEDS_CLASS=y \
    CONFIG_GPIOLIB=y \
    "
BALENA_CONFIGS[leds-gpio] ?= " \
    CONFIG_LEDS_GPIO=y \
    "

#
# Expose kernel config via procfs
#
BALENA_CONFIGS_DEPS[proc-config] ?= " \
    CONFIG_IKCONFIG=y \
    CONFIG_PROC_FS=y \
    CONFIG_EXPERT=y \
    "
BALENA_CONFIGS[proc-config] ?= " \
    CONFIG_IKCONFIG_PROC=y \
    "

#
# For a flawless boot experience deactivate logo - we have splash screen providers
#
BALENA_CONFIGS[no-logo] ?= " \
    CONFIG_LOGO=n \
    "

#
# Compress Kernel modules
#
BALENA_CONFIGS[compress-kmodules] ?= " \
    CONFIG_MODULE_COMPRESS=y \
    CONFIG_MODULE_COMPRESS_GZIP=y \
    "

#
# Do not include debugging info in kernel and modules
#
BALENA_CONFIGS[no-debug-info] ?= " \
    CONFIG_DEBUG_INFO=n \
    "

#
# Support for touchscreens using generic multitouch driver
#
BALENA_CONFIGS_DEPS[hid-multitouch] ?= " \
    CONFIG_INPUT=y \
    CONFIG_HID=y \
    "
BALENA_CONFIGS[hid-multitouch] ?= " \
    CONFIG_HID_MULTITOUCH=m \
    CONFIG_HIDRAW=y \
    "

BALENA_CONFIGS[ip_set] = " \
    CONFIG_IP_SET=m \
    CONFIG_IP_SET_BITMAP_IP=m \
    CONFIG_IP_SET_BITMAP_IPMAC=m \
    CONFIG_IP_SET_BITMAP_PORT=m \
    CONFIG_IP_SET_HASH_IP=m \
    CONFIG_IP_SET_HASH_IPPORT=m \
    CONFIG_IP_SET_HASH_IPPORTIP=m \
    CONFIG_IP_SET_HASH_IPPORTNET=m \
    CONFIG_IP_SET_HASH_NET=m \
    CONFIG_IP_SET_HASH_NETIFACE=m \
    CONFIG_IP_SET_HASH_NETPORT=m \
    CONFIG_IP_SET_LIST_SET=m \
    "

# enable ip6table_nat and nf_nat_ipv6 as modules (we only add CONFIG_IP6_NF_NAT here as that will also bring in CONFIG_NF_NAT_IPV6)

BALENA_CONFIGS_DEPS[ip6tables_nat] = " \
    CONFIG_NF_CONNTRACK_IPV6=m \
    CONFIG_IP6_NF_IPTABLES=m \
    "
BALENA_CONFIGS[ip6tables_nat] = " \
    CONFIG_IP6_NF_NAT=m \
    "

BALENA_CONFIGS[ipv6_mroute] = " \
    CONFIG_IPV6_MROUTE=y \
    CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y \
    "

BALENA_CONFIGS[seccomp] = " \
    CONFIG_SECCOMP=y \
    "

#
# The flasher images relies on shutdown at the end of the flashing process.
# Having no way out we might end up rebooting the board before shutdown because
# systemd is disabling watchdog before killing the other processes which might
# take more than the watchdog timer.
#
BALENA_CONFIGS[wd-nowayout] = " \
    CONFIG_WATCHDOG_NOWAYOUT=n \
    "

BALENA_CONFIGS[wd] = " \
    CONFIG_WATCHDOG_SYSFS=y \
    "

BALENA_CONFIGS_DEPS[xtables] = " \
    CONFIG_NETFILTER_ADVANCED=m \
    CONFIG_IP_SET=m \
    "

BALENA_CONFIGS[xtables] = " \
    CONFIG_NETFILTER_XT_SET=m \
    "

# Deactivate the audit susbsystem and the audit syscall
BALENA_CONFIGS_DEPS[audit] = " \
    CONFIG_HAVE_AUDITSYSCALL=n \
    "

BALENA_CONFIGS[audit] = " \
    CONFIG_AUDIT=n \
    CONFIG_AUDITSYSCALL=n \
    "

BALENA_CONFIGS_DEPS[governor] ?= " \
    CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y \
    "

# support for mbim cell modems
BALENA_CONFIGS_DEPS[mbim] = " \
    CONFIG_USB_NET_DRIVERS=m \
    CONFIG_USB_USBNET=m \
"

BALENA_CONFIGS[mbim] = " \
    CONFIG_USB_NET_CDC_MBIM=m \
    "

# support for qmi cell modems
BALENA_CONFIGS_DEPS[qmi] = " \
    CONFIG_USB_NET_DRIVERS=m \
    CONFIG_USB_USBNET=m \
"

BALENA_CONFIGS[qmi] = " \
    CONFIG_USB_NET_QMI_WWAN=m \
    "

# various other configurations
BALENA_CONFIGS[misc] = " \
    CONFIG_USB_SERIAL_CP210X=m \
    CONFIG_DEBUG_FS=y \
    "

# IP_NF_TARGET_LOG is replaced by NETFILTER_XT_TARGET_LOG from v3.10 (see sha1 6939c33a757bd006c5e0b8b5fd429fc587a4d0f4)
# NF_NAT_REDIRECT is a dependency for other modules so it is selected automatically
BALENA_CONFIGS_DEPS[misc] = " \
    CONFIG_IP_NF_TARGET_LOG=m \
    CONFIG_NETFILTER_XT_TARGET_LOG=m \
    CONFIG_NF_NAT_REDIRECT=m \
"

# Reset on oops
BALENA_CONFIGS[panic] = " \
    CONFIG_PANIC_ON_OOPS=y \
    CONFIG_PANIC_TIMEOUT=1 \
"

# configs needed for our usage of redsocks
BALENA_CONFIGS[redsocks] = " \
    CONFIG_NETFILTER_ADVANCED=y \
    CONFIG_NETFILTER_XT_MATCH_OWNER=m \
    CONFIG_NETFILTER_XT_TARGET_REDIRECT=m \
    "

# disable some large and commonly enabled configs to reduce image size
BALENA_CONFIGS[reduce-size] = " \
    CONFIG_OCFS2_FS=n \
    CONFIG_GFS2_FS=n \
    CONFIG_REISERFS_FS=n \
    CONFIG_NTFS_FS=n \
    CONFIG_JFS_FS=n \
    CONFIG_HFS_FS=n \
    CONFIG_HFSPLUS_FS=n \
    CONFIG_UDF_FS=n \
    CONFIG_BLK_DEV_DRBD=n \
    CONFIG_XFS_FS=n \
    "

# security features
# From v4.18 these are renamed and are automatically selected with the architecture (sha1 d148eac0e70f06485dbd4cce6ed01cb07c650cec)
BALENA_CONFIGS_DEPS[security] = " \
    CONFIG_CC_STACKPROTECTOR=y \
    CONFIG_CC_STACKPROTECTOR_STRONG=y \
    "

# zram provides a compressed in-memory swap device
BALENA_CONFIGS[zram] = " \
    CONFIG_ZSMALLOC=y \
    CONFIG_ZRAM=y \
    CONFIG_CRYPTO=y \
    CONFIG_CRYPTO_LZ4=y \
    "

BALENA_CONFIGS:append = " ${@configure_from_version("6.12", " zram_backend_lz4", "", d)}"
BALENA_CONFIGS[zram_backend_lz4] = "CONFIG_ZRAM_BACKEND_LZ4=y"

# Kernel versions between 4.0 and 4.9
# need this for lz4 support
BALENA_CONFIGS_DEPS[zram] = " \
    CONFIG_ZRAM_LZ4_COMPRESS=y \
"

# USB Modem (CDC ACM) support
BALENA_CONFIGS[cdc-acm] = " \
    CONFIG_USB_ACM=m \
    "

# USB serial device drivers
BALENA_CONFIGS_DEPS[usb-serial] = " \
    CONFIG_USB_SERIAL_WWAN=m \
    "
BALENA_CONFIGS[usb-serial] = " \
    CONFIG_USB_SERIAL=y \
    CONFIG_USB_SERIAL_GENERIC=y \
    CONFIG_USB_SERIAL_OPTION=m \
    CONFIG_USB_SERIAL_QUALCOMM=m \
    CONFIG_USB_SERIAL_CH341=m \
    CONFIG_USB_SERIAL_FTDI_SIO=m \
    CONFIG_USB_SERIAL_PL2303=m \
    "

BALENA_CONFIGS[fatfs] = " \
    CONFIG_MSDOS_FS=y \
    CONFIG_VFAT_FS=y \
    CONFIG_NLS_ASCII=y \
    CONFIG_NLS_CODEPAGE_437=y \
    "

BALENA_CONFIGS[nf_tables] = " \
    CONFIG_NF_TABLES=m \
    CONFIG_NF_TABLES_INET=y \
    CONFIG_NF_TABLES_NETDEV=y \
    CONFIG_NFT_NUMGEN=m \
    CONFIG_NFT_CT=m \
    CONFIG_NFT_CONNLIMIT=m \
    CONFIG_NFT_LOG=m \
    CONFIG_NFT_LIMIT=m \
    CONFIG_NFT_MASQ=m \
    CONFIG_NFT_REDIR=m \
    CONFIG_NFT_NAT=m \
    CONFIG_NFT_TUNNEL=m \
    CONFIG_NFT_OBJREF=m \
    CONFIG_NFT_QUOTA=m \
    CONFIG_NFT_REJECT=m \
    CONFIG_NFT_REJECT_INET=m \
    CONFIG_NFT_COMPAT=m \
    CONFIG_NFT_HASH=m \
    CONFIG_NFT_FIB=m \
    CONFIG_NFT_FIB_INET=m \
    CONFIG_NFT_SOCKET=m \
    CONFIG_NFT_OSF=m \
    CONFIG_NFT_TPROXY=m \
    CONFIG_NF_DUP_NETDEV=m \
    CONFIG_NFT_DUP_NETDEV=m \
    CONFIG_NFT_FWD_NETDEV=m \
    CONFIG_NFT_FIB_NETDEV=m \
    CONFIG_NF_SOCKET_IPV4=m \
    CONFIG_NF_TPROXY_IPV4=m \
    CONFIG_NF_TABLES_IPV4=y \
    CONFIG_NFT_REJECT_IPV4=m \
    CONFIG_NFT_DUP_IPV4=m \
    CONFIG_NFT_FIB_IPV4=m \
    CONFIG_NF_TABLES_ARP=y \
    CONFIG_NF_DUP_IPV4=m \
    CONFIG_NF_SOCKET_IPV6=m \
    CONFIG_NF_TPROXY_IPV6=m \
    CONFIG_NF_TABLES_IPV6=y \
    CONFIG_NFT_REJECT_IPV6=m \
    CONFIG_NFT_DUP_IPV6=m \
    CONFIG_NFT_FIB_IPV6=m \
    CONFIG_NF_DUP_IPV6=m \
    "
BALENA_CONFIGS:append = " ${@configure_from_version("5.10", "", " nf_tables_set", d)}"
BALENA_CONFIGS[nf_tables_set] = "CONFIG_NF_TABLES_SET=m"

BALENA_CONFIGS:append = " ${@configure_from_version("5.17", "", " nft_counter", d)}"
BALENA_CONFIGS[nft_counter] = "CONFIG_NFT_COUNTER=m"

BALENA_CONFIGS[task-accounting] = " \
    CONFIG_TASKSTATS=y \
    CONFIG_TASK_DELAY_ACCT=y \
    CONFIG_TASK_IO_ACCOUNTING=y \
    "

# This adds support for creating
# dummy net devices
BALENA_CONFIGS[dummy] = " \
    CONFIG_DUMMY=m \
    "

# enable uinput kernel module
BALENA_CONFIGS[uinput] = " \
    CONFIG_INPUT_UINPUT=m \
    "

# enable Analog Devices AD5446 and similar single channel DACs driver
BALENA_CONFIGS[ad5446] = " \
    CONFIG_AD5446=m \
"

BALENA_CONFIGS_DEPS[uprobes] = " \
    CONFIG_FTRACE=y \
"

# enable user space probes support
BALENA_CONFIGS[uprobes] = " \
    CONFIG_UPROBE_EVENTS=y \
"

BALENA_CONFIGS[disable_hung_panic] = " \
    CONFIG_BOOTPARAM_HUNG_TASK_PANIC=n \
    "

BALENA_CONFIGS[no_gcc_plugins] = " \
    CONFIG_GCC_PLUGINS=n \
"

# enable rootfs on RAID1
RAID = "${@bb.utils.contains('MACHINE_FEATURES','raid','mdraid','',d)}"
BALENA_CONFIGS[mdraid] = " \
    CONFIG_MD=y \
    CONFIG_BLK_DEV_MD=y \
    CONFIG_MD_RAID1=y \
    CONFIG_MD_AUTODETECT=y \
"

# Enable dmcrypt/LUKS
BALENA_CONFIGS:append = "${@oe.utils.conditional('SIGN_API','','',' dmcrypt',d)}"
BALENA_CONFIGS_DEPS[dmcrypt] = " \
    CONFIG_BLK_DEV_DM=y \
"
BALENA_CONFIGS[dmcrypt] = " \
    CONFIG_CRYPTO_XTS=y \
    CONFIG_DM_CRYPT=y \
"

BALENA_CONFIGS[kexec] = " \
    CONFIG_KEXEC=y \
    CONFIG_KEXEC_FILE=y \
    CONFIG_KEXEC_SIG=y \
"
BALENA_CONFIGS:append = "${@bb.utils.contains('MACHINE_FEATURES','efi',' kexec','',d)}"

BALENA_CONFIGS:append = "${@oe.utils.conditional('SIGN_API','','',' secureboot',d)}"
BALENA_CONFIGS_DEPS[secureboot] = " \
    CONFIG_INTEGRITY_SIGNATURE=y \
    CONFIG_INTEGRITY_ASYMMETRIC_KEYS=y \
    CONFIG_SYSTEM_BLACKLIST_KEYRING=y \
"
BALENA_CONFIGS[secureboot] = " \
    CONFIG_INTEGRITY_PLATFORM_KEYRING=y \
    CONFIG_MODULE_SIG=y \
    CONFIG_MODULE_SIG_ALL=y \
    CONFIG_MODULE_SIG_SHA512=y \
    CONFIG_SECURITY_LOCKDOWN_LSM=y \
    CONFIG_SECURITY_LOCKDOWN_LSM_EARLY=y \
    CONFIG_SYSTEM_TRUSTED_KEYS="certs/kmod.crt" \
"
BALENA_CONFIGS[efi-secureboot] = " \
    CONFIG_LOAD_UEFI_KEYS=y \
    CONFIG_KEXEC_SIG_FORCE=y \
    CONFIG_KEXEC_BZIMAGE_VERIFY_SIG=y \
"
BALENA_CONFIGS:append = "${@bb.utils.contains('MACHINE_FEATURES','efi',' efi-secureboot','',d)}"

###########
# HELPERS #
###########

# Returns a set of all activated configs in srcpath
def getKernelSetConfigs(srcpath):
    import os.path
    allSetConfigs = set()
    if os.path.isfile(srcpath):
        with open(srcpath, 'r') as f:
            lines = f.readlines();
            for line in lines:
                if not line.startswith('#'):
                    allSetConfigs.add(line.strip())
    return allSetConfigs

# Appends a line to a file
def appendLineToFile (filepath, line):
    import os.path
    if os.path.isfile(filepath):
        with open(filepath, 'a') as f:
            f.write(line.strip()+'\n')

#########
# TASKS #
#########

#
# Configuration for balena storage
#

def aufs_kernel_select(kernelversion):
    import collections
    # define an ordered dictionary with aufs branch names as keys and branch revisions as values
    aufsdict = collections.OrderedDict([
        ('3.0', 'aa3d7447003abd5e3c437de52d8da2e6203390ac'),
        ('3.1', '269a613efab1718fd587c2bfc945d095b57f56e2'),
        ('3.2', '5809bf47aeb6e8257691287f9a218660c110acc5'),
        ('3.2.x', '16af2a5afdfd14bc482963942b2e657a032da43d'),
        ('3.3', 'df60b373c5f6c22835fdb8521b12973e9d6e06df'),
        ('3.4', 'bfbe10165cbfc0cd7b1d7e9c878f1a3f2b6872f1'),
        ('3.5', '3e310a136e71bb284a959d95c77f5b7af132280b'),
        ('3.6', '82d56105d0bdbdf5959b16f788fed4f6a530373f'),
        ('3.7', '27b5f7469fe5259aa489e92fdb6d88900ec8c0a4'),
        ('3.8', 'e98c69e26250b411e51cc92bf73df2f0829d0759'),
        ('3.9', 'f88513f985e153aaf3e2950622c2a2329c3c3f8f'),
        ('3.10', '4a8ee1833947c5aba704bf09fad612f4c4ecd827'),
        ('3.10.x', '3ec542bfe6854491bceb77b40c46f3b63849445a'),
        ('3.11', '35fd8e89d9cbd3b665dd11c3ae901ac52b07bcbb'),
        ('3.12', 'fcc197ae3a575b6f1b2aa1e51fe250eaadd4292b'),
        ('3.12.x', '74a2fd46ecfeb9d520e50779734a473037924831'),
        ('3.12.31+', 'bc1683ef045db170785c86eeebe57798445af63c'),
        ('3.13', 'b8ca8d15cf8e635d310acab5e571e31399a842b2'),
        ('3.14', 'b279b0bb265eb0c71c0420becd127c90f09b0003'),
        ('3.14.21+', 'aea8b249e0a369981f2b2c9a58f5aaf200e31594'),
        ('3.14.40+', '6eb622e3346262bd20b05458c371b864577b8c27'),
        ('3.15', '19702ee73cdc4a102593969537938f3183d4b841'),
        ('3.16', 'cb287d372de85fad6a15afa198d7526383037381'),
        ('3.17', 'a511fd5b5b4a311c906e200ef8abc42d1387b94d'),
        ('3.18', 'b5a25205ee21187e20e1d998f98763d09f442c26'),
        ('3.18.1+', 'cb74b62417010b75273fa1e1ee89d2a4782a728f'),
        ('3.18.25+', '0591c3182066555d46564404a29786232d49e977'),
        ('3.19', '2a2a3ee407810b4a3e19c3d5cfdb7f371d5df835'),
        ('4.0', 'f3daf663294ae51cde1105450705a83d7f0abf84'),
        ('4.1', '779216b4d28c295a6f52787dc35962e6dedcdc8c'),
        ('4.1.13+', '5757557b36dc5e875e93dbe299e75dd331126d98'),
        ('4.2', '7696ae969ebcef1b7a74d0d0aeae8857dfb972c1'),
        ('4.3', '09faae00f970d044ccd90ea8cc9a34545b3ac24d'),
        ('4.4', '7b00655846641e84c87f9af94985f48e4bb0f2df'),
        ('4.5', '655770239032bc4dec1e591016e1a3a5307c9f6c'),
        ('4.6', '058f6e23530e4b38f60725537ad151098ee74437'),
        ('4.7', '0228f4bae07367afbcccc7b1c98ec438c35fb60e'),
        ('4.8', 'f1590cdde901ad19fa9800b1a35b557270f29fc0'),
        ('4.9', '34be418bd4f0bb069e3971c76f5a8d8a6038558a'),
        ('4.9.9+', '71d20f2f8e0d26779645b1a436d9c7a6f87911a4'),
        ('4.9.94+', '600b5b31643556b07e9782efb73f3b0092e6a58c'),
        ('4.10', 'aa5ef5e7a628817b6c2c89acddfc7976bb758bb6'),
        ('4.11.7+', '017c55ba5613570d44f63c99cfd39c01867dc826'),
        ('4.12', '31266c01bd88e0053f53f4580adcca03175947b2'),
        ('4.13', '78cbc7ffc120b21092a984808865f226764eed3b'),
        ('4.14', '105ac5581e1792f80f4520d4ab4072dfb863c818'),
        ('4.14.56+', '1f1c400638e72061967bf318002e49b1d971bf37'),
        ('4.14.73+', 'df5c09adc49fd0d431c0f18d190130675c8bffb9'),
        ('4.15', '05375f52cab37d77602dd8cdb4a6b34a45de7689'),
        ('4.16', '425ecd2b0837d5d7c12a0aae7c6c05910ead5cef'),
        ('4.17', '4662af5e51c2191aac6bea3fd1f1bc853e33bb12'),
        ('4.18', 'c0cdacc30e85486a06a3b0d0a4c91accfd62e95d'),
        ('4.18.11+', '989cad9ca164ffc6b21ee13f35e6130cb4b068cc'),
        ('4.19', '0f5cf9757022f1dc050623455a196140e4f63eaa'),
        ('4.19.17+', '63fd5ed7eecef4f65bf60a1136df6bbd493fe511'),
        ('4.19.63+', '1bb4caf8d7ee47acc49f05deb4da9d34884c44b2'),
        ('4.20', '13c40c206b7a50bcc116bb512682ef588e0c985c'),
        ('4.20.4+', '51f87f23d9460e2bd3d615dc1cb8bae070971e28'),
        ('5.0', '25f304c2c8c866b551ba7dc0c26b8fc1bbac95fa'),
        ('5.1', 'd051ff358d1072d71103b076ca2d7d163a17a3f8'),
        ('5.2', '45f6f8eb62d2208316ad09bf9cce7d88537270f4'),
        ('5.2.5+', '40a8029ab232f2e03c7a9939800f2507308f5b38'),
        ('5.3', '26428f642dce5b1c1455fa73ac77c3b51bafdd85'),
        ('5.3.16', '28e5d4ec9104b44ae72da47218e60f9d3d5cc11b'),
        ('5.4', '6445cad30e63f7dfac92cdac4c4d9ee6822d45a0'),
        ('5.4.3', '10751a60a5e05275421f3c0dd6a21460c257bc9c'),
        ('5.5', 'd1b73359ba9941ed16c7b0fc73d6a1d31567e55f'),
        ('5.6', '175ef71420bf49a67263b703d98b8950658ae74f'),
        ('5.7', 'a903981607ce1f23154aee3e7547924c951125df'),
        ('5.8', '541e69ed9ceacb63105c88edd30355bf7267dc02'),
        ('5.9', 'a786c5eb13b3a45938ac1b829709d0b1d59cd47d'),
        ('5.10', '5ccffc85172fb21a564a4a68fd33987a6a312ba0'),
        ('5.10.82', '712523807ed66d89a5c919c6db31019d30760b11'),
        ('5.10.117', '088ebc287b30fb54aabf268fc81280e3f44e6edd'),
        ('5.10.140', '72075d1d0bd59c94529348883e810410318674e5'),
        ('5.15','39e948b1b73122dc0069be89691494516c3a91c3'),
        ('5.15.5','c2ce6a805f301e939724e9a48e523c7298b797e6'),
        ('5.15.36','8c2481e91182fc6959cb3ad56858c66d7a0c97fd'),
        ('5.15.41','5e018961ad499fc74e750ae857c33fbfc7641cfd'),
        ('6.1','bfd38ec481836d86de5686dadca02e072b4f0584'),
        ('6.6','1b28ab1ec3a89a9bec859f61f36d7a5e895583d5'),
        ('6.6.63','4b3aaa6e3dfad2e26deef81a6abbec02939e1080'),
        ('6.12','a74fc3a112d90acddafa65a254177d4e523d1f0c'),
    ])


    # match with the correct aufs branch for our kernel version
    # from the aufs git repo README file:

    # 'For (an unreleased) example:
    # If you are using "linux-4.10" and the "aufs4.10" branch
    # does not exist in aufs-util repository, then "aufs4.9", "aufs4.8"
    # or something numerically smaller is the branch for your kernel.'

    # Some branch names finish in '+', it is always removed for comparison

    for key, value in reversed(list(aufsdict.items())):
        if key.split('+')[0] == kernelversion:
            aufsbranch = key
            break
        keylen = len(key.split('+')[0].split('.'))
        if int(key.split('+')[0].split('.')[0]) > int(kernelversion.split('.')[0]):
            continue
        elif int(key.split('+')[0].split('.')[0]) < int(kernelversion.split('.')[0]):
            aufsbranch = key
            break

        if int(key.split('+')[0].split('.')[1]) > int(kernelversion.split('.')[1]):
            continue
        elif int(key.split('+')[0].split('.')[1]) < int(kernelversion.split('.')[1]):
            aufsbranch = key
            break

        if keylen is 3:
            # If kernel version does not have a third digit continue searching
            if len(kernelversion.split('.')) < keylen:
                continue
            # Branch name of the form M.m.x, replace with M.m.0 for comparison
            patchlevel = key.split('+')[0].split('.')[2]
            if patchlevel[-1] == 'x':
                if int(patchlevel[:-1] + '0') < int(kernelversion.split('.')[2]):
                    aufsbranch = key
                    break
            # Branch name is standard kernel version format M.m.p
            else:
                if int(patchlevel) < int(kernelversion.split('.')[2]):
                    aufsbranch = key
                    break

        else:
            aufsbranch = key
            break

    return aufsbranch,aufsdict[aufsbranch]

python do_test_aufs_kernel_select() {
    import collections
    # Tuples with kernel version and expected branch combinations
    testdata = collections.OrderedDict([
        ('3.2.10', '3.2.x'),
        ('3.10', '3.10'),
        ('3.12.31','3.12.31+'),
        ('3.14.40','3.14.40+'),
        ('4.19.18','4.19.17+'),
        ('5.2.0','5.2'),
        ('5.2.5','5.2.5+'),
        ('5.2.6','5.2.5+'),
        ('5.10.82','5.10.82'),
        ('5.15.34','5.15.5'),
        ('5.15.36','5.15.36'),
        ('5.15.41','5.15.41'),
        ('5.15.42','5.15.41'),
        ])

    for kernelversion,expectedBranch in list(testdata.items()):
        result = aufs_kernel_select(kernelversion)[0]
        if result != expectedBranch:
            bb.fatal("Expecting %s but got %s" % (expectedBranch, result))
}
addtask test_aufs_kernel_select after do_fetch before do_patch

python do_kernel_resin_aufs_fetch_and_unpack() {

    import os.path
    from bb.fetch2.git import Git

    balena_storage = d.getVar('BALENA_STORAGE', True)
    bb.note("Kernel will be configured for " + balena_storage + " balena storage driver.")

    kernelversion = get_kernel_version(d)
    kernelversion_major = int(kernelversion.split('.')[0])
    # If overlay2, we assume support in the kernel source so no need for extra
    # patches
    if balena_storage == "overlay2":
        if int(kernelversion_major) < 4:
            bb.fatal("overlay2 is only available from kernel version 4.0. Can't use overlay2 as BALENA_STORAGE.")
        if not bb.utils.contains("BALENA_CONFIGS", "aufs", True, False, d):
            return

    kernelsource = d.getVar('S', True)
    # Everything from here is for aufs
    if os.path.isdir(kernelsource + "/fs/aufs"):
        bb.note("The kernel source tree has the fs/aufs directory. Will not fetch and unpack aufs patches.")
        return

    aufsbranch,aufscommit = aufs_kernel_select(kernelversion)

    if kernelversion.split('.')[0] is '3':
        srcuri = "git://git.code.sf.net/p/aufs/aufs3-standalone.git;protocol=https;branch=aufs%s;name=aufs;destsuffix=aufs_standalone" % aufsbranch
    elif kernelversion.split('.')[0] is '4':
        srcuri = "git://github.com/sfjro/aufs4-standalone.git;protocol=https;branch=aufs%s;name=aufs;destsuffix=aufs_standalone" % aufsbranch
    elif kernelversion.split('.')[0] is '5' or kernelversion.split('.')[0] is '6':
        srcuri = "git://github.com/sfjro/aufs-standalone.git;protocol=https;branch=aufs%s;name=aufs;destsuffix=aufs_standalone" % aufsbranch

    d.setVar('SRCREV_aufs', aufscommit)
    aufsgit = Git()
    urldata = bb.fetch.FetchData(srcuri, d)
    aufsgit.download(urldata, d)
    aufsgit.unpack(urldata, d.getVar('WORKDIR', True), d)
}

# add our task to task queue - we need the kernel version (so we need to have the sources unpacked and patched) in order to know what aufs patches version we fetch and unpack
addtask kernel_resin_aufs_fetch_and_unpack after do_patch before do_configure
kernel_resin_aufs_fetch_and_unpack[vardeps] += " BALENA_STORAGE BALENA_CONFIGS"

# copy needed aufs files and apply aufs patches
apply_aufs_patches () {
    # bail out if it looks like the kernel source tree already has the fs/aufs directory
    if [ -d ${S}/fs/aufs ] || ! ${@bb.utils.contains('BALENA_CONFIGS','aufs','true','false',d)}; then
        exit
    fi
    cp -r ${WORKDIR}/aufs_standalone/Documentation ${WORKDIR}/aufs_standalone/fs ${S}
    cp ${WORKDIR}/aufs_standalone/include/uapi/linux/aufs_type.h ${S}/include/uapi/linux/
    cd ${S}
    if [ -d "${S}/.git" ]; then
        PATCH_CMD="git apply -3"
    else
        PATCH_CMD="patch -p1"
    fi
    $PATCH_CMD < `find ${WORKDIR}/aufs_standalone/ -name 'aufs*-kbuild.patch'`
    $PATCH_CMD < `find ${WORKDIR}/aufs_standalone/ -name 'aufs*-base.patch'`
    $PATCH_CMD < `find ${WORKDIR}/aufs_standalone/ -name 'aufs*-mmap.patch'`
}
do_kernel_resin_aufs_fetch_and_unpack[postfuncs] += "apply_aufs_patches"
do_kernel_resin_aufs_fetch_and_unpack[network] = "1"

#
# Inject resin configs
#
python do_kernel_resin_injectconfig() {
    activatedflags = d.getVar("BALENA_CONFIGS", True).split()
    if not activatedflags:
        bb.warn("No resin specific kernel configuration flags selected.")
        return

    # This is after configure so we are sure there is a .config file
    configfilepath = d.getVar("B", True) + '/.config'

    # Configs added with flaged dictionaries
    configs = d.getVarFlags("BALENA_CONFIGS") or {}
    configsdep = d.getVarFlags("BALENA_CONFIGS_DEPS") or {}

    for activatedflag in activatedflags:
        bb.note("Configure kernel for %s." %activatedflag)

        # Address dependencies
        if activatedflag in configsdep:
            bb.note("Configure kernel for %s [configs dependencies]."
                %activatedflag)
            for c in configsdep[activatedflag].split():
                appendLineToFile(filepath=configfilepath, line=c)
        else:
            bb.note("No dependent configs for %s." %activatedflag)

        # Address configs
        if activatedflag in configs:
            bb.note("Configure kernel for %s [configs]." %activatedflag)
            for c in configs[activatedflag].split():
                appendLineToFile(filepath=configfilepath, line=c)
        else:
            bb.note("No configs for %s." %activatedflag)

    # Configs added with resin defconfig
    resinDefconfig = d.getVar("BALENA_DEFCONFIG_NAME", True)
    resinDefconfigPath = d.getVar("WORKDIR", True) + '/' +  resinDefconfig
    resinDefconfigs = getKernelSetConfigs(resinDefconfigPath)
    if resinDefconfigs:
        bb.note("Configure kernel from %s." %resinDefconfig)
        for c in resinDefconfigs:
            appendLineToFile(filepath=configfilepath, line=c)
    else:
        bb.note("No kernel configuration found from %s." %resinDefconfig)
}
addtask kernel_resin_injectconfig after do_configure before do_compile
do_kernel_resin_injectconfig[vardeps] += "BALENA_CONFIGS BALENA_CONFIGS_DEPS"
do_kernel_resin_injectconfig[deptask] += "do_configure"
do_kernel_resin_injectconfig[dirs] += "${WORKDIR} ${B}"

#
# Reconfigure kernel after we inject resin configs
#
do_kernel_resin_reconfigure() {
    ${KERNEL_CONFIG_COMMAND}
}
addtask kernel_resin_reconfigure after do_kernel_resin_injectconfig before do_compile
do_kernel_resin_reconfigure[vardeps] += "BALENA_CONFIGS BALENA_CONFIGS_DEPS"
do_kernel_resin_reconfigure[deptask] += "do_kernel_resin_injectconfig"
do_kernel_resin_reconfigure[dirs] += "${B}"

#
# Check that all the wanted configs got activated in kernel
#
python do_kernel_resin_checkconfig() {
    activatedflags = d.getVar("BALENA_CONFIGS", True).split()
    if not activatedflags:
        bb.warn("No resin specific kernel configuration flags selected.")
        return

    configfilepath = d.getVar("B", True) + '/.config'
    allSetKernelConfigs = getKernelSetConfigs(configfilepath)
    configs = d.getVarFlags("BALENA_CONFIGS") or {}
    firmware_compression = d.getVar('FIRMWARE_COMPRESSION', True)

    if firmware_compression == "1" and \
        'firmware_compress' not in activatedflags:
            bb.fatal("Firmware compression is enabled for this device but" \
                " the kernel does not have support for it")

    for activatedflag in activatedflags:
        if activatedflag in configs:
            bb.note("Checking kernel configs for %s." %activatedflag)
            wantedConfigs = set(configs[activatedflag].split())
            configured = wantedConfigs.intersection(allSetKernelConfigs)
            notconfigured = wantedConfigs.difference(configured)

            for config in notconfigured:
                if not config.endswith('=n'):
                    bb.warn("Checking for %s in the kernel configs failed for %s."
                        % (config, activatedflag))

    # Check configs added with resin defconfig
    resinDefconfig = d.getVar("BALENA_DEFCONFIG_NAME", True)
    resinDefconfigPath = d.getVar("WORKDIR", True) + '/' +  resinDefconfig
    wantedConfigs = getKernelSetConfigs(resinDefconfigPath)
    if wantedConfigs:
        configured = wantedConfigs.intersection(allSetConfigs)
        notconfigured = wantedConfigs.difference(configured)
        for config in notconfigured:
            if not config.endswith('=n'):
                bb.warn("Checking for %s in the resin kernel configs failed from %s."
                    % (config, resinDefconfig))
}
addtask kernel_resin_checkconfig after do_kernel_resin_reconfigure before do_compile
do_kernel_resin_checkconfig[vardeps] += "BALENA_CONFIGS BALENA_CONFIGS_DEPS"
do_kernel_resin_checkconfig[deptask] += "do_kernel_resin_reconfigure"
do_kernel_resin_checkconfig[dirs] += "${WORKDIR} ${B}"

do_configure:append () {
    if [ -f "${DEPLOY_DIR_IMAGE}/balena-keys/kmod.crt" ]; then
        install -d certs
        install -m 0655 "${DEPLOY_DIR_IMAGE}/balena-keys/kmod.crt" "certs/"
    fi

}
do_configure[depends] += "${@oe.utils.conditional('SIGN_API','','',' balena-keys:do_deploy',d)}"
# Force compile to depend on the last resin task in the chain
do_compile[deptask] += "do_kernel_resin_checkconfig"
# Remove kernel module certificates generated during previous build
do_configure[cleandirs] += "${@oe.utils.conditional('SIGN_API','','','${B}/certs',d)}"
do_configure[vardeps] += " \
    SIGN_API \
    "

# Because we chain signatures here, the signed artifact is different for each
# and defined in :prepend for each task
SIGNING_ARTIFACTS_BASE = "${B}/${KERNEL_OUTPUT_DIR}/${KERNEL_IMAGETYPE}.initramfs"
addtask sign_efi before do_deploy after do_bundle_initramfs
addtask sign_gpg before do_deploy after do_sign_efi

do_sign_efi:prepend() {
    SIGNING_ARTIFACTS="${SIGNING_ARTIFACTS_BASE}"
}

do_sign_gpg:prepend () {
    SIGNING_ARTIFACTS=""
    for SIGNING_ARTIFACT in ${SIGNING_ARTIFACTS_BASE}; do
        SIGNING_ARTIFACTS="${SIGNING_ARTIFACTS} ${SIGNING_ARTIFACT}.signed"
    done
}

do_sign_gpg:append () {
    for SIGNING_ARTIFACT in ${SIGNING_ARTIFACTS_BASE}; do
        mv "${SIGNING_ARTIFACT}.signed.sig" "${SIGNING_ARTIFACT}.sig"
    done
}

# Parallel builds sharing state cache will mismatch singed kernel and modules
# Avoid using cache for signed kernel modules to avoid this
# Also, avoid having the kernel modules rebuilt even if they
# are not signed - see https://lists.openembedded.org/g/bitbake-devel/message/12359
python __anonymous() {
    if d.getVar('SIGN_API'):
        d.setVarFlag('do_compile_kernelmodules', 'nostamp', '1')
}

do_deploy:prepend () {
    SIGNING_ARTIFACTS="${SIGNING_ARTIFACTS_BASE}"
}

# copy to deploy dir latest .config and Module.symvers (after kernel modules have been built)
do_deploy:append () {
    install -m 0644 ${D}/boot/Module.symvers-* ${DEPLOYDIR}/Module.symvers
    install -m 0644 ${D}/boot/config-* ${DEPLOYDIR}/.config
}
