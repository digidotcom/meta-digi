# Copyright (C) 2013 Digi International.

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

INITSCRIPT_NAME = "networking"
INITSCRIPT_PARAMS = "start 03 2 3 4 5 . stop 80 0 6 1 ."

SRC_URI_append = " \
	file://interfaces.eth0.static \
	file://interfaces.eth0.dhcp \
	file://interfaces.eth1.static \
	file://interfaces.eth1.dhcp \
	file://interfaces.wlan0.static \
	file://interfaces.wlan0.dhcp \
	file://interfaces.cellular \
"

SRC_URI_append_mx5 = " file://ifup"

WPA_DRIVER ?= "wext"

do_install_append() {
	# Create 'interfaces' file dynamically
	cat ${WORKDIR}/interfaces.eth0.${ETH0_MODE} >> ${D}${sysconfdir}/network/interfaces
	[ -n "${HAVE_EXT_ETH}" ] && cat ${WORKDIR}/interfaces.eth1.${ETH1_MODE} >> ${D}${sysconfdir}/network/interfaces
	[ -n "${HAVE_WIFI}" ] && cat ${WORKDIR}/interfaces.wlan0.${WLAN0_MODE} >> ${D}${sysconfdir}/network/interfaces

	# Cellular interface
	if [ -n "${@base_contains('DISTRO_FEATURES', 'cellular', '1', '', d)}" ] && [ -n "${CELLULAR_INTERFACE}" ]; then
		cat ${WORKDIR}/interfaces.cellular >> ${D}${sysconfdir}/network/interfaces
		sed -i -e 's,##CELLULAR_INTERFACE##,${CELLULAR_INTERFACE},g' ${D}${sysconfdir}/network/interfaces
		[ -n "${CELLULAR_AUTO}" ] && sed -i -e 's/#auto/auto/g' ${D}${sysconfdir}/network/interfaces
		if [ -n "${CELLULAR_APN}" ]; then 
			sed -i -e 's/apn/apn ${CELLULAR_APN}/g' ${D}${sysconfdir}/network/interfaces
		else
			sed -i -e '/apn/d' ${D}${sysconfdir}/network/interfaces
		fi
		
		if [ -n "${CELLULAR_PIN}" ]; then
			sed -i -e 's/pin/pin ${CELLULAR_PIN}/g' ${D}${sysconfdir}/network/interfaces
		else
			sed -i -e '/pin/d' ${D}${sysconfdir}/network/interfaces
		fi

		if [ -n "${CELLULAR_PORT}" ]; then
			sed -i -e 's/port/port ${CELLULAR_PORT}/g' ${D}${sysconfdir}/network/interfaces
			sed -i -e 's,dhcp,manual,g' ${D}${sysconfdir}/network/interfaces
		else
			sed -i -e '/port/d' ${D}${sysconfdir}/network/interfaces
		fi

		if [ -n "${CELLULAR_USER}" ]; then
			sed -i -e 's/user/user ${CELLULAR_PORT}/g' ${D}${sysconfdir}/network/interfaces  
		else
			sed -i -e '/user/d' ${D}${sysconfdir}/network/interfaces
		fi

		if [ -n "${CELLULAR_PASSWORD}" ]; then
			sed -i -e 's/password/password ${CELLULAR_PORT}/g' ${D}${sysconfdir}/network/interfaces  
		else
			sed -i -e '/password/d' ${D}${sysconfdir}/network/interfaces
		fi
	fi

	# Replace interface parameters
	sed -i -e 's,##ETH0_STATIC_IP##,${ETH0_STATIC_IP},g' ${D}${sysconfdir}/network/interfaces
	sed -i -e 's,##ETH0_STATIC_NETMASK##,${ETH0_STATIC_NETMASK},g' ${D}${sysconfdir}/network/interfaces
	sed -i -e 's,##ETH0_STATIC_GATEWAY##,${ETH0_STATIC_GATEWAY},g' ${D}${sysconfdir}/network/interfaces
	sed -i -e 's,##ETH1_STATIC_IP##,${ETH1_STATIC_IP},g' ${D}${sysconfdir}/network/interfaces
	sed -i -e 's,##ETH1_STATIC_NETMASK##,${ETH1_STATIC_NETMASK},g' ${D}${sysconfdir}/network/interfaces
	sed -i -e 's,##ETH1_STATIC_GATEWAY##,${ETH1_STATIC_GATEWAY},g' ${D}${sysconfdir}/network/interfaces
	sed -i -e 's,##WLAN0_STATIC_IP##,${WLAN0_STATIC_IP},g' ${D}${sysconfdir}/network/interfaces
	sed -i -e 's,##WLAN0_STATIC_NETMASK##,${WLAN0_STATIC_NETMASK},g' ${D}${sysconfdir}/network/interfaces
	sed -i -e 's,##WLAN0_STATIC_GATEWAY##,${WLAN0_STATIC_GATEWAY},g' ${D}${sysconfdir}/network/interfaces
	sed -i -e "s,##WPA_DRIVER##,${WPA_DRIVER},g" ${D}${sysconfdir}/network/interfaces
}

do_install_append_mx5() {
	install -m 0755 ${WORKDIR}/ifup ${D}${sysconfdir}/network/if-up.d
}

pkg_postinst_${PN}() {
	# run the postinst script on first boot
	if [ x"$D" != "x" ]; then
		exit 1
	fi

	COMPAT="/proc/device-tree/compatible"
	WIFI_MAC="/proc/device-tree/wireless/mac-address"
	WIFI_FOUND="0"

	# Only execute the script on ccardimx28/ccimx6 platforms
	if [ -e ${WIFI_MAC} -a $(grep fsl,imx28 ${COMPAT} || grep fsl,imx6dl ${COMPAT} || grep fsl,imx6q ${COMPAT} | grep -v fsl,imx6qp) ]; then
		for id in $(find /sys/devices -name modalias -print0 | xargs -0 cat ); do
			if [[ "$id" == "sdio:c00v0271d0301" || "$id" == "sdio:c00v0271d050A" ]] ; then
				WIFI_FOUND="1"
				break
			fi
		done

		if [[ "$WIFI_FOUND" == "0" ]] ; then
			sed -i -e "s,^auto wlan0,#auto wlan0,g" /etc/network/interfaces
		fi
	fi
}
