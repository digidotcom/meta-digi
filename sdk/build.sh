#!/bin/bash
#===============================================================================
#
#  build.sh
#
#  Copyright (C) 2013 by Digi International Inc.
#  All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License version 2 as published by
#  the Free Software Foundation.
#
#
#  !Description: Yocto autobuild script from Jenkins.
#
#  Parameters set by Jenkins:
#     DY_BUILD_VARIANTS: Build all platform variants
#     DY_DISTRO:         Distribution name (the default is 'dey')
#     DY_PLATFORMS:      Platforms to build
#     DY_REVISION:       Revision of the manifest repository (for 'repo init')
#     DY_RM_WORK:        Remove the package working folders to save disk space.
#     DY_TARGET:         Target image (the default is 'dey-image-minimal')
#     DY_USE_MIRROR:     Use internal Digi mirror to download packages
#
#===============================================================================

set -e

SCRIPTNAME="$(basename ${0})"
SCRIPTPATH="$(cd $(dirname ${0}) && pwd)"

MANIFEST_URL="ssh://git@stash.digi.com/dey/digi-yocto-sdk-manifest.git"

DIGI_PREMIRROR_CFG="
# Use internal mirror
SOURCE_MIRROR_URL = \"http://log-sln-jenkins.digi.com/yocto/downloads/\"
INHERIT += \"own-mirrors\"
"

KERNEL_3X_CFG="
# Build Linux 3.10 and U-Boot 2013.01
PREFERRED_VERSION_linux-dey = \"3.10\"
PREFERRED_VERSION_u-boot-dey = \"2013.01\"
"

REPO="$(which repo)"

error() {
	printf "${1}"
	exit 1
}

