# Copyright (C) 2013-2017 Digi International.

SUMMARY = "Redpine's wireless driver"
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://RS.GENR.LNX.SD_GPL/include/ganges_faf.h;endline=6;md5=2b5a9aab5291bd86a1103ca1165f9afa"

inherit module

PR = "${DISTRO}.r0"

SRCREV = "08c371ab31ccfdc689f39d7093199df2305f92bb"
SRCREV_SHORT = "${@'${SRCREV}'[:7]}"

# Checksums for 'redpine-${MACHINE}-${SRCREV_SHORT}.tar.gz' tarballs
TARBALL_MD5_ccimx51js    = "1ce383a9fef23a83bf35a2aecf84f006"
TARBALL_SHA256_ccimx51js = "7499bed6b3aed98db7958e79c89068cf72d1566b63c57786fd9271c3f302d285"
TARBALL_MD5_ccimx53js    = "efb468075924f287bb7e47ae0cc9c685"
TARBALL_SHA256_ccimx53js = "74a7ac0b6dad27a50ed909377460e5933435b2249f19ca3e09ef9dda0182e32e"

SRC_URI_git = "${DIGI_GIT}linux-modules/redpine.git;protocol=git"
SRC_URI_obj = "${DIGI_PKG_SRC}/redpine-${MACHINE}-${SRCREV_SHORT}.tar.gz;md5sum=${TARBALL_MD5};sha256sum=${TARBALL_SHA256}"
SRC_URI  = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_git}', '${SRC_URI_obj}', d)}"
SRC_URI += " \
    file://Makefile \
    file://redpine \
"

S = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${WORKDIR}/git', '${WORKDIR}/${MACHINE}', d)}"

EXTRA_OEMAKE = "DEL_PLATFORM=${MACHINE}"

do_configure_prepend() {
	cp ${WORKDIR}/Makefile ${S}/
}

do_install_append() {
	install -d ${D}${sysconfdir}/network/if-pre-up.d
	install -m 0755 ${WORKDIR}/redpine ${D}${sysconfdir}/network/if-pre-up.d/
}

# Deploy objects tarball if building from sources
do_deploy() {
	if [ "${DIGI_INTERNAL_GIT}" = "1" ]; then
		oe_runmake tarball
		install -d ${DEPLOY_DIR_IMAGE}
		if [ -f "${S}/redpine-${MACHINE}-${SRCREV_SHORT}.tar.gz" ]; then
			cp ${S}/redpine-${MACHINE}-${SRCREV_SHORT}.tar.gz ${DEPLOY_DIR_IMAGE}/
		else
			bberror "Objects tarball not found: ${S}/redpine-${MACHINE}-${SRCREV_SHORT}.tar.gz"
			exit 1
		fi
	fi
}

addtask deploy before do_build after do_install

FILES_${PN} += " \
    ${base_libdir}/firmware/ \
    ${sysconfdir}/network/ \
"

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(mx5)"
