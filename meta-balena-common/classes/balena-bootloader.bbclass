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

inherit kernel-balena-noimage sign-efi

BALENA_CONFIGS ?= " \
    kexec \
    raid \
    device_mapper \
    firmware_compress \
    virt \
    fs \
    net \
    usb \
    spi \
    i2c \
    input \
    blkdev \
    media \
    nls \
    misc \
    ${@oe.utils.conditional('SIGN_API','','',' crypto',d)} \
    "

#
# Balena bootloader specific kernel configuration
#

# We need kexec for the bootloader to work
BALENA_CONFIGS[kexec] = " \
    CONFIG_KEXEC=y \
    CONFIG_KEXEC_FILE=y \
    "

BALENA_CONFIGS:append = "${@oe.utils.conditional('SIGN_API','','','secureboot',d)}"
BALENA_CONFIGS_DEPS[secureboot] = " \
    CONFIG_INTEGRITY_SIGNATURE=y \
    CONFIG_INTEGRITY_ASYMMETRIC_KEYS=y \
    CONFIG_SYSTEM_BLACKLIST_KEYRING=y \
    CONFIG_SECURITY_LOCKDOWN_LSM=y \
    CONFIG_SECURITY_LOCKDOWN_LSM_EARLY=y \
"
BALENA_CONFIGS[secureboot] = " \
    CONFIG_KEXEC_SIG=y \
    CONFIG_MODULE_SIG=y \
    CONFIG_MODULE_SIG_ALL=y \
    CONFIG_MODULE_SIG_SHA512=y \
    CONFIG_SYSTEM_TRUSTED_KEYS="certs/kmod.crt" \
    CONFIG_INTEGRITY_PLATFORM_KEYRING=y \
"

# We only support RAID1
BALENA_CONFIGS[raid] = " \
    CONFIG_BLK_DEV_MD=y \
    CONFIG_MD_RAID1=y \
    CONFIG_MD_LINEAR=n \
    CONFIG_MD_RAID0=n \
    CONFIG_MD_RAID10=n \
    CONFIG_MD_RAID456=n \
    "

# We need dm-crypt for LUKS but not much else
BALENA_CONFIGS[device_mapper] = " \
    CONFIG_BLK_DEV_DM=y \
    CONFIG_DM_CRYPT=y \
    CONFIG_DM_BUFIO=n \
    CONFIG_DM_BIO_PRISON=n \
    CONFIG_DM_PERSISTENT_DATA=n \
    CONFIG_DM_SNAPSHOT=n \
    CONFIG_DM_THIN_PROVISIONING=n \
    CONFIG_DM_CACHE=n \
    CONFIG_DM_CACHE_SMQ=n \
    CONFIG_DM_WRITECACHE=n \
    CONFIG_DM_MIRROR=n \
    CONFIG_DM_RAID=n \
    CONFIG_DM_ZERO=n \
    CONFIG_DM_MULTIPATH=n \
    CONFIG_DM_DELAY=n \
    CONFIG_DM_INTEGRITY=n \
    "

# Not sure we really need to load firmware for anything that bootloader
# would touch but if it is the case let's assume compression works
BALENA_CONFIGS[firmware_compress] = " \
    CONFIG_FW_LOADER_COMPRESS=y \
    "

# We do not need virtualization for the bootloader
BALENA_CONFIGS[virt] = " \
    CONFIG_VIRTUALIZATION=n \
    CONFIG_KVM=n \
    CONFIG_VHOST=n \
    CONFIG_VHOST_MENU=n \
    CONFIG_VHOST_NET=n \
    CONFIG_VSOCKETS=n \
    "

