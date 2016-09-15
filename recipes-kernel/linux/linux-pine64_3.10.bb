# This file was derived from the linux-yocto-custom.bb recipe in
# oe-core.
#
# linux-pine64_3.10.bb:
#
#   This recipe compiles a longsleep linux kernel for pine64
#

inherit kernel
require recipes-kernel/linux/linux-yocto.inc

KBRANCH = "pine64-hacks-1.2"

SRC_URI = "git://github.com/longsleep/linux-pine64.git;protocol=git;nocheckout=1;branch=${KBRANCH} "
SRC_URI += "file://defconfig "

KERNEL_DEVICETREE ?= "pine64.dtb pine64noplus.dtb"
S = "${WORKDIR}/git"

LINUX_VERSION = "3.10"
LINUX_VERSION_EXTENSION = "-pine64"

SRCREV="${AUTOREV}"
PV = "${LINUX_VERSION}"

KERNEL_IMAGETYPE="Image"

COMPATIBLE_MACHINE_pine64 = "pine64"

# Add dts files to kernel tree
do_configure_prepend() {
	install -d ${WORKDIR}/arch/arm64/boot/dts/
	cp ${THISDIR}/files/pine64.dts ${S}/arch/arm64/boot/dts/
	cp ${THISDIR}/files/pine64noplus.dts ${S}/arch/arm64/boot/dts/ 
}
