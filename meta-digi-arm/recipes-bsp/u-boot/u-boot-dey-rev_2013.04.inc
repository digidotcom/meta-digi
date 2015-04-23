# Copyright (C) 2013 Digi International

# Internal repo branch
SRCBRANCH = "v2013.04/dub-2.3/maint"

SRCREV_external = "f954d01d6d385f0b562017dfa31a6345a4b61caa"
SRCREV_internal = "75ae35e55979e595bbde3c0940f6e00e0de5185d"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/yocto-uboot.git;protocol=git;nobranch=1"
SRC_URI_internal = "${DIGI_GIT}u-boot-denx.git;protocol=git;nobranch=1"
SRC_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"
