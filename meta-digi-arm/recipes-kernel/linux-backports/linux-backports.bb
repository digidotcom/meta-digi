# Copyright (C) 2022 Digi International.

DESCRIPTION = "Linux Backports"
HOMEPAGE = "https://backports.wiki.kernel.org"
SECTION = "kernel/modules"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

PV = "3.12.8-1"

BACKPORTS_VERSION = "v3.12.8-1-0-geb41fad"
BACKPORTED_KERNEL_VERSION = "v3.12.8-0-g97f15f1"
BACKPORTED_KERNEL_NAME = "Linux"

SRC_URI = " \
    https://www.kernel.org/pub/linux/kernel/projects/backports/stable/v3.12.8/backports-${PV}.tar.gz \
    file://0001-cfg80211-backports-3.12.8-1.patch \
    file://backports-defconfig \
"
SRC_URI[md5sum] = "e8bf2cab35510ad6e554326b46263d7e"
SRC_URI[sha256sum] = "bb5a3ed21b462bedc639f20cf53c77aaa04c7d65818113eef8942b6d83889434"

S = "${WORKDIR}/backports-${PV}"

EXTRA_OEMAKE = " \
    KLIB_BUILD=${STAGING_KERNEL_DIR} \
    KLIB=${D} \
    DESTDIR=${D} \
"

DEPENDS += "virtual/kernel"

inherit module-base

addtask make_scripts after do_patch before do_compile
do_make_scripts[lockfiles] = "${TMPDIR}/kernel-scripts.lock"
do_make_scripts[deptask] = "do_populate_sysroot"

BACKPORTS_CONFIG = "backports-defconfig"
MAKE_TARGETS = "modules"

do_configure_prepend() {
	unset CXXFLAGS
	cp ${WORKDIR}/${BACKPORTS_CONFIG} ${S}/.config
	CC=${BUILD_CC} oe_runmake -C kconf conf
}

do_compile() {
	unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
	bbnote "Build Linux backports module for ${KERNEL_VERSION}"
	oe_runmake ${MAKE_TARGETS}
}

do_install() {
	# Linux backports binaries
	install -d ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra
	install -m 0644 ${S}/compat/compat.ko ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/compat.ko
	install -m 0644 ${S}/net/wireless/cfg80211.ko ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/cfg80211.ko
}

QCA_BUILD_DIR = "${WORKDIR}/qcacld"

# The repo is stored in the digi-embedded GitHub page, not the digidotcom one
DIGI_GITHUB_GIT = "https://github.com/digi-embedded"

QCOM_GIT_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${DIGI_MTK_GIT}linux/qcacld-2.0.git;protocol=ssh', '${DIGI_GITHUB_GIT}/qcacld-2.0.git', d)}"

SRCBRANCH = "dey-2.2/maint"
SRCREV_qcacld = "${AUTOREV}"

SRC_URI_append = " \
    ${QCOM_GIT_URI};branch=${SRCBRANCH};destsuffix=qcacld;name=qcacld \
    file://0002-qcacld-2.6.35.14-kernel-support.patch;patchdir=${QCA_BUILD_DIR}  \
    file://0003-qcacld-Fix-initialization-timeout-for-setup-file.patch;patchdir=${QCA_BUILD_DIR} \
    file://0004-qcacld-2.0-add-module-parameter-to-enable-the-p2p-in.patch;patchdir=${QCA_BUILD_DIR} \
    file://81-sdio-qcom.rules \
    file://modprobe-qualcomm.conf \
    file://qualcomm.sh \
"

BUILD_VER = "v4.2.80.63"

QCA_EXTRA_OEMAKE = " \
    CONFIG_CLD_HL_SDIO_CORE=y \
    CONFIG_LINUX_QCMBR=y \
    WLAN_OPEN_SOURCE=1 \
    CONFIG_NON_QC_PLATFORM=y \
    CONFIG_CFG80211=m \
    BUILD_DEBUG_VERSION=0 \
"

do_compile_append() {
	unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
	bbnote "Build External QCACLD-2.0 Wireless module for ${KERNEL_VERSION}"
	cd ${QCA_BUILD_DIR}

	export NOSTDINC_FLAGS=" \
		-I${S}/backport-include/ \
		-I${S}/backport-include/uapi \
		-I${S}/include/ \
		-I${S}/include/uapi \
		-I${S}/include/drm \
		-include ${S}/backport-include/backport/backport.h \
		-DBACKPORTS_VERSION=\\\"${BACKPORTS_VERSION}\\\" \
		-DBACKPORTED_KERNEL_VERSION=\\\"${BACKPORTED_KERNEL_VERSION}\\\" \
		-DBACKPORTED_KERNEL_NAME=\\\"${BACKPORTED_KERNEL_NAME}\\\" \
	"

	oe_runmake KERNEL_SRC=${STAGING_KERNEL_DIR} \
		   KERNEL_VERSION=${KERNEL_VERSION} \
		   BUILD_VER=${BUILD_VER} \
		   KBUILD_EXTRA_SYMBOLS=${S}/Module.symvers \
		   ${QCA_EXTRA_OEMAKE}
}

do_install_append() {
	# Qualcomm Wireless driver binaries
	install -d ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra
	install -m 0644 ${QCA_BUILD_DIR}/wlan.ko ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/wlan.ko
	install -d ${D}${sysconfdir}/modprobe.d
	install -m 0644 ${WORKDIR}/modprobe-qualcomm.conf ${D}${sysconfdir}/modprobe.d/qualcomm.conf
	install -d ${D}${base_libdir}/firmware/wlan/
	install -m 0644 ${QCA_BUILD_DIR}/firmware_bin/WCNSS_cfg.dat ${D}${base_libdir}/firmware/wlan/cfg.dat
	install -m 0644 ${QCA_BUILD_DIR}/firmware_bin/WCNSS_qcom_cfg.ini ${D}${base_libdir}/firmware/wlan/qcom_cfg.ini
	install -d ${D}${sysconfdir}/udev/rules.d ${D}${sysconfdir}/udev/scripts
	install -m 0644 ${WORKDIR}/81-sdio-qcom.rules ${D}${sysconfdir}/udev/rules.d/
	install -m 0755 ${WORKDIR}/qualcomm.sh ${D}${sysconfdir}/udev/scripts/
}

FILES_${PN} += " \
    ${sysconfdir}/udev \
    ${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra \
    ${sysconfdir}/modprobe.d/qualcomm.conf \
    ${base_libdir}/firmware/wlan/cfg.dat \
    ${base_libdir}/firmware/wlan/qcom_cfg.ini \
"

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(ccardimx28js)"
