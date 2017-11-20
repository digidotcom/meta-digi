# Copyright (C) 2013 Digi International

# Internal repo branch
SRCBRANCH = "v2013.01/dub-2.0/maint"

SRCREV_external = "ad540ffb97f09c12673626ca1d5ac585de136827"
SRCREV_internal = "c39c0d8216919ceff93c461516a1b48125c9c6ba"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/yocto-uboot.git;protocol=git;nobranch=1"
SRC_URI_internal = "${DIGI_GIT}u-boot-denx.git;protocol=git;nobranch=1"
SRC_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"

UBOOT_NVRAM_LIBPATH = "git/board/digi/common/cmd_nvram/lib"
