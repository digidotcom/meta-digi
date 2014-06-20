# Copyright (C) 2013 Digi International

# Internal repo branch
SRCBRANCH = "v2013.01/master"

SRCREV_external = "d021d2dfa75b709c02bd2e0e7f69fb82b369128f"
SRCREV_internal = "31f2fc414e30ff53bf3f924e488723369fe06a52"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/yocto-uboot.git;protocol=git;nobranch=1"
SRC_URI_internal = "${DIGI_GIT}u-boot-denx.git;protocol=git;nobranch=1"
SRC_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"

UBOOT_NVRAM_LIBPATH = "git/board/digi/common/cmd_nvram/lib"
