# Copyright (C) 2012 Digi International

require recipes-kernel/linux/linux-dey.inc

COMPATIBLE_MACHINE = "(mxs|mx5)"

# Internal repo branch
SRCBRANCH = "v2.6.35/dey-1.4/maint"

SRCREV_external = ""
SRCREV_internal = "${AUTOREV}"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

KERNEL_CFG_FRAGS ?= ""
KERNEL_CFG_FRAGS_append_mx5 = "file://config-sahara-module.cfg file://config-camera-module.cfg"
KERNEL_CFG_FRAGS_append_mx5 = " ${@base_contains('MACHINE_FEATURES', 'accelerometer', 'file://config-accel-module.cfg', '', d)}"
KERNEL_CFG_FRAGS_append_mx5 = " ${@base_contains('MACHINE_FEATURES', 'ext-eth', 'file://config-ext-eth-module.cfg', '', d)}"
KERNEL_CFG_FRAGS_append_mx5 = " ${@base_contains('MACHINE_FEATURES', 'wifi', 'file://config-wireless-redpine.cfg', '', d)}"
KERNEL_CFG_FRAGS_append_ccimx51js = " file://config-battery-module.cfg"
KERNEL_CFG_FRAGS_append_mxs = " ${@base_contains('MACHINE_FEATURES', 'wifi', 'file://config-wireless-atheros.cfg \
									      file://0001-mmc-sdio-add-support-to-SDIO-CCCR-v2.0.patch', '', d)}"
KERNEL_CFG_FRAGS_append_mxs = " ${@base_contains('MACHINE_FEATURES', 'bluetooth', 'file://config-bluetooth-atheros.cfg', '', d)}"
KERNEL_CFG_FRAGS_append_ccardimx28js = " ${@base_contains('MACHINE_FEATURES', '1-wire', 'file://config-1-wire.cfg', '', d)}"
KERNEL_CFG_FRAGS_append_ccardimx28js = " ${@base_contains('MACHINE_FEATURES', 'ext-eth', 'file://config-ext-eth.cfg', '', d)}"
KERNEL_CFG_FRAGS_append_ccardimx28js = " ${@base_contains('DISTRO_FEATURES', 'x11', 'file://config-fb.cfg file://config-touch.cfg', '', d)}"
KERNEL_CFG_FRAGS_append_ccardimx28js = " ${@base_contains('MACHINE_FEATURES', 'alsa', 'file://config-sound.cfg', '', d)}"
