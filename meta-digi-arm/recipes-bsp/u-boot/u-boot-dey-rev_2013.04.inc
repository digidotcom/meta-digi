# Copyright (C) 2013 Digi International

# Internal repo branch
SRCBRANCH = "v2013.04/master"

SRCREV_external = "9afa3cb942184c5b7d36aed2af47f6770c233eb9"
SRCREV_internal = "5a6ef542491a4221212d9f65cf8c9d56334c2de2"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/yocto-uboot.git;protocol=git;nobranch=1"
SRC_URI_internal = "${DIGI_GIT}u-boot-denx.git;protocol=git;nobranch=1"
SRC_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"
