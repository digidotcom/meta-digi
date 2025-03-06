# Copyright (C) 2013 Digi International

# Internal repo branch
SRCBRANCH = "v2013.04/dub-2.3/maint"

SRCREV_external = "249fc9bbea82c43e4df32e58008371df495b4f96"
SRCREV_internal = "69819b4762d9773b0b10bd259598e21b19f09f27"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/yocto-uboot.git;protocol=git;nobranch=1"
SRC_URI_internal = "${DIGI_GIT}u-boot-denx.git;protocol=git;nobranch=1"
SRC_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"
