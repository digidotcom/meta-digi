# Copyright (C) 2013 Digi International

# Internal repo branch
SRCBRANCH = "v2013.04/master"

SRCREV_external = "1bca6523b68e516a5d76e6c0b46550d40f4814e7"
SRCREV_internal = "b69bd166693e2d1f0670646c0fa79168a19ad4ee"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/yocto-uboot.git;protocol=git;nobranch=1"
SRC_URI_internal = "${DIGI_GIT}u-boot-denx.git;protocol=git;nobranch=1"
SRC_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"
