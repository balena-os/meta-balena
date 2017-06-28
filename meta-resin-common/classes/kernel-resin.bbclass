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
#          RESIN_CONFIGS[mynewconfigblock].
#       b) [optional] Define a kernel configuration block which is a dependency
#          for RESIN_CONFIGS[mynewconfigblock] using
#          RESIN_CONFIGS_DEPS[mynewconfigblock]. This block won't be checked at
#          do_kernel_resin_checkconfig but will be configured before the configs
#          in RESIN_CONFIGS[mynewconfigblock].
#       c) Activate the new block appending the config block name to
#          RESIN_CONFIGS.
#          Ex: RESIN_CONFIGS_append = " mynewconfigblock"
#          Mind the space!
#   2. Using a special filename defined as RESIN_DEFCONFIG_NAME
#       a) [optional] Define RESIN_DEFCONFIG_NAME. Default: "resin-defconfig"
#       b) Add RESIN_DEFCONFIG_NAME to SRC_URI.

RESIN_DEFCONFIG_NAME ?= "resin-defconfig"

RESIN_CONFIGS ?= " \
    docker \
    brcmfmac \
    ralink \
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
    xtables \
    audit \
    governor \
    mbim \
    qmi \
    misc \
    "

#
# Docker specific kernel configuration
# Keep these updated with
# https://raw.githubusercontent.com/docker/docker/master/contrib/check-config.sh
#
RESIN_CONFIGS_DEPS[docker] ?= " \
    CONFIG_IP_NF_NAT=y \
    CONFIG_IPV6=y \
    CONFIG_IP_NF_IPTABLES=y \
    CONFIG_NF_CONNTRACK=y \
    CONFIG_NF_CONNTRACK_IPV4=y \
    CONFIG_NETFILTER=y \
    "
RESIN_CONFIGS[docker] ?= " \
    CONFIG_ADVISE_SYSCALLS=y \
    CONFIG_MEMCG=y \
    CONFIG_NAMESPACES=y \
    CONFIG_NET_NS=y \
    CONFIG_PID_NS=y \
    CONFIG_IPC_NS=y \
    CONFIG_UTS_NS=y \
    CONFIG_DEVPTS_MULTIPLE_INSTANCES=y \
    CONFIG_CGROUPS=y \
    CONFIG_CGROUP_CPUACCT=y \
    CONFIG_CGROUP_DEVICE=y \
    CONFIG_CGROUP_FREEZER=y \
    CONFIG_CGROUP_SCHED=y \
    CONFIG_CPUSETS=y \
    CONFIG_MACVLAN=y \
    CONFIG_VETH=y \
    CONFIG_BRIDGE=y \
    CONFIG_NF_NAT_IPV4=y \
    CONFIG_IP_NF_FILTER=y \
    CONFIG_IP6_NF_FILTER=m \
    CONFIG_IP_NF_TARGET_REJECT=m \
    CONFIG_IP6_NF_TARGET_REJECT=m \
    CONFIG_IP_NF_TARGET_MASQUERADE=m \
    CONFIG_IP6_NF_TARGET_MASQUERADE=m \
    CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y \
    CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y \
    CONFIG_NF_NAT=y \
    CONFIG_NF_NAT_NEEDED=y \
    CONFIG_POSIX_MQUEUE=y \
    CONFIG_TUN=y \
    CONFIG_BTRFS_FS=n \
    CONFIG_BTRFS_FS_POSIX_ACL=n \
    CONFIG_EXT4_FS=y \
    CONFIG_EXT4_FS_POSIX_ACL=y \
    CONFIG_EXT4_FS_SECURITY=y \
    CONFIG_AUFS_FS=y \
    CONFIG_AUFS_XATTR=y \
    CONFIG_KEYS=y \
    "

#
# systemd specific kernel configuration options
# see https://github.com/systemd/systemd/blob/master/README for an up-to-date list
#
RESIN_CONFIGS_DEPS[systemd] ?= " \
    CONFIG_DMIID=y \
    "
