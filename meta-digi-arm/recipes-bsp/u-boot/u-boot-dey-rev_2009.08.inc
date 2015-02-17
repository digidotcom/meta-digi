# Copyright (C) 2013 Digi International

SRCREV_external = "c97623b3f06987cd505d34b7f9f40cabca9b66f7"
SRCREV_internal = "0f79ef58320f2d0bf725c5cd75cb6e9d3dee7923"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/yocto-uboot.git;protocol=git"
SRC_URI_internal = "${DIGI_GIT}u-boot-denx.git;protocol=git"
SRC_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"

UBOOT_NVRAM_LIBPATH = "git/common/digi/cmd_nvram/lib"