# We only need ext4, FAT(32) and the pseudo-filesystems
BALENA_CONFIGS[fs] = " \
    CONFIG_EXT4_FS=y \
    CONFIG_FAT_FS=y \
    CONFIG_MSDOS_FS=y \
    CONFIG_VFAT_FS=y \
    CONFIG_PROC_FS=y \
    CONFIG_KERNFS=y \
    CONFIG_DEVTMPFS=y \
    CONFIG_SYSFS=y \
    CONFIG_TMPFS=y \
    CONFIG_AUTOFS_FS=n \
    CONFIG_AUTOFS4_FS=n \
    CONFIG_NFS_FS=n \
    CONFIG_CEPH_FS=n \
    CONFIG_OCFS2_FS=n \
    CONFIG_F2FS_FS=n \
    CONFIG_REISERFS_FS=n \
    CONFIG_JFS_FS=n \
    CONFIG_XFS_FS=n \
    CONFIG_GFS2_FS=n \
    CONFIG_BTRFS_FS=n \
    CONFIG_NILFS2_FS=n \
    CONFIG_FUSE_FS=n \
    CONFIG_CUSE=n \
    CONFIG_OVERLAY_FS=n \
    CONFIG_ISO9660_FS=n \
    CONFIG_UDF_FS=n \
    CONFIG_USB_F_FS=n \
    CONFIG_EXFAT_FS=n \
    CONFIG_NTFS_FS=n \
    CONFIG_NTFS3_FS=n \
    CONFIG_EFIVAR_FS=n \
    CONFIG_ECRYPT_FS=n \
    CONFIG_HFS_FS=n \
    CONFIG_HFSPLUS_FS=n \
    CONFIG_JFFS2_FS=n \
    CONFIG_UBIFS_FS=n \
    CONFIG_SQUASHFS=n \
    CONFIG_BLK_DEBUG_FS=n \
    CONFIG_DEBUG_FS=n \
    "

# We do not need actual physical networking but we need kernel networking
# for loopback and unix sockets, otherwise e.g. udev does not work
BALENA_CONFIGS[net] = " \
    CONFIG_NET=y \
    CONFIG_UNIX=y \
    CONFIG_WIRELESS=n \
    CONFIG_BT=n \
    CONFIG_NFC=n \
    CONFIG_CAN=n \
    CONFIG_NETFILTER=n \
    CONFIG_NET_SCHED=n \
    CONFIG_NETDEVICES=n \
    CONFIG_INET=n \
    CONFIG_YAM=n \
    CONFIG_ROSE=n \
    CONFIG_BAYCOM_SER_FDX=n \
    CONFIG_BAYCOM_SER_HDX=n \
    CONFIG_NETROM=n \
    CONFIG_BRIDGE=n \
    CONFIG_GARP=n \
    CONFIG_VLAN_8021Q=n \
    CONFIG_STP=n \
    CONFIG_ATM=n \
    CONFIG_MAC802154=n \
    CONFIG_IEEE802154=n \
    CONFIG_NET_9P=n \
    CONFIG_NET_MPLS_GSO=n \
    CONFIG_NET_NSH=n \
    CONFIG_AX25=n \
    CONFIG_MKISS=n \
    CONFIG_6PACK=n \
    CONFIG_BPQETHER=n \
    CONFIG_RFKILL=n \
    "

# We need USB for keybaords and USB sticks but not much else
BALENA_CONFIGS_DEPS[usb] = " \
    CONFIG_SCSI=y \
    CONFIG_BLK_DEV_SD=y \
    CONFIG_USB_EHCI_HCD=y \
    CONFIG_USB_EHCI_PCI=y \
    CONFIG_USB_XHCI_HCD=y \
    CONFIG_USB_XHCI_PCI=y \
"