RESIN_CONFIGS[systemd] ?= " \
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
    CONFIG_BLK_DEV_BSG=y \
    CONFIG_NET_NS=y \
    CONFIG_DEVPTS_MULTIPLE_INSTANCES=y \
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
RESIN_CONFIGS[rtl8192cu] ?= "\
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
RESIN_CONFIGS_DEPS[r8188eu] ?= "\
    CONFIG_STAGING=y \
    "
RESIN_CONFIGS[r8188eu] ?= "\
    CONFIG_R8188EU=m \
    CONFIG_88EU_AP_MODE=y \
    "

# rt53xx wireless chipset family to the rt2800usb driver.
# Supported chips: RT5370 RT5572
RESIN_CONFIGS_DEPS[ralink] ?= "\
    CONFIG_CFG80211=m \
    CONFIG_MAC80211=m \
    CONFIG_RT2X00=m \
    CONFIG_RT2800USB=m \
    "
RESIN_CONFIGS[ralink] ?= "\
    CONFIG_RT2800USB_RT53XX=y \
    CONFIG_RT2800USB_RT55XX=y \
    "

#
# Official RPI WiFi adapter
# http://thepihut.com/collections/new-products/products/official-raspberry-pi-wifi-adapter
#
RESIN_CONFIGS_DEPS[brcmfmac] ?= " \
    CONFIG_CFG80211=m \
    CONFIG_BRCMFMAC_USB=y \
    "
RESIN_CONFIGS[brcmfmac] ?= " \
    CONFIG_BRCMFMAC=m \
    "

#
# Most of the resin supported boards have user controllable LEDs
#
RESIN_CONFIGS_DEPS[leds-gpio] ?= " \
    CONFIG_NEW_LEDS=y \
    CONFIG_LEDS_CLASS=y \
    "
RESIN_CONFIGS[leds-gpio] ?= " \
    CONFIG_LEDS_GPIO=y \
    "

#
# Expose kernel config via procfs
#
RESIN_CONFIGS_DEPS[proc-config] ?= " \
    CONFIG_IKCONFIG=y \
    CONFIG_PROC_FS=y \
    CONFIG_EXPERT=y \
    "
RESIN_CONFIGS[proc-config] ?= " \
    CONFIG_IKCONFIG_PROC=y \
    "

#
# For a flawless boot experience deactivate logo - we have splash screen providers
#
RESIN_CONFIGS[no-logo] ?= " \
    CONFIG_LOGO=n \
    "

#
# Compress Kernel modules
#
RESIN_CONFIGS[compress-kmodules] ?= " \
    CONFIG_MODULE_COMPRESS=y \
    CONFIG_MODULE_COMPRESS_GZIP=y \
    CONFIG_DEBUG_INFO=n \
    "

#
# Support for touchscreens using generic multitouch driver
#
RESIN_CONFIGS_DEPS[hid-multitouch] ?= " \
    CONFIG_INPUT=y \
    CONFIG_HID=y \
    "
RESIN_CONFIGS[hid-multitouch] ?= " \
    CONFIG_HID_MULTITOUCH=m \
    CONFIG_HIDRAW=y \
    "

RESIN_CONFIGS[ip_set] = " \
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

RESIN_CONFIGS_DEPS[ip6tables_nat] = " \
    CONFIG_NF_CONNTRACK_IPV6=m \
    CONFIG_IP6_NF_IPTABLES=m \
    "
RESIN_CONFIGS[ip6tables_nat] = " \
    CONFIG_IP6_NF_NAT=m \
    "

RESIN_CONFIGS[seccomp] = " \
    CONFIG_SECCOMP=y \
    "

#
# The flasher images relies on shutdown at the end of the flashing process.
# Having no way out we might end up rebooting the board before shutdown because
# systemd is disabling watchdog before killing the other processes which might
# take more than the watchdog timer.
#
RESIN_CONFIGS[wd-nowayout] = " \
    CONFIG_WATCHDOG_NOWAYOUT=n \
    "

RESIN_CONFIGS_DEPS[xtables] = " \
    CONFIG_NETFILTER_ADVANCED=m \
    CONFIG_IP_SET=m \
    "

