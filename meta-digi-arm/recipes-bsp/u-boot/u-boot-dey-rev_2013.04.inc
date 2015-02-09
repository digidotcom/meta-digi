# Copyright (C) 2013 Digi International

# Internal repo branch
SRCBRANCH = "v2013.04/dub-2.3/maint"

SRCREV_external = "3b19f96b7d51bad33c3fb7a2338490e4ab39b41f"
SRCREV_internal = "d22ee33095af50326935c55c07e166019a0aca97"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/yocto-uboot.git;protocol=git;nobranch=1"
SRC_URI_internal = "${DIGI_GIT}u-boot-denx.git;protocol=git;nobranch=1"
SRC_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"
