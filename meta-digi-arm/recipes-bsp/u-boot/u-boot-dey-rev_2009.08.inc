# Copyright (C) 2013 Digi International

# Internal repo branch
SRCBRANCH = "v2009.08/dub-1.6/maint"

SRCREV_external = "e5a573eb96c72a95295542818ce89ba1d6f609c5"
SRCREV_internal = "1efa30dd5766e39d553c4079a74218c8bedcd7cd"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/yocto-uboot.git;protocol=git;nobranch=1"
SRC_URI_internal = "${DIGI_GIT}u-boot-denx.git;protocol=git;nobranch=1"
SRC_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"

UBOOT_NVRAM_LIBPATH = "git/common/digi/cmd_nvram/lib"
