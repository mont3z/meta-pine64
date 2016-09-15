#
# sunxitools-native.bb
# 

DESCRIPTION = "Sunxi Pack Tools"
LICENSE = "GPLv2"

inherit native

SRCREV="${AUTOREV}"

LIC_FILES_CHKSUM = 'file://LICENSE.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263'

SRC_URI = "git://github.com/mont3z/sunxi-pack-tools.git;protocol=git;branch=master"

S = "${WORKDIR}/git"

FILES_${PN} = "${bindir}/*"

do_install() {
	install -m 755 ${S}/bin/merge_uboot ${bindir}/merge_uboot_${MACHINE}
        install -m 755 ${S}/bin/script ${bindir}/script_${MACHINE}
        install -m 755 ${S}/bin/update_uboot ${bindir}/update_uboot_${MACHINE}
        install -m 755 ${S}/bin/update_uboot_fdt ${bindir}/update_uboot_fdt_${MACHINE}
}

