inherit image_types

# Dynamically calculate max LEB count for UBIFS images
FLASH_MLC = "${@max_leb_count(d)}"
def max_leb_count(d):
    _mlc = []
    _flash_peb = d.getVar('FLASH_PEB', True)
    _flash_psz = d.getVar('FLASH_PSZ', True)
    for i in _flash_peb.split(','):
        _mlc.append(str(next_power_of_2(int(_flash_psz)/int(i)) - 1))
    return ','.join(_mlc)

# Return next power_of_2 bigger than passed argument
def next_power_of_2(n):
    i = 1
    while (n > i):
        i <<= 1
    return i

# Return TRUE if jffs2 is not in IMAGE_FSTYPES
JFFS2_NOT_IN_FSTYPES = "${@jffs2_not_in_fstypes(d)}"
def jffs2_not_in_fstypes(d):
    return str('jffs2' not in d.getVar('IMAGE_FSTYPES', True).split()).lower()

IMAGE_CMD_jffs2() {
	nimg="$(echo ${FLASH_PEB} | awk -F, '{print NF}')"
	for i in $(seq 1 ${nimg}); do
		peb_it="$(echo ${FLASH_PEB} | cut -d',' -f${i})"
		# Do not use '-p (padding)' option. It breaks 'ccardimx28js' flash images [JIRA:DEL-218]
		mkfs.jffs2 -n -e ${peb_it} -d ${IMAGE_ROOTFS} -o ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.${peb_it}.rootfs.jffs2
		ln -sf ${IMAGE_NAME}.${peb_it}.rootfs.jffs2 ${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.${peb_it}.jffs2
	done
}

# The CWD for this set of commads is DEPLOY_DIR_IMAGE so the paths are relative to it.
COMPRESS_CMD_sum() {
	# 'nimg' is set in IMAGE_CMD_jffs2 (which is executed just before)
	for i in $(seq 1 ${nimg}); do
		peb_it="$(echo ${FLASH_PEB} | cut -d',' -f${i})"
		sumtool -e ${peb_it} -i ${IMAGE_NAME}.${peb_it}.rootfs.jffs2 -o ${IMAGE_NAME}.${peb_it}.rootfs.jffs2.sum
		ln -sf ${IMAGE_NAME}.${peb_it}.rootfs.jffs2.sum ${IMAGE_LINK_NAME}.${peb_it}.jffs2.sum

		# If 'jffs2' is not in IMAGE_FSTYPES remove the images and symlinks
		if ${JFFS2_NOT_IN_FSTYPES}; then
			rm -f ${IMAGE_NAME}.${peb_it}.rootfs.jffs2 ${IMAGE_LINK_NAME}.${peb_it}.jffs2
		fi
	done

	# Create dummy file so the final script can remove it and not fail
	if ${JFFS2_NOT_IN_FSTYPES}; then
		touch ${IMAGE_NAME}.rootfs.jffs2
	fi
}

IMAGE_CMD_ubifs() {
	nimg="$(echo ${FLASH_PEB} | awk -F, '{print NF}')"
	for i in $(seq 1 ${nimg}); do
		mlc_it="$(echo ${FLASH_MLC} | cut -d',' -f${i})"
		peb_it="$(echo ${FLASH_PEB} | cut -d',' -f${i})"
		leb_it="$(echo ${FLASH_LEB} | cut -d',' -f${i})"
		mio_it="$(echo ${FLASH_MIO} | cut -d',' -f${i})"
		mkfs.ubifs -r ${IMAGE_ROOTFS} -o ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.${peb_it}.rootfs.ubifs -m ${mio_it} -e ${leb_it} -c ${mlc_it} ${MKUBIFS_ARGS}
		ln -sf ${IMAGE_NAME}.${peb_it}.rootfs.ubifs ${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.${peb_it}.ubifs
	done
}

IMAGE_DEPENDS_boot.vfat = " \
    dosfstools-native:do_populate_sysroot \
    mtools-native:do_populate_sysroot \
    u-boot:do_deploy \
    virtual/kernel:do_deploy \
"

IMAGE_CMD_boot.vfat() {
	#
	# Image generation code for image type 'boot.vfat'
	#
	BOOTIMG_FILES="$(readlink -e ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${MACHINE})"
	BOOTIMG_FILES_SYMLINK="${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${MACHINE}.bin"
	if [ -n "${KERNEL_DEVICETREE}" ]; then
		for DTB in ${KERNEL_DEVICETREE}; do
			if [ -e "${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${DTB}" ]; then
				BOOTIMG_FILES="${BOOTIMG_FILES} $(readlink -e ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${DTB})"
				BOOTIMG_FILES_SYMLINK="${BOOTIMG_FILES_SYMLINK} ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${DTB}"
			fi
		done
	fi

	# Size of kernel and device tree + 10% extra space (in bytes)
	BOOTIMG_FILES_SIZE="$(expr $(du -bc ${BOOTIMG_FILES} | tail -n1 | cut -f1) \* \( 100 + 10 \) / 100)"

	# 1KB blocks for mkfs.vfat
	BOOTIMG_BLOCKS="$(expr ${BOOTIMG_FILES_SIZE} / 1024)"
	if [ -n "${BOARD_BOOTIMAGE_PARTITION_SIZE}" ]; then
		BOOTIMG_BLOCKS="${BOARD_BOOTIMAGE_PARTITION_SIZE}"
	fi

	# POKY: Ensure total sectors is a multiple of sectors per track or mcopy will
	# complain. Blocks are 1024 bytes, sectors are 512 bytes, and we generate
	# images with 32 sectors per track. This calculation is done in blocks, thus
	# the use of 16 instead of 32.
	BOOTIMG_BLOCKS="$(expr \( \( ${BOOTIMG_BLOCKS} + 15 \) / 16 \) \* 16)"

	# Build VFAT boot image and copy files into it
	mkfs.vfat -n "Boot ${MACHINE}" -S 512 -C ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.boot.vfat ${BOOTIMG_BLOCKS}
	mcopy -i ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.boot.vfat ${BOOTIMG_FILES_SYMLINK} ::/

	# Copy boot scripts into the VFAT image
	for item in ${BOOT_SCRIPTS}; do
		src=`echo $item | awk -F':' '{ print $1 }'`
		dst=`echo $item | awk -F':' '{ print $2 }'`
		mcopy -i ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.boot.vfat -s ${DEPLOY_DIR_IMAGE}/$src ::/$dst
	done

	# Truncate the image to speed up the downloading/writing to the EMMC
	if [ -n "${BOARD_BOOTIMAGE_PARTITION_SIZE}" ]; then
		# U-Boot writes 512 bytes sectors so truncate the image at a sector boundary
		truncate -s $(expr \( \( ${BOOTIMG_FILES_SIZE} + 511 \) / 512 \) \* 512) ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.boot.vfat
	fi

        # Create the symlink
	if [ -n "${IMAGE_LINK_NAME}" ] && [ -e ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.boot.vfat ]; then
		ln -s ${IMAGE_NAME}.boot.vfat ${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.boot.vfat
	fi
}

# Set alignment to 4MB [in KiB]
IMAGE_ROOTFS_ALIGNMENT = "4096"

IMAGE_DEPENDS_sdcard = " \
    dosfstools-native:do_populate_sysroot \
    mtools-native:do_populate_sysroot \
    parted-native:do_populate_sysroot \
    u-boot:do_deploy \
    virtual/kernel:do_deploy \
"

# SD card image name
SDIMG = "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.sdcard"

SDIMG_BOOTFS_TYPE ?= "boot.vfat"
SDIMG_BOOTFS = "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.${SDIMG_BOOTFS_TYPE}"
SDIMG_ROOTFS_TYPE ?= "ext4"
SDIMG_ROOTFS = "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.${SDIMG_ROOTFS_TYPE}"

#
# Create an image that can by written onto a SD card using dd.
#
# The disk layout used is:
#
#   1. Not partitioned  : reserved for bootloader (u-boot)
#   2. BOOT PARTITION   : kernel and device tree blobs
#   3. ROOTFS PARTITION : rootfs
#
#       4MiB            BOOT_SPACE                 ROOTFS_SIZE
#  <------------> <--------------------> <------------------------------>
# +--------------+----------------------+--------------------------------+
# | U-BOOT (RAW) | BOOT PARTITION (FAT) | ROOTFS PARTITION (EXT4)        |
# +--------------+----------------------+--------------------------------+
# ^              ^                      ^                                ^
# |              |                      |                                |
# 0            4MiB             4MiB + BOOT_SPACE                   SDIMG_SIZE
#
IMAGE_CMD_sdcard() {
	# Align boot partition and calculate total sdcard image size
	BOOT_SPACE_ALIGNED="$(expr \( \( ${BOARD_BOOTIMAGE_PARTITION_SIZE} + ${IMAGE_ROOTFS_ALIGNMENT} - 1 \) / ${IMAGE_ROOTFS_ALIGNMENT} \) \* ${IMAGE_ROOTFS_ALIGNMENT})"
	SDIMG_SIZE="$(expr ${IMAGE_ROOTFS_ALIGNMENT} + ${BOOT_SPACE_ALIGNED} + $ROOTFS_SIZE)"

	# Initialize sdcard image file
	dd if=/dev/zero of=${SDIMG} bs=1024 count=0 seek=${SDIMG_SIZE}

	# Create partition table, boot partition (with bootable flag) and rootfs partition (to the end of the disk)
	parted -s ${SDIMG} mklabel msdos
	parted -s ${SDIMG} unit KiB mkpart primary fat32 ${IMAGE_ROOTFS_ALIGNMENT} $(expr ${IMAGE_ROOTFS_ALIGNMENT} \+ ${BOOT_SPACE_ALIGNED})
	parted -s ${SDIMG} set 1 boot on
	parted -s ${SDIMG} -- unit KiB mkpart primary ext2 $(expr ${IMAGE_ROOTFS_ALIGNMENT} \+ ${BOOT_SPACE_ALIGNED}) -1s
	parted -s ${SDIMG} unit KiB print

	# Burn bootloader, boot and rootfs partitions
	dd if=${DEPLOY_DIR_IMAGE}/${UBOOT_SYMLINK} of=${SDIMG} conv=notrunc,fsync seek=2 bs=512
	dd if=${SDIMG_BOOTFS} of=${SDIMG} conv=notrunc,fsync seek=1 bs=$(expr ${IMAGE_ROOTFS_ALIGNMENT} \* 1024)
	dd if=${SDIMG_ROOTFS} of=${SDIMG} conv=notrunc,fsync seek=1 bs=$(expr ${IMAGE_ROOTFS_ALIGNMENT} \* 1024 + ${BOOT_SPACE_ALIGNED} \* 1024)
}

# The sdcard image requires the boot and rootfs images to be built before
IMAGE_TYPEDEP_sdcard = "${SDIMG_BOOTFS_TYPE} ${SDIMG_ROOTFS_TYPE}"
