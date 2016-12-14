inherit image_types

#
# Create an image that can by written onto a SD card using dd.
# Based on rasberrypi sdimg and adapt for pine64 needs  
#
# The disk layout used is:
#
#    0                     			-> reserverd
#    8 KiB                  			-> boot0  
#    19096 KiB              			-> u-boot 
#    20480 KiB              			-> BOOT_SPACE - kernel
#    20480 KiB + 50 MiB (rounded by 4096)	-> rootfs
#

# This image depends on the rootfs image
IMAGE_TYPEDEP_pine64-sdimg = "${SDIMG_ROOTFS_TYPE}"

# Boot partition volume id
BOOTDD_VOLUME_ID = "${MACHINE}"

# Positions in KiB
BOOT0_POSITION = "8" 
UBOOT_POSITION = "19096" 
BOOT_POSITION = "20480"

# Size in MiB
BOOT_SIZE = "50"

# Use an uncompressed ext3 by default as rootfs
SDIMG_ROOTFS_TYPE = "ext3"
SDIMG_ROOTFS = "${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.${SDIMG_ROOTFS_TYPE}"
# SDIMG_ROOTFS = "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.${SDIMG_ROOTFS_TYPE}"
# ALT_SDIMG_ROOTFS = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}.${SDIMG_ROOTFS_TYPE}"
#SDIMG_ROOTFS = "${DEPLOY_DIR_IMAGE}/${LOCALEBASEPN}-${MACHINE}.${SDIMG_ROOTFS_TYPE}"

IMAGE_DEPENDS_pine64-sdimg += " \
			parted-native \
			mtools-native \
			dosfstools-native \
			virtual/kernel \
			virtual/bootloader \
			boot0 \
			"

rootfs[depends] += "virtual/kernel:do_deploy"

# SD card image name
SDIMG = "${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.pine64-sdimg"

IMAGE_CMD_pine64-sdimg () {
        # Align partitions
	ROOTFS_ALIGNMENT=4096
	ROOTFS_POSITION=$(expr ${BOOT_POSITION} \+ ${BOOT_SIZE} \* 1024)
	ROOTFS_DELTA=$(expr ${ROOTFS_ALIGNMENT} - ${ROOTFS_POSITION} % ${ROOTFS_ALIGNMENT})
	ROOTFS_POSITION=$(expr ${ROOTFS_POSITION} \+ ${ROOTFS_DELTA})
	
	SDIMG_SIZE=$(expr ${ROOTFS_POSITION} \+ $ROOTFS_SIZE \+ ${ROOTFS_ALIGNMENT})

	# Initialize sdcard image file
	dd if=/dev/zero of=${SDIMG} bs=1 count=0 seek=$(expr 1024 \* ${SDIMG_SIZE})

	# Create partition table
	parted -s ${SDIMG} mklabel msdos
	# Create boot partition and mark it as bootable
	parted -s ${SDIMG} unit KiB mkpart primary fat32 ${BOOT_POSITION} ${ROOTFS_POSITION}
	parted -s ${SDIMG} set 1 boot on
	# Create rootfs partition
	parted -s ${SDIMG} unit KiB mkpart primary ext3 ${ROOTFS_POSITION} $(expr ${ROOTFS_POSITION} \+ $ROOTFS_SIZE)
	parted ${SDIMG} print

	# Create a vfat image with boot files
	BOOT_BLOCKS=$(LC_ALL=C parted -s ${SDIMG} unit b print | awk '/ 1 / { print substr($4, 1, length($4 -1)) / 512 /2 }')
	rm -f ${WORKDIR}/boot.img
	mkfs.vfat -n "${BOOTDD_VOLUME_ID}" -S 512 -C ${WORKDIR}/boot.img $BOOT_BLOCKS

	mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${MACHINE}.bin ::Image

	# Copy device tree files
	if test -n "${KERNEL_DEVICETREE}"; then
		for DTB_FILE in ${KERNEL_DEVICETREE}; do
			if [ -e "${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${DTB_FILE}" ]; then
				mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${DTB_FILE} ::${DTB_FILE}
			fi
		done
	fi

	if [ -e "${DEPLOY_DIR_IMAGE}/boot-${MACHINE}.scr" ]
	then
		mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/boot-${MACHINE}.scr ::boot.scr
	fi

	# Burn Partitions
	dd if=${WORKDIR}/boot.img of=${SDIMG} conv=notrunc seek=1 bs=$(expr ${BOOT_POSITION} \* 1024) && sync && sync
	# Write rootfs
	if [ -e ${SDIMG_ROOTFS} ]; then
		dd if=${SDIMG_ROOTFS} of=${SDIMG} conv=notrunc seek=1 bs=$(expr ${ROOTFS_POSITION} \* 1024) && sync && sync
	else
		bbfatal "No rootfs image found. Looked for ${SDIMG_ROOTFS}"
	fi

	#write boot0 at the beginning of sdimage 
	dd if=${DEPLOY_DIR_IMAGE}/boot0.bin of=${SDIMG} conv=notrunc seek=1 bs=$(expr ${BOOT0_POSITION} \* 1024) && sync && sync

	#write u-boot  
	dd if=${DEPLOY_DIR_IMAGE}/u-boot-with-dtb.bin of=${SDIMG} conv=notrunc seek=1 bs=$(expr ${UBOOT_POSITION} \* 1024) && sync && sync 
}
