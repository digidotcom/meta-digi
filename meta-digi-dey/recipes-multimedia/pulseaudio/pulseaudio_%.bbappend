# Copyright (C) 2021 Digi International

inherit bluetooth

# Pulseaudio includes bluez4 unconditionally, however there is support to
# bluez4 and bluez5, so now the dependency is added using the bluetooth class.
PACKAGECONFIG_remove = "bluez4"
PACKAGECONFIG_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', '${BLUEZ}', '', d)}"
