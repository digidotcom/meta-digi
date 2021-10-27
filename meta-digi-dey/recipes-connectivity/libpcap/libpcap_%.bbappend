# Copyright (C) 2021 Digi International

inherit bluetooth

# libpcap includes bluez4 unconditionally, but there is only a PACKAGECONFIG for
# bluetooth to support bluez4, nothing about bluez5. So split it in bluez4 and
# add a dummy PACKAGECONFIG for bluez5 since it is not supported by libpcap.
PACKAGECONFIG_remove = "bluetooth"
PACKAGECONFIG_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', '${BLUEZ}', '', d)}"
PACKAGECONFIG[bluez4] = "--enable-bluetooth,--disable-bluetooth,bluez4"
PACKAGECONFIG[bluez5] = ",,"
