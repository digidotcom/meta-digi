# Copyright (C) 2013 Digi International

# Internal repo branch
SRCBRANCH = "v2013.04/master"

SRCREV_external = "0274d11b1398a9ec9ca373a8db9be6c50f4661b9"
SRCREV_internal = "c3fee874cf7ebef4abfc056775d2f4211a31eac9"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/yocto-uboot.git;protocol=git;nobranch=1"
SRC_URI_internal = "${DIGI_GIT}u-boot-denx.git;protocol=git;nobranch=1"
SRC_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"
