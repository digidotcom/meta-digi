# Copyright (C) 2013 Digi International

# Internal repo branch
SRCBRANCH = "v2013.04/dub-2.3/maint"

SRCREV_external = "465e54b0e54d8df02bf9f19ce252eae5888b4592"
SRCREV_internal = "ef2a3e267fe8b3cc9c0850f2a3be99c3cf668bac"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/yocto-uboot.git;protocol=git;nobranch=1"
SRC_URI_internal = "${DIGI_GIT}u-boot-denx.git;protocol=git;nobranch=1"
SRC_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"