BALENA_CONFIGS[usb] = " \
    CONFIG_USB_STORAGE=y \
    CONFIG_USB_UAS=y \
    CONFIG_USB_SERIAL=n \
    CONFIG_USB_GADGET=n \
    CONFIG_USB_PRINTER=n \
    CONFIG_USB_MDC800=n \
    CONFIG_USB_MICROTEK=n \
    CONFIG_USBIP_CORE=n \
    CONFIG_USB_EMI62=n \
    CONFIG_USB_EMI26=n \
    CONFIG_USB_ADUTUX=n \
    CONFIG_USB_SEVSEG=n \
    CONFIG_USB_LEGOTOWER=n \
    CONFIG_USB_LCD=n \
    CONFIG_USB_CYPRESS_CY7C63=n \
    CONFIG_USB_CYTHERM=n \
    CONFIG_USB_IDMOUSE=n \
    CONFIG_USB_FTDI_ELAN=n \
    CONFIG_USB_APPLEDISPLAY=n \
    CONFIG_USB_LD=n \
    CONFIG_USB_TRANCEVIBRATOR=n \
    CONFIG_USB_IOWARRIOR=n \
    CONFIG_USB_TEST=n \
    CONFIG_USB_STORAGE_REALTEK=n \
    CONFIG_USB_STORAGE_DATAFAB=n \
    CONFIG_USB_STORAGE_FREECOM=n \
    CONFIG_USB_STORAGE_ISD200=n \
    CONFIG_USB_STORAGE_USBAT=n \
    CONFIG_USB_STORAGE_SDDR09=n \
    CONFIG_USB_STORAGE_SDDR55=n \
    CONFIG_USB_STORAGE_JUMPSHOT=n \
    CONFIG_USB_STORAGE_ALAUDA=n \
    CONFIG_USB_STORAGE_ONETOUCH=n \
    CONFIG_USB_STORAGE_KARMA=n \
    CONFIG_USB_STORAGE_CYPRESS_ATACB=n \
    CONFIG_USB_STORAGE_ENE_UB6250=n \
    CONFIG_USB_MON=n \
    CONFIG_USB_ACM=n \
    CONFIG_USB_WDM=n \
    CONFIG_USB_TMC=n \
    CONFIG_USB_ISIGHTFW=n \
    CONFIG_USB_YUREX=n \
    CONFIG_USB_EZUSB_FX2=n \
    "

# We should be fine with keeping just the keyboard as input
# which should be handled by the generic HID driver
# Disable everything else - mouses, joysticks, steering wheels etc.
BALENA_CONFIGS[input] = " \
    CONFIG_INPUT_TOUCHSCREEN=n \
    CONFIG_INPUT_JOYSTICK=n \
    CONFIG_INPUT_JOYDEV=n \
    CONFIG_INPUT_MOUSEDEV=n \
    CONFIG_INPUT_AD714X=n \
    CONFIG_INPUT_ATI_REMOTE2=n \
    CONFIG_INPUT_KEYSPAN_REMOTE=n \
    CONFIG_INPUT_POWERMATE=n \
    CONFIG_INPUT_YEALINK=n \
    CONFIG_INPUT_CM109=n \
    CONFIG_INPUT_UINPUT=n \
    CONFIG_INPUT_GPIO_ROTARY_ENCODER=n \
    CONFIG_INPUT_ADXL34X=n \
    CONFIG_INPUT_CMA3000=n \
    CONFIG_INPUT_RASPBERRYPI_BUTTON=n \
    CONFIG_GAMEPORT=n \
    CONFIG_UHID=n \
    CONFIG_HID_A4TECH=n \
    CONFIG_HID_ACRUX=n \
    CONFIG_HID_APPLE=n \
    CONFIG_HID_ASUS=n \
    CONFIG_HID_BELKIN=n \
    CONFIG_HID_BETOP_FF=n \
    CONFIG_HID_BIGBEN_FF=n \
    CONFIG_HID_CHERRY=n \
    CONFIG_HID_CHICONY=n \
    CONFIG_HID_CYPRESS=n \
    CONFIG_HID_DRAGONRISE=n \
    CONFIG_HID_EMS_FF=n \
    CONFIG_HID_ELECOM=n \
    CONFIG_HID_ELO=n \
    CONFIG_HID_EZKEY=n \
    CONFIG_HID_GEMBIRD=n \
    CONFIG_HID_HOLTEK=n \
    CONFIG_HID_KEYTOUCH=n \
    CONFIG_HID_KYE=n \
    CONFIG_HID_UCLOGIC=n \
    CONFIG_HID_WALTOP=n \
    CONFIG_HID_GYRATION=n \
    CONFIG_HID_TWINHAN=n \
    CONFIG_HID_KENSINGTON=n \
    CONFIG_HID_LCPOWER=n \
    CONFIG_HID_LED=n \
    CONFIG_HID_LOGITECH=n \
    CONFIG_HID_LOGITECH_DJ=n \
    CONFIG_HID_LOGITECH_HIDPP=n \
    CONFIG_HID_MAGICMOUSE=n \
    CONFIG_HID_MICROSOFT=n \
    CONFIG_HID_MONTEREY=n \
    CONFIG_HID_MULTITOUCH=n \
    CONFIG_HID_NINTENDO=n \
    CONFIG_HID_NTRIG=n \
    CONFIG_HID_ORTEK=n \
    CONFIG_HID_PANTHERLORD=n \
    CONFIG_HID_PETALYNX=n \
    CONFIG_HID_PICOLCD=n \
    CONFIG_HID_PLAYSTATION=n \
    CONFIG_HID_ROCCAT=n \
    CONFIG_HID_SAMSUNG=n \
    CONFIG_HID_SONY=n \
    CONFIG_HID_SPEEDLINK=n \
    CONFIG_HID_STEAM=n \
    CONFIG_HID_SUNPLUS=n \
    CONFIG_HID_GREENASIA=n \
    CONFIG_HID_SMARTJOYPLUS=n \
    CONFIG_HID_TOPSEED=n \
    CONFIG_HID_THINGM=n \
    CONFIG_HID_THRUSTMASTER=n \
    CONFIG_HID_WACOM=n \
    CONFIG_HID_WIIMOTE=n \
    CONFIG_HID_XINMO=n \
    CONFIG_HID_ZEROPLUS=n \
    CONFIG_HID_ZYDACRON=n \
    CONFIG_LOGITECH_FF=n \
    CONFIG_LOGIRUMBLEPAD2_FF=n \
    CONFIG_LOGIG940_FF=n \
    CONFIG_LOGIWHEELS_FF=n \
    CONFIG_NINTENDO_FF=n \
    CONFIG_PLAYSTATION_FF=n \
    CONFIG_SONY_FF=n \
    "

