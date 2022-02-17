# Copyright (C) 2013 Digi International

# Internal repo branch
SRCBRANCH = "v2013.01/dub-2.0/maint"

SRCREV_external = "2cde133a97c514d88659b7dcdce2345bedbdff19"
SRCREV_internal = "0067cfe617224e1ed481336567068f4ddfc87b21"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/yocto-uboot.git;protocol=git;nobranch=1"
SRC_URI_internal = "${DIGI_GIT}u-boot-denx.git;protocol=git;nobranch=1"
SRC_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"

UBOOT_NVRAM_LIBPATH = "git/board/digi/common/cmd_nvram/lib"