#
# Copy buildresults (images, licenses, packages)
#
#  $1: destination directoy
#
copy_images() {
	# Copy individual packages only for 'release' builds, not for 'daily'.
	# For 'daily' builds just copy the firmware images (the buildserver
	# cannot afford such amount of disk space)
	if echo ${JOB_NAME} | grep -qs 'dey.*release'; then
		cp -r tmp/deploy/* ${1}/
	else
		cp -r tmp/deploy/images ${1}/
	fi
	# Jenkins artifact archiver does not copy symlinks, so remove them
	# beforehand to avoid ending up with several duplicates of the same
	# files.
	if [ -d "${1}/images" ]; then
		find ${1}/images -type l -delete
	fi
}

#
# In the buildserver we share the state-cache for all the different platforms
# we build in a jenkins job. This may cause problems with some packages that
# have different runtime dependences depending on the platform.
#
# Purge then the state cache of those problematic packages between platform
# builds.
#
purge_sstate() {
	bitbake -c cleansstate packagegroup-dey-examples || true
}

# Sanity check (Jenkins environment)
[ -z "${DY_BUILD_VARIANTS}" ] && error "DY_BUILD_VARIANTS not specified"
[ -z "${DY_PLATFORMS}" ]      && error "DY_PLATFORMS not specified"
[ -z "${DY_REVISION}" ]       && error "DY_REVISION not specified"
[ -z "${DY_RM_WORK}" ]        && error "DY_RM_WORK not specified"
[ -z "${DY_USE_MIRROR}" ]     && error "DY_USE_MIRROR not specified"
[ -z "${WORKSPACE}" ]         && error "WORKSPACE not specified"

# Set default settings if Jenkins does not do it
[ -z "${DY_TARGET}" ] && DY_TARGET="dey-image-minimal"
[ -z "${DY_DISTRO}" ] && DY_DISTRO="dey"

# Per-platform variants
while read _pl _var; do
	[ "${DY_BUILD_VARIANTS}" = "false" ] && _var="DONTBUILDVARIANTS"
	eval "${_pl}_var=\"${_var}\""
done<<-_EOF_
	ccardimx28js    - e w wb web web1
	ccimx51js       128 128a 128agv agv eagv w w128a w128agv wagv weagv
	ccimx53js       - 128 4k e e4k w w128 we
_EOF_

# Support Linux-3.x and U-Boot 2013.x
while read _pl _ker; do
	eval "${_pl}_ker=\"${_ker}\""
done<<-_EOF_
	ccardimx28js    y
	ccimx51js       n
	ccimx53js       n
_EOF_

YOCTO_IMGS_DIR="${WORKSPACE}/images"
YOCTO_INST_DIR="${WORKSPACE}/digi-yocto-sdk.$(echo ${DY_REVISION} | tr '/' '_')"
YOCTO_PROJ_DIR="${WORKSPACE}/projects"

CPUS="$(grep -c processor /proc/cpuinfo)"
[ ${CPUS} -gt 1 ] && MAKE_JOBS="-j${CPUS}"

printf "\n[INFO] Build Yocto \"${DY_REVISION}\" for \"${DY_PLATFORMS}\" (cpus=${CPUS})\n\n"

# Install/Update Digi's Yocto SDK
mkdir -p ${YOCTO_INST_DIR}
if pushd ${YOCTO_INST_DIR}; then
	# Use git ls-remote to check the revision type
	if [ "${DY_REVISION}" != "master" ]; then
		if git ls-remote --tags --exit-code "${MANIFEST_URL}" "${DY_REVISION}"; then
			printf "[INFO] Using tag \"${DY_REVISION}\"\n"
			repo_revision="-b refs/tags/${DY_REVISION}"
		elif git ls-remote --heads --exit-code "${MANIFEST_URL}" "${DY_REVISION}"; then
			printf "[INFO] Using branch \"${DY_REVISION}\"\n"
			repo_revision="-b ${DY_REVISION}"
		else
			error "Revision \"${DY_REVISION}\" not found"
		fi
	fi
	yes "" 2>/dev/null | ${REPO} init --no-repo-verify -u ${MANIFEST_URL} ${repo_revision}
	time ${REPO} sync ${MAKE_JOBS}
	popd
fi

# Create projects and build
rm -rf ${YOCTO_IMGS_DIR} ${YOCTO_PROJ_DIR}
for platform in ${DY_PLATFORMS}; do
	eval platform_variants="\${${platform}_var}"
	eval platform_kernel3x="\${${platform}_ker%n}"
	for kernel_ver in "" ${platform_kernel3x:+-3x}; do
		for variant in ${platform_variants}; do
			_this_prj_dir="${YOCTO_PROJ_DIR}/${platform}${kernel_ver}"
			_this_img_dir="${YOCTO_IMGS_DIR}/${platform}${kernel_ver}"
			if [ "${variant}" != "DONTBUILDVARIANTS" ]; then
				_this_prj_dir="${YOCTO_PROJ_DIR}/${platform}${kernel_ver}_${variant}"
				_this_img_dir="${YOCTO_IMGS_DIR}/${platform}${kernel_ver}_${variant}"
				_this_var_arg="-v ${variant}"
				[ "${variant}" = "-" ] && _this_var_arg="-v \\"
			fi
			mkdir -p ${_this_img_dir} ${_this_prj_dir}
			if pushd ${_this_prj_dir}; then
				# Configure and build the project in a sub-shell to avoid
				# mixing environments between different platform's projects
				(
					export TEMPLATECONF="${TEMPLATECONF:+${TEMPLATECONF}/${platform}}"
					. ${YOCTO_INST_DIR}/mkproject.sh -p ${platform} ${_this_var_arg}
					# Set a common DL_DIR and SSTATE_DIR for all platforms
					sed -i  -e "/^#DL_DIR ?=/cDL_DIR ?= \"${YOCTO_PROJ_DIR}/downloads\"" \
						-e "/^#SSTATE_DIR ?=/cSSTATE_DIR ?= \"${YOCTO_PROJ_DIR}/sstate-cache\"" \
						conf/local.conf
					# Set the DISTRO and remove 'meta-digi-dey' layer if distro is not DEY based
					sed -i -e "/^DISTRO ?=/cDISTRO ?= \"${DY_DISTRO}\"" conf/local.conf
					if ! echo "${DY_DISTRO}" | grep -qs "dey"; then
						sed -i -e '/meta-digi-dey/d' conf/bblayers.conf
					fi
					if [ "${DY_USE_MIRROR}" = "true" ]; then
						sed -i -e "s,^#DIGI_INTERNAL_GIT,DIGI_INTERNAL_GIT,g" conf/local.conf
						printf "${DIGI_PREMIRROR_CFG}" >> conf/local.conf
					fi
					if [ -n "${kernel_ver}" ]; then
						printf "${KERNEL_3X_CFG}" >> conf/local.conf
					fi
					[ "${DY_RM_WORK}" = "true" ] && printf "\nINHERIT += \"rm_work\"\n" >> conf/local.conf
					for target in ${DY_TARGET}; do
						printf "\n[INFO] Building the $target target.\n"
						time bitbake ${target}
					done
					purge_sstate
				)
				copy_images ${_this_img_dir}
				popd
			fi
		done
	done
done
