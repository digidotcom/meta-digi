# Copyright (C) 2013 Digi International

# Internal repo branch
SRCBRANCH = "v2013.04/dub-2.3/maint"

SRCREV_external = "0b9ade7fcc48dc9ed08575643f0d3147794f356b"
SRCREV_internal = "c67867520673cef70164003f76a85a5e7a4f6e6c"
SRCREV = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRCREV_internal}', '${SRCREV_external}', d)}"

SRC_URI_external = "${DIGI_GITHUB_GIT}/yocto-uboot.git;protocol=git;nobranch=1"
SRC_URI_internal = "${DIGI_GIT}u-boot-denx.git;protocol=git;branch=${SRCBRANCH}"
SRC_URI = "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${SRC_URI_internal}', '${SRC_URI_external}', d)}"
