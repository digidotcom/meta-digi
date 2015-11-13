#@TYPE: Machine
#@NAME: ConnectCore 6 module.
#@DESCRIPTION: Machine configuration for Digi's ConnectCore 6 module.

include conf/machine/include/imx-digi-base.inc
include conf/machine/include/tune-cortexa9.inc

DIGI_FAMILY = "ccimx6"
SOC_FAMILY  = "mx6:${CPU_FAMILY}:${DIGI_FAMILY}"

# Platform u-boot settings
UBOOT_ENTRYPOINT = "0x10800000"
UBOOT_SUFFIX = "imx"

# wpa_supplicant driver to use in '/etc/network/interfaces'
WPA_DRIVER = "nl80211"

# Firmware
MACHINE_FIRMWARE ?= ""
MACHINE_FIRMWARE_append_mx6q = " firmware-imx-vpu-imx6q"
MACHINE_FIRMWARE_append_mx6dl = " firmware-imx-vpu-imx6d"
MACHINE_FIRMWARE_append = " ${@base_conditional('HAVE_BT', '1' , 'firmware-atheros-ar3k', '', d)}"

MACHINE_EXTRA_RDEPENDS += " \
    e2fsprogs \
    e2fsprogs-mke2fs \
    parted \
    u-boot-dey-fw-utils \
"
MACHINE_EXTRA_RRECOMMENDS += "${MACHINE_FIRMWARE}"
MACHINE_EXTRA_RRECOMMENDS += "fsl-alsa-plugins"

# Flash image types
SDCARD_ROOTFS ?= "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.ext4"
IMAGE_FSTYPES ?= "boot.vfat ext4 sdcard tar.bz2"

#
# Supported variants
#
# Maintain in sync with the same table in platform local.conf template.
#
# Name        WiFi[w]    BT[b]    Proc[q|dl]      DDR[2048|1024|512]
# ----------------------------------------------------------------------
# wbq1024        Y         Y      quad/dual          1024MiB       (0x01,0x02,0x04,0x11)
# wbq512         Y         Y      quad/dual           512MiB       (0x03,0x06)
# wq1024         Y         N      quad/dual          1024MiB       (0x05)
# q512           N         N      quad/dual           512MiB       (0x08,0x0E,0x0F)
# wdl512         Y         N      duallite/solo       512MiB       (0x0A)
# wbdl1024       Y         Y      duallite/solo      1024MiB       (0x0B)
# dl512          N         N      duallite/solo       512MiB       (0x0C)
# wbq2048        Y         Y      quad/dual          2048MiB       (0x12)

# All variants support
MACHINE_FEATURES += "accel-graphics accel-video"

# Per-variant machine features
MACHINE_FEATURES_append_wbq1024 = " wifi bluetooth"
MACHINE_FEATURES_append_wbq512 = " wifi bluetooth"
MACHINE_FEATURES_append_wq1024 = " wifi"
MACHINE_FEATURES_append_q512 = ""
MACHINE_FEATURES_append_wdl512 = " wifi"
MACHINE_FEATURES_append_wbdl1024 = " wifi bluetooth"
MACHINE_FEATURES_append_dl512 = ""
MACHINE_FEATURES_append_wbq2048 = " wifi bluetooth"

# Per-variant u-boot configuration
UBOOT_MACHINE = ""
UBOOT_MACHINE_wbq1024 = "ccimx6qsbc_config"
UBOOT_MACHINE_wbq512 = "ccimx6qsbc512MB_config"
UBOOT_MACHINE_wq1024 = "ccimx6qsbc_config"
UBOOT_MACHINE_q512 = "ccimx6qsbc512MB_config"
UBOOT_MACHINE_wdl512 = "ccimx6dlsbc512MB_config"
UBOOT_MACHINE_wbdl1024 = "ccimx6dlsbc_config"
UBOOT_MACHINE_dl512 = "ccimx6dlsbc512MB_config"
UBOOT_MACHINE_wbq2048 = "ccimx6qsbc2GB_config"

# Per-variant cpu family
CPU_FAMILY = ""
CPU_FAMILY_wbq1024 = "mx6q"
CPU_FAMILY_wbq512 = "mx6q"
CPU_FAMILY_wq1024 = "mx6q"
CPU_FAMILY_q512 = "mx6q"
CPU_FAMILY_wdl512 = "mx6dl"
CPU_FAMILY_wbdl1024 = "mx6dl"
CPU_FAMILY_dl512 = "mx6dl"
CPU_FAMILY_wbq2048 = "mx6q"

# Per-variant device tree
DTB_VARIANT_STR = ""
DTB_VARIANT_STR_wbq1024 = "-wb"
DTB_VARIANT_STR_wbq512 = "-wb"
DTB_VARIANT_STR_wq1024 = "-w"
DTB_VARIANT_STR_q512 = "-z"
DTB_VARIANT_STR_wdl512 = "-mw"
DTB_VARIANT_STR_wbdl1024 = "-mwb"
DTB_VARIANT_STR_dl512 = "-m"
DTB_VARIANT_STR_wbq2048 = "-wb"
