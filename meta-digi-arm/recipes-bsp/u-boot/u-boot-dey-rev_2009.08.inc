# Copyright (C) 2013 Digi International

# Internal repo branch
SRCBRANCH = "v2009.08/dub-1.6/maint"

SRCREV_external = "7e45706240ec07a7c538708524c60dcf1eff5ec2"
SRCREV_internal = "1f0bad62e1d8176c7101accdbc378ecd0565a699"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/yocto-uboot.git;protocol=git;nobranch=1"
SRC_URI_internal = "${DIGI_GIT}u-boot-denx.git;protocol=git;nobranch=1"
SRC_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"

UBOOT_NVRAM_LIBPATH = "git/common/digi/cmd_nvram/lib"
