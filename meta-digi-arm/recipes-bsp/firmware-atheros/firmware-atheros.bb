# Copyright (C) 2013 Digi International.

SUMMARY = "Firmware files for Digi's platforms, such as Atheros bluetooth."
SECTION = "base"
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${DIGI_EULA_FILE};md5=4c0991cfde5c8a92338cbfe0f4f9a5c6"

PR = "${DISTRO}.r0"

SRC_URI = " \
    file://PS_ASIC_class_1.pst \
    file://PS_ASIC_class_2.pst \
    file://RamPatch.txt \
    file://readme.txt \
"

S = "${WORKDIR}"

do_install() {
	install -d ${D}${base_libdir}/firmware/ar3k/1020200
	install -m 0644 PS_ASIC_class_1.pst PS_ASIC_class_2.pst RamPatch.txt readme.txt \
		${D}${base_libdir}/firmware/ar3k/1020200/
}

# Do not create empty debug and development packages (PN-dbg PN-dev PN-staticdev)
PACKAGES = "${PN}-ar3k"

FILES_${PN}-ar3k = "/lib/firmware/ar3k"

COMPATIBLE_MACHINE = "(mxs|mx6)"
