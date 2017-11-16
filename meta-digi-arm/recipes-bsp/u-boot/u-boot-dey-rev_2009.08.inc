# Copyright (C) 2013 Digi International

# Internal repo branch
SRCBRANCH = "v2009.08/dub-1.6/maint"

SRCREV_external = "fd3a6f15df8d9fc68d233a3a1eec1be12dc23b76"
SRCREV_internal = "21cb3d0bb94fdd4465da2351382e4c44d5bbe269"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/yocto-uboot.git;protocol=git;nobranch=1"
SRC_URI_internal = "${DIGI_GIT}u-boot-denx.git;protocol=git;nobranch=1"
SRC_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"

UBOOT_NVRAM_LIBPATH = "git/common/digi/cmd_nvram/lib"