# Block devices that we do not typically boot from or provision to
BALENA_CONFIGS[blkdev] = " \
    CONFIG_ATA=n \
    CONFIG_ATA_OVER_ETH=n \
    CONFIG_BLK_DEV_NBD=n \
    CONFIG_BLK_DEV_SR=n \
    CONFIG_CDROM=n \
    CONFIG_CDROM_PKTCDVD=n \
    CONFIG_ZRAM=n \
    CONFIG_ZPOOL=n \
    CONFIG_SWAP=n \
    CONFIG_ZSWAP=n \
    CONFIG_MTD=n \
    "

# No need for media support in the bootloader
BALENA_CONFIGS[media] = " \
    CONFIG_SOUND=n \
    CONFIG_MEDIA_SUPPORT=n \
    CONFIG_DRM=n \
    "

# NLS is pulled in by ext4
# keeping only UTF8, ASCII and 437 as the system will fail to boot
# without them
BALENA_CONFIGS[nls] = " \
    CONFIG_NLS=y \
    CONFIG_NLS_DEFAULT="utf8" \
    CONFIG_NLS_UTF8=y \
    CONFIG_NLS_ASCII=y \
    CONFIG_NLS_CODEPAGE_437=y \
    CONFIG_NLS_CODEPAGE_737=n \
    CONFIG_NLS_CODEPAGE_775=n \
    CONFIG_NLS_CODEPAGE_850=n \
    CONFIG_NLS_CODEPAGE_852=n \
    CONFIG_NLS_CODEPAGE_855=n \
    CONFIG_NLS_CODEPAGE_857=n \
    CONFIG_NLS_CODEPAGE_860=n \
    CONFIG_NLS_CODEPAGE_861=n \
    CONFIG_NLS_CODEPAGE_862=n \
    CONFIG_NLS_CODEPAGE_863=n \
    CONFIG_NLS_CODEPAGE_864=n \
    CONFIG_NLS_CODEPAGE_865=n \
    CONFIG_NLS_CODEPAGE_866=n \
    CONFIG_NLS_CODEPAGE_869=n \
    CONFIG_NLS_CODEPAGE_936=n \
    CONFIG_NLS_CODEPAGE_950=n \
    CONFIG_NLS_CODEPAGE_932=n \
    CONFIG_NLS_CODEPAGE_949=n \
    CONFIG_NLS_CODEPAGE_874=n \
    CONFIG_NLS_ISO8859_8=n \
    CONFIG_NLS_CODEPAGE_1250=n \
    CONFIG_NLS_CODEPAGE_1251=n \
    CONFIG_NLS_ISO8859_1=n \
    CONFIG_NLS_ISO8859_2=n \
    CONFIG_NLS_ISO8859_3=n \
    CONFIG_NLS_ISO8859_4=n \
    CONFIG_NLS_ISO8859_5=n \
    CONFIG_NLS_ISO8859_6=n \
    CONFIG_NLS_ISO8859_7=n \
    CONFIG_NLS_ISO8859_9=n \
    CONFIG_NLS_ISO8859_13=n \
    CONFIG_NLS_ISO8859_14=n \
    CONFIG_NLS_ISO8859_15=n \
    CONFIG_NLS_KOI8_R=n \
    CONFIG_NLS_KOI8_U=n \
    CONFIG_NLS_MAC_ROMAN=n \
    CONFIG_NLS_MAC_CELTIC=n \
    CONFIG_NLS_MAC_CENTEURO=n \
    CONFIG_NLS_MAC_CROATIAN=n \
    CONFIG_NLS_MAC_CYRILLIC=n \
    CONFIG_NLS_MAC_GAELIC=n \
    CONFIG_NLS_MAC_GREEK=n \
    CONFIG_NLS_MAC_ICELAND=n \
    CONFIG_NLS_MAC_INUIT=n \
    CONFIG_NLS_MAC_ROMANIAN=n \
    CONFIG_NLS_MAC_TURKISH=n \
    "

