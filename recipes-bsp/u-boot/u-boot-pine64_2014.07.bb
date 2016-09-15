#
# u-boot-pine64_2014.07.bb:
#
#   This recipe compiles u-boot from longsleep repository
#

DESCRIPTION="U-boot from longsleep repository"

require recipes-bsp/u-boot/u-boot.inc
DEPENDS += "arm-trusted-firmware sunxitools-native dtc-native"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = 'file://Licenses/README;md5=025bf9f768cbcb1a165dbe1a110babfb'

# Hack to compile using 32bit toolchain
LINARO_EABIHF_PATH ?= "/opt/gcc-linaro-gnueabihf"
export PATH =. "${LINARO_EABIHF_PATH}/bin:"
UBOOT_ARCH_pine64 = "arm"
PACKAGE_ARCH = "armv7a"
EXTRA_OEMAKE = 'ARCH="${UBOOT_ARCH}" CROSS_COMPILE=arm-linux-gnueabihf-'

UBOOT_REPO ?= "git://github.com/longsleep/u-boot-pine64.git"
UBOOT_BRANCH ?= "pine64-hacks"
UBOOT_PROT ?= "git"

SRC_URI = "${UBOOT_REPO};protocol=${UBOOT_PROT};branch=${UBOOT_BRANCH}"
SRC_URI += "file://boot.cmd"

SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"
COMPATIBLE_MACHINE = "pine64"
UBOOT_MACHINE_pine64 = "sun50iw1p1_config"

SPL_BINARY="u-boot-with-dtb.bin"

UBOOT_ENV_SUFFIX = "scr"
UBOOT_ENV = "boot"

do_compile[depends] = "sunxitools-native:do_install"
do_compile[depends] += "arm-trusted-firmware:do_build" 

do_compile_append() {
	# build binary device tree
	cp ${THISDIR}/${PN}/pine64.dts ${S}
	dtc -Odtb -o ${S}/pine64.dtb ${S}/pine64.dts

	cp ${THISDIR}/${PN}/sys_config.fex ${S}
	# unix2dos conversion
	sed -i -e 's/\r*$/\r/' ${S}/sys_config.fex
	script_${MACHINE} ${S}/sys_config.fex

	# merge_uboot.exe u-boot.bin infile outfile mode[secmonitor|secos|scp]
	cp ${STAGING_LOADER_DIR}/bl31-${MACHINE}.bin ${S}
	cp ${THISDIR}/${PN}/scp.bin ${S}
	merge_uboot_${MACHINE} u-boot.bin bl31-${MACHINE}.bin u-boot-merged.bin secmonitor
	merge_uboot_${MACHINE} u-boot-merged.bin scp.bin u-boot-merged2.bin scp

	# update_fdt.exe u-boot.bin xxx.dtb output_file.bin
	update_uboot_fdt_${MACHINE} u-boot-merged2.bin pine64.dtb u-boot-with-dtb.bin

	# Add fex file to u-boot so it actually is accepted by boot0.
	update_uboot_${MACHINE} u-boot-with-dtb.bin sys_config.bin
	cp ${S}/u-boot-with-dtb.bin ${WORKDIR}

	# Translate boot.cmd to a boot.scr by using the mkimage command 
	${S}/tools/mkimage -C none -A arm -T script -d ${WORKDIR}/boot.cmd ${WORKDIR}/${UBOOT_ENV_BINARY}
}

