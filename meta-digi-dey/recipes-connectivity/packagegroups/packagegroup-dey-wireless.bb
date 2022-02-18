#
# Copyright (C) 2012-2021 Digi International.
#
SUMMARY = "Wireless packagegroup for DEY image"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=3f40d7994397109285ec7b81fdeb3b58"
PACKAGE_ARCH = "${MACHINE_ARCH}"

PR = "r0"

inherit packagegroup

WIRELESS_MODULE ?= ""
WIRELESS_MODULE_append_mx5 = "${@base_contains('MACHINE_FEATURES', 'wifi', 'kernel-module-redpine', '', d)}"
WIRELESS_MODULE_append_mxs = "${@base_contains('MACHINE_FEATURES', 'wifi', \
                                               base_conditional("IS_KERNEL_2X", "1" , "", \
                                                                                      "kernel-module-atheros kernel-module-qualcomm", d), \
                                               '', d)}"
WIRELESS_MODULE_append_mx6 = "${@base_contains('MACHINE_FEATURES', 'wifi', 'kernel-module-atheros kernel-module-qualcomm', '', d)}"

RDEPENDS_${PN} = "\
    crda \
    wireless-tools \
    wpa-supplicant \
    wpa-supplicant-cli \
    wpa-supplicant-passphrase \
    ${WIRELESS_MODULE} \
"

RDEPENDS_${PN}_append_mxs = " ${@base_conditional('IS_KERNEL_2X', '1' , 'iw ath-prop-tools', 'iw hostapd ath-prop-tools', d)}"
RDEPENDS_${PN}_append_mx6 = " iw hostapd ath-prop-tools"