# We should generally not need SPI but there might be devices
# that e.g. boot from SPI flash so keeping this separate
# for easier override
BALENA_CONFIGS[spi] = " \
    CONFIG_SPI=n \
    "

# We should generally not need I2C but there might be specific
# cases where we want it, e.g. accessing a TPM
BALENA_CONFIGS[i2c] = " \
    CONFIG_I2C=n \
    "

# Things that seem like a good idea but do not fit anywhere else yet
BALENA_CONFIGS[misc] = " \
    CONFIG_PM_SLEEP_SMP=y \
    CONFIG_PM_SLEEP=y \
    CONFIG_SUSPEND=y \
    CONFIG_IKCONFIG=y \
    CONFIG_IKCONFIG_PROC=y \
    CONFIG_BINFMT_SCRIPT=y \
    CONFIG_BINFMT_MISC=y \
    CONFIG_SECURITY_APPARMOR=n \
    CONFIG_SECURITY_SELINUX=n \
    CONFIG_W1=n \
    CONFIG_RC_CORE=n \
    CONFIG_FB_TFT=n \
    CONFIG_SSB=n \
    CONFIG_IIO=n \
    CONFIG_UIO=n \
    CONFIG_UHID=n \
    CONFIG_HWMON=n \
    CONFIG_LOGO=n \
    CONFIG_DEBUG_INFO=n \
    CONFIG_DEBUG_INFO_NONE=y \
    CONFIG_TRACING=n \
    CONFIG_KGDB=n \
    CONFIG_STAGING=n \
    "

# We need crypto support to mount LUKS encrypted drives
BALENA_CONFIGS[crypto] = " \
    CONFIG_CRYPTO_LIB_AES=y \
    CONFIG_CRYPTO_MD5=y \
    CONFIG_CRYPTO_CBC=y \
    CONFIG_CRYPTO_AES=y \
    CONFIG_CRYPTO_SHA256=y \
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
do_configure[cleandirs] += "${@oe.utils.conditional('SIGN_API','','','${B}',d)}"
do_configure[vardeps] += " \
    SIGN_API \
    "

SIGNING_ARTIFACTS = "${B}/${KERNEL_OUTPUT_DIR}/${KERNEL_IMAGETYPE}.initramfs"
addtask sign_efi before do_deploy after do_bundle_initramfs

DESTDIR = "${DEPLOYDIR}/${KERNEL_PACKAGE_NAME}"
