#!/usr/bin/make -f
# -*- makefile -*-

# Configure quilt.
export QUILT_PATCHES=debian/patches
export QUILT_REFRESH_ARGS='-p ab --no-timestamps --no-index'

# The absolute path of this present "make" file.
MAKE_PATH := $(realpath $(firstword $(MAKEFILE_LIST)))

# The working directory is obtained by removing the "/make"
# string at the end of MAKE_PATH and adding "/workdir".
WORK_DIR := $(realpath $(MAKE_PATH:/make=))/workdir

# Version number in the changelog to create the tarball
# of the upstream application with the good name.
# Typically, during the first call, ie `./make install-env`,
# the dpkg-parsechangelog will be not installed and the VERSION
# variable will be equal to "UNDEFINED".
VERSION := $(shell cd $(WORK_DIR) && (dpkg-parsechangelog 2>/dev/null \
    || echo Version UNDEFINED) | awk '/^Version/ {print $$2}' | cut -d'-' -f1 \
    | sed -r 's/^([0-9]*:)*(.*)$$/\2/')

# Name of the package.
PACKAGE_NAME := $(shell cd $(WORK_DIR) && (dpkg-parsechangelog 2>/dev/null \
    || echo Source UNDEFINED) | awk '/^Source/ {print $$2}')


# lintian is not necessary to build the package but can help to
# detect any things which are not Debian policy compliant.
install-env:
	# wget and libwww-perl are necessary for uscan.
	apt-get update && apt-get install --no-install-recommends --yes \
	    wget libwww-perl
	# Basic packages to make builds.
	apt-get install --no-install-recommends --yes devscripts equivs \
	    lsb-release build-essential lintian dput
	# Installation of build-dependencies.
	cd "$(WORK_DIR)" && mk-build-deps --install --tool \
	    'apt-get --yes --no-install-recommends' --remove ./debian/control

clean:
	cd "$(WORK_DIR)" && { which dh_clean >/dev/null && dh_clean; } || true
	cd "$(WORK_DIR)" && cd .. && rm -f *.deb *.build *.buildinfo *.changes
	cd "$(WORK_DIR)" && rm -f "../$(PACKAGE_NAME)_$(VERSION).orig.tar.gz"
	cd "$(WORK_DIR)" && rm -f "../archive.tar.gz"
	cd "$(WORK_DIR)" && find . -maxdepth 1 -mindepth 1 '!' -name 'debian' \
	    -exec rm -rf '{}' ';'

populate: clean
	cd "$(WORK_DIR)" && uscan --download-current-version --force-download
	cd "$(WORK_DIR)" && tar --strip-components=1 \
	    -zxf "../$(PACKAGE_NAME)_$(VERSION).orig.tar.gz" -C .
	cd "$(WORK_DIR)" && quilt push -a

build: populate
#	cd "$(WORK_DIR)" && debuild -b -us -uc --lintian-opts --pedantic -i -I \
#	    && echo 'Building is OK!'
	cd "$(WORK_DIR)" && debuild --no-lintian -b -us -uc && echo 'Building is OK!'


