# Copyright (C) 2013-2021 Digi International.

PRINC := "${@int(PRINC) + 1}"
PR_append = "+${DISTRO}"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

SRC_URI_append_mx5 = " file://ifup"

WPA_DRIVER ?= "wext"

do_install_append() {
	# Enable or disable second ethernet interface
	if [ -n "${HAVE_EXT_ETH}" ]; then
		sed -i -e '/^.*auto eth1.*/cauto eth1' ${D}${sysconfdir}/network/interfaces
	else
		sed -i -e '/^.*auto eth1.*/c#auto eth1' ${D}${sysconfdir}/network/interfaces
	fi
	# Enable or disable wifi interface
	if [ -n "${HAVE_WIFI}" ]; then
		sed -i -e '/^.*auto wlan0.*/cauto wlan0' ${D}${sysconfdir}/network/interfaces
	else
		sed -i -e '/^.*auto wlan0.*/c#auto wlan0' ${D}${sysconfdir}/network/interfaces
	fi
	# Configure wpa_supplicant driver
	sed -i -e "s,##WPA_DRIVER##,${WPA_DRIVER},g" ${D}${sysconfdir}/network/interfaces
}

do_install_append_mx5() {
	install -m 0755 ${WORKDIR}/ifup ${D}${sysconfdir}/network/if-up.d
}

pkg_postinst_${PN}_mxs() {
	# run the postinst script on first boot
	if [ x"$D" != "x" ]; then
		exit 1
	fi

	WIFI_FOUND="0"

	# Only execute the script on ccardimx28 platform
	for id in $(find /sys/devices -name modalias -print0 | xargs -0 cat ); do
		if [[ "$id" == "sdio:c00v0271d0301" || "$id" == "sdio:c00v0271d050A" ]] ; then
			WIFI_FOUND="1"
			break
		fi
	done

	if [[ "$WIFI_FOUND" == "0" ]] ; then
		sed -i -e "s,^auto wlan0,#auto wlan0,g" /etc/network/interfaces
	fi
}
