#!/bin/sh
#===============================================================================
#
#  10-atheros_pre-up
#
#  Copyright (C) 2012-2021 by Digi International Inc.
#  All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License version 2 as published by
#  the Free Software Foundation.
#
#
#  !Description: Load Atheros' wireless driver
#
#===============================================================================

set -e

FIRMWARE_DIR="/lib/firmware/ath6k/AR6003/hw2.1.1"

ATH6KL_DBG_NONE=0x0
ATH6KL_DBG_CREDIT=0x00000001
ATH6KL_DBG_WLAN_TX=0x00000004
ATH6KL_DBG_WLAN_RX=0x00000008
ATH6KL_DBG_BMI=0x00000010
ATH6KL_DBG_HTC=0x00000020
ATH6KL_DBG_HIF=0x00000040
ATH6KL_DBG_IRQ=0x00000080
ATH6KL_DBG_WMI=0x00000400
ATH6KL_DBG_TRC=0x00000800
ATH6KL_DBG_SCATTER=0x00001000
ATH6KL_DBG_WLAN_CFG=0x00002000
ATH6KL_DBG_RAW_BYTES=0x00004000
ATH6KL_DBG_AGGR=0x00008000
ATH6KL_DBG_SDIO=0x00010000
ATH6KL_DBG_SDIO_DUMP=0x00020000
ATH6KL_DBG_BOOT=0x00040000
ATH6KL_DBG_WMI_DUMP=0x00080000
ATH6KL_DBG_SUSPEND=0x00100000
ATH6KL_DBG_USB=0x00200000
ATH6KL_DBG_RECOVERY=0x00400000
ATH6KL_DBG_ANY=0xffffffff

ATH6KL_DEBUG_MASK="${ATH6KL_DBG_NONE}"

# At this point of the boot (udev script), the system log (syslog) is not
# available yet, so use the kernel log buffer from userspace.
log() {
        printf "<$1>ath6kl: $2\n" >/dev/kmsg
}

#
# Get the wlan MAC address from kernel command line.  Use a default
# value if the address has not been set.
#
if [ -f "/proc/device-tree/wireless/mac-address" ]; then
	MAC_ADDR="$(hexdump -ve '1/1 "%02X" ":"' /proc/device-tree/wireless/mac-address | sed 's/:$//g')"
else
	MAC_ADDR="$(sed -ne 's,^.*ethaddr2=\([^[:blank:]]\+\)[:blank:]*.*,\1,g;T;p' /proc/cmdline)"
fi
if [ -z "${MAC_ADDR}" -o "${MAC_ADDR}" = "00:00:00:00:00:00" ]; then
	MAC_ADDR="00:04:F3:4C:B1:D3"
fi

# We need to write the WLAN MAC address to softmac in the ath6k firmware
# directory.  However, we don't want to rewrite the file if it already exists
# and the address is the same because we don't want to wear out NAND flash.
#
# So create the file on the RAM DRIVE first and compare the two.  Only update
# the copy on NAND if the address has changed.
#
mac1="$(echo ${MAC_ADDR} | cut -d':' -f1)"
mac2="$(echo ${MAC_ADDR} | cut -d':' -f2)"
mac3="$(echo ${MAC_ADDR} | cut -d':' -f3)"
mac4="$(echo ${MAC_ADDR} | cut -d':' -f4)"
mac5="$(echo ${MAC_ADDR} | cut -d':' -f5)"
mac6="$(echo ${MAC_ADDR} | cut -d':' -f6)"

TMP_MACFILE="$(mktemp -t softmac.XXXXXX)"
printf "\x${mac1}\x${mac2}\x${mac3}\x${mac4}\x${mac5}\x${mac6}" > ${TMP_MACFILE}
if ! cmp -s ${TMP_MACFILE} ${FIRMWARE_DIR}/softmac; then
	cp ${TMP_MACFILE} ${FIRMWARE_DIR}/softmac
fi
rm -f ${TMP_MACFILE}

# Figure out which wireless region we are in.  The US has rules for
# what channels can be used and at what power level.  We use a different set of
# rules for the other regions in the world that we sell into.  The mod_cert field
# in OTP will be set to 0x0 for the US.  Once we know the region, make sure the
# appropriate calibration file is loaded.
#
MACHINE="$(cat /proc/device-tree/digi,machine,name 2>/dev/null || \
	   cat /sys/kernel/machine/name)"
MOD_VARIANT="$(cat /proc/device-tree/digi,hwid,variant 2>/dev/null || \
	       cat /sys/kernel/${MACHINE}/mod_variant)"
REGION_CODE="$(cat /proc/device-tree/digi,hwid,cert 2>/dev/null || \
	       cat /sys/kernel/${MACHINE}/mod_cert)"

# 'ccimx6sbc' variants 0x05, 0x07 and 0x0a do not have bluetooth
# and use a different calibration file
US_CODE="0x0"
case "${MACHINE}:${MOD_VARIANT}:${REGION_CODE}" in
	ccimx6sbc:0x05:${US_CODE}|ccimx6sbc:0x07:${US_CODE}|ccimx6sbc:0x0a:${US_CODE})
		BDATA_SOURCE="Digi_6203_2_ANT-US.bin"
		log "5" "Setting US wireless region (no bluetooth)";;
	ccimx6sbc:0x05:*|ccimx6sbc:0x07:*|ccimx6sbc:0x0a:*)
		BDATA_SOURCE="Digi_6203_2_ANT-World.bin"
		log "5" "Setting non-US (world) wireless region (no bluetooth)";;
	*:*:${US_CODE})
		BDATA_SOURCE="Digi_6203-6233-US.bin"
		log "5" "Setting US wireless region";;
	*:*:*)
		BDATA_SOURCE="Digi_6203-6233-World.bin"
		log "5" "Setting non-US (world) wireless region";;
esac

# We don't want to rewrite NAND every time we boot so only
# change the link if it is wrong.
BDATA_LINK="${FIRMWARE_DIR}/bdata.bin"
if [ ! -e "${BDATA_LINK}" ] || ! cmp -s "${BDATA_LINK}" "${FIRMWARE_DIR}/${BDATA_SOURCE}"; then
	ln -sf "${BDATA_SOURCE}" "${BDATA_LINK}"
fi

# Load 'cfg80211' and let it settle down (needed by 'ath6kl_sdio')
modprobe -q cfg80211_ath && sleep 1

# ath6kl_sdio.ko
if ! grep -qs ath6kl_sdio /proc/modules; then
	RETRIES="5"
	while [ "${RETRIES}" -gt "0" ]; do
		modprobe --ignore-install -q ath6kl_sdio debug_mask="${ATH6KL_DEBUG_MASK}" || true
		[ -d "/sys/class/net/wlan0" ] && break
		RETRIES="$((RETRIES - 1))"
		rmmod ath6kl_sdio > /dev/null
		log "5" "Retrying to load wireless"
		sleep 2
	done
	[ "${RETRIES}" -eq "0" ] && log "3" "Loading ath6kl_sdio module: [FAILED]"
fi

# Delay required for the interface 'wlan0' to settle down before trying to configure it.
sleep 0.5
