#
# Install boot0
#
DESCRIPTION = "Closed source binary file to help boot A64 on the pine64."
LICENSE = "CLOSED"

inherit deploy

COMPATIBLE_MACHINE = "pine64"
SRCREV="${AUTOREV}"

SRC_URI = "https://github.com/longsleep/build-pine64-image/raw/master/blobs/boot0.bin;name=boot0"

SRC_URI[boot0.md5sum] = "95c2a9947cde355dd8d23543b09351a4"
SRC_URI[boot0.sha256sum] = "51982495732baececffb026e424a4ad680226537ed6bac370975678d2e5f3611"

S = "${WORKDIR}"

do_configure() {
	:
}

do_install() {
	:
}

do_deploy() {
	install -m 0755 ${WORKDIR}/boot0.bin ${DEPLOYDIR}
}

addtask deploy before do_package after do_install

PACKAGE_ARCH = "${MACHINE_ARCH}"

