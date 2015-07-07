# Copyright (C) 2013 Digi International

# Internal repo branch
SRCBRANCH = "v2013.01/dub-2.0/maint"

SRCREV_external = "186aa93875cc150f87a47cf0131e2325bd9f38ed"
SRCREV_internal = "fdf969ac41fe351c0a99a0ef4f8978f65b91c315"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/yocto-uboot.git;protocol=git;nobranch=1"
SRC_URI_internal = "${DIGI_GIT}u-boot-denx.git;protocol=git;branch=${SRCBRANCH}"
SRC_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"

UBOOT_NVRAM_LIBPATH = "git/board/digi/common/cmd_nvram/lib"
