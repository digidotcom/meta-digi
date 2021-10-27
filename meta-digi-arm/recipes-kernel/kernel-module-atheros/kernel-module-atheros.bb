# Copyright (C) 2013-2021 Digi International.

SUMMARY = "Atheros's wireless driver"
LICENSE = "ISC"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/ISC;md5=f3b90e78ea0cffb20bf5cca7947a896d"

inherit module

SRCREV_external = "9b0b4e474bca44106f2ffa3e1c4bea21519da9a6"
SRCREV_internal = "50dafb5890180cf33fdb42919c3e6f591d0cd2ea"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/atheros.git;protocol=git;nobranch=1"
SRC_URI_internal = "${DIGI_GIT}linux-modules/atheros.git;protocol=git;nobranch=1"
SRC_URI  = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"
SRC_URI += " \
    file://81-sdio-atheros.rules \
    file://atheros.sh \
    file://Makefile \
    ${@base_conditional('IS_KERNEL_2X', '1' , '', 'file://0001-atheros-convert-NLA_PUT-macros.patch', d)} \
    ${@base_conditional('IS_KERNEL_2X', '1' , '', 'file://0002-atheros-update-renamed-struct-members.patch', d)} \
    file://fw-4.bin \
"

S = "${WORKDIR}/git"

EXTRA_OEMAKE = "DEL_PLATFORM=${MACHINE} KLIB_BUILD=${STAGING_KERNEL_DIR}"

do_configure_prepend() {
	cp ${WORKDIR}/Makefile ${S}/
}

do_install_append() {
	install -d ${D}${sysconfdir}/udev/rules.d ${D}${sysconfdir}/udev/scripts
	install -m 0644 ${WORKDIR}/81-sdio-atheros.rules ${D}${sysconfdir}/udev/rules.d/
	install -m 0755 ${WORKDIR}/atheros.sh ${D}${sysconfdir}/udev/scripts/atheros.sh
	install -d ${D}${sysconfdir}/modprobe.d
	cat >> ${D}${sysconfdir}/modprobe.d/atheros.conf <<-_EOF_
		blacklist ath6kl_sdio
		options ath6kl_sdio ath6kl_p2p=1 softmac_enable=1
	_EOF_
}

FILES_${PN} += " \
    ${sysconfdir}/udev/ \
    ${sysconfdir}/modprobe.d/ \
"

# 'modprobe' from kmod package is needed to load atheros driver. The one
# from busybox does not support '--ignore-install' option.
RDEPENDS_${PN} = "kmod"

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(ccardimx28|ccimx6)"
