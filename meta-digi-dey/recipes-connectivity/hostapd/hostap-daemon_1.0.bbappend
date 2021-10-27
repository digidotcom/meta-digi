# Copyright (C) 2021 Digi International.

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
	file://hostapd.conf \
"

do_install_append() {
	# Overwrite the default hostapd.conf with our custom file
	install -m 0644 ${WORKDIR}/hostapd.conf ${D}${sysconfdir}/hostapd.conf
}

# Do not autostart hostapd daemon, it will conflict with wpa-supplicant.
INITSCRIPT_PARAMS = "remove"
