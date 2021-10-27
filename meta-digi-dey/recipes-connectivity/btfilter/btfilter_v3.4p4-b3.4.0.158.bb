# Copyright (C) 2013-2021 Digi International.

SUMMARY = "Atheros BT/wlan coexistance daemon"
SECTION = "network"
LICENSE = "ISC"
LIC_FILES_CHKSUM = "file://Makefile;beginline=1;endline=14;md5=8f6614b37751445a5f6a9bdc69be26b3"

inherit bluetooth

DEPENDS = "${BLUEZ} dbus libnl"

PR = "${DISTRO}.r0"

SRC_URI = "${DIGI_PKG_SRC}/${PN}-${PV}.tar.bz2 \
	   file://0001-enable-libnl3.patch \
	   file://0002-cross-compile.patch \
	   file://0003-abtfilt_wan-Rewrite-the-netlink-listener.patch \
	   ${@bb.utils.contains('DISTRO_FEATURES', 'bluez4', 'file://bluez-init', '', d)}"

SRC_URI[md5sum] = "06a26d3a368c33b508d660ea84d476ee"
SRC_URI[sha256sum] = "b1af73003b622189b66d51911d429d6d205ac9227ec8278c8572ca0c68c7d5f3"

inherit update-rc.d

EXTRA_OEMAKE = "INCLUDES=-I${STAGING_INCDIR}/bluetooth"

do_install() {
	install -d ${D}${bindir} ${D}${sysconfdir}/init.d/
	install -m 0755 abtfilt ${D}${bindir}
	if ${@bb.utils.contains('DISTRO_FEATURES', 'bluez4', 'true', 'false', d)}; then
		install -m 0755 ${WORKDIR}/bluez-init ${D}${sysconfdir}/init.d/bluez
	fi
}

INITSCRIPT_NAME = "bluez"
INITSCRIPT_PARAMS = "start 10 5 ."