RESIN_CONFIGS[xtables] = " \
    CONFIG_NETFILTER_XT_SET=m \
    "

# Deactivate the audit susbsystem and the audit syscall
RESIN_CONFIGS_DEPS[audit] = " \
    CONFIG_HAVE_AUDITSYSCALL=n \
    CONIFG_SECURITY=n \
    "

RESIN_CONFIGS[audit] = " \
    CONFIG_AUDIT=n \
    CONFIG_AUDITSYSCALL=n \
    "

RESIN_CONFIGS_DEPS[governor] ?= " \
    CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y \
    "

# support for mbim cell modems
RESIN_CONFIGS[mbim] = " \
    CONFIG_USB_NET_CDC_MBIM=m \
    "

# support for qmi cell modems
RESIN_CONFIGS[qmi] = " \
    CONFIG_USB_NET_QMI_WWAN=m \
    "

# various other configurations
RESIN_CONFIGS[misc] = " \
    CONFIG_NF_NAT_REDIRECT=m \
    "

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
# Add aufs patches
#

python do_kernel_resin_aufs_fetch_and_unpack() {

    import collections, os.path, re
    from bb.fetch2.git import Git

    kernelsource = d.getVar('S', True)

    if os.path.isdir(kernelsource + "/fs/aufs"):
        bb.note("The kernel source tree has the fs/aufs directory. Will not fetch and unpack aufs patches.")
        return

    # get the kernel version from the top Makefile in the kernel source tree
    topmakefile = kernelsource + "/Makefile"
    with open(topmakefile, 'r') as makefile:
        lines = makefile.readlines()

    kernelversion = ""
    for s in lines:
        m = re.match("VERSION = (\d+)", s)
        if m:
            kernelversion = kernelversion + m.group(1)
        m = re.match("PATCHLEVEL = (\d+)", s)
        if m:
            kernelversion = kernelversion + '.' + m.group(1)
        m = re.match("SUBLEVEL = (\d+)", s)
        if m:
            kernelversion = kernelversion + '.' + m.group(1)
        m = re.match("EXTRAVERSION = (\d+)", s)
        if m:
            kernelversion = kernelversion + '.' + m.group(1)

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
        ('4.1', '0f55e31aefd360c19cc9d38b256c63fdbdb1cb0e'),
        ('4.1.13+', '149f0ce41b5c17ad206c8399e97f27f62163d179'),
        ('4.2', 'c41877758208364ab2a3fb4576e08d8521280f0f'),
        ('4.3', '32a6b994ca7ce59a729ed59cd9e9d2238bdc8b8e'),
        ('4.4', '7d174ae40b4c9c876ee51aa50fa4ee1f3747de23'),
        ('4.5', '6dd8031372d2d0c0e134cfc4770f2c5a3f9bc7c4'),
        ('4.6', '4ae7c7529ad9814789c65832dfb0646ed7b475e5'),
        ('4.7', '7731e69c5a26de9519332be64d973c91a377a582'),
        ('4.8', '34599e5c1fbc295f96ffbbc7e8129921e6f79a8a'),
        ('4.9', '8a73f3f87e9150de4ac807de1562a060112cbbe6'),
        ('4.10', '14d1526d7436f2e4371893d4ecd4dda3b26f3730'),
    ])


    # match with the correct aufs branch for our kernel version
    # from the aufs git repo README file:

    # 'For (an unreleased) example:
    # If you are using "linux-4.10" and the "aufs4.10" branch
    # does not exist in aufs-util repository, then "aufs4.9", "aufs4.8"
    # or something numerically smaller is the branch for your kernel.'

    for key, value in reversed(list(aufsdict.items())) :
        if key.split('+')[0] is kernelversion:
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
            if int(key.split('+')[0].split('.')[2][:-1] + '0') <= int(kernelversion.split('.')[2]):
                aufsbranch = key
                break
        else:
            aufsbranch = key
            break

    if kernelversion.split('.')[0] is '3':
        srcuri = "git://git.code.sf.net/p/aufs/aufs3-standalone.git;branch=aufs%s;name=aufs;destsuffix=aufs_standalone" % aufsbranch
    elif kernelversion.split('.')[0] is '4':
        srcuri = "git://github.com/sfjro/aufs4-standalone.git;branch=aufs%s;name=aufs;destsuffix=aufs_standalone" % aufsbranch

    d.setVar('SRCREV_aufs', aufsdict[aufsbranch])
    aufsgit = Git()
    urldata = bb.fetch.FetchData(srcuri, d)
    aufsgit.download(urldata, d)
    aufsgit.unpack(urldata, d.getVar('WORKDIR', True), d)
}

# add our task to task queue - we need the kernel version (so we need to have the sources unpacked and patched) in order to know what aufs patches version we fetch and unpack
addtask kernel_resin_aufs_fetch_and_unpack after do_patch before do_configure

# copy needed aufs files and apply aufs patches
apply_aufs_patches () {
    # bail out if it looks like the kernel source tree already has the fs/aufs directory
    if [ -d ${S}/fs/aufs ]; then
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

#
# Inject resin configs
#
python do_kernel_resin_injectconfig() {
    activatedflags = d.getVar("RESIN_CONFIGS", True).split()
    if not activatedflags:
        bb.warn("No resin specific kernel configuration flags selected.")
        return

    # This is after configure so we are sure there is a .config file
    configfilepath = d.getVar("B", True) + '/.config'

    # Configs added with flaged dictionaries
    configs = d.getVarFlags("RESIN_CONFIGS") or {}
    configsdep = d.getVarFlags("RESIN_CONFIGS_DEPS") or {}

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
    resinDefconfig = d.getVar("RESIN_DEFCONFIG_NAME", True)
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
do_kernel_resin_injectconfig[vardeps] += "RESIN_CONFIGS RESIN_CONFIGS_DEPS"
do_kernel_resin_injectconfig[deptask] += "do_configure"
do_kernel_resin_injectconfig[dirs] += "${WORKDIR} ${B}"

#
# Reconfigure kernel after we inject resin configs
#
do_kernel_resin_reconfigure() {
    eval ${KERNEL_CONFIG_COMMAND}
}
addtask kernel_resin_reconfigure after do_kernel_resin_injectconfig before do_compile
do_kernel_resin_reconfigure[vardeps] += "RESIN_CONFIGS RESIN_CONFIGS_DEPS"
do_kernel_resin_reconfigure[deptask] += "do_kernel_resin_injectconfig"
do_kernel_resin_reconfigure[dirs] += "${B}"

#
# Check that all the wanted configs got activated in kernel
#
python do_kernel_resin_checkconfig() {
    activatedflags = d.getVar("RESIN_CONFIGS", True).split()
    if not activatedflags:
        bb.warn("No resin specific kernel configuration flags selected.")
        return

    configfilepath = d.getVar("B", True) + '/.config'
    allSetKernelConfigs = getKernelSetConfigs(configfilepath)
    configs = d.getVarFlags("RESIN_CONFIGS") or {}

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
    resinDefconfig = d.getVar("RESIN_DEFCONFIG_NAME", True)
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
do_kernel_resin_checkconfig[vardeps] += "RESIN_CONFIGS RESIN_CONFIGS_DEPS"
do_kernel_resin_checkconfig[deptask] += "do_kernel_resin_reconfigure"
do_kernel_resin_checkconfig[dirs] += "${WORKDIR} ${B}"

# Force compile to depend on the last resin task in the chain
do_compile[deptask] += "do_kernel_resin_checkconfig"

# copy to deploy dir latest .config and Module.symvers (after kernel modules have been built)
do_deploy_append () {
    install -m 0644 ${D}/boot/Module.symvers-* ${DEPLOYDIR}/Module.symvers
    install -m 0644 ${D}/boot/config-* ${DEPLOYDIR}/.config
}

# Don't trigger in the kernel image without initramfs
# Boards should:
# a) use kernel-image-initramfs and deploy in in the rootfs (ex bbb)
# b) use boot deployment using RESIN_BOOT_PARTITION_FILES mechanism to deploy
#    the initramfs bundled kernel image
RDEPENDS_kernel-base = ""
