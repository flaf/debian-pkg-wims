#!/usr/bin/make -f
# -*- makefile -*-

# Configure quilt.
export QUILT_PATCHES=debian/patches
export QUILT_REFRESH_ARGS='-p ab --no-timestamps --no-index'

# The absolute path of this present make file.
RULES_PATH := $(realpath $(firstword $(MAKEFILE_LIST)))

# The root directory is obtained by removing the
# "/make" string at the end of RULES_PATH and by
# adding "/root".
ROOT_DIR := $(realpath $(RULES_PATH:/make=))/root

# Version number in the changelog to create the tarball
# of the upstream application with the good name.
# Typically, during the first call, ie `./make install_env`,
# the dpkg-parsechangelog will be not installed and the VERSION
# variable will be equal to "UNDEFINED".
VERSION := $(shell cd $(ROOT_DIR) && (dpkg-parsechangelog 2>/dev/null \
    || echo Version UNDEFINED) | awk '/^Version/ {print $$2}' | cut -d'-' -f1)


# lintian is not necessary to build the package but can help to
# detect any things which are not Debian policy compliant.
install_env:
	# wget and libwww-perl are necessary for uscan.
	apt-get update && apt-get install --no-install-recommends --yes wget libwww-perl
	apt-get install --no-install-recommends --yes devscripts equivs lsb-release build-essential lintian dput
	cd "$(ROOT_DIR)" && mk-build-deps --install --tool 'apt-get --yes --no-install-recommends' --remove ./debian/control

populate: clean
	cd "$(ROOT_DIR)" && uscan --download-current-version --force-download
	cd "$(ROOT_DIR)" && tar --strip-components=1 -zxf "../xia_$(VERSION).orig.tar.gz" -C .
	# This is crucial to apply all patches, because this is not always
	# automatic. For instance, patches are not pushed if debuild use
	# the -b option.
	cd "$(ROOT_DIR)" && quilt push -a

# -b and -sa --> man dpkg-genchanges
build: populate
	cd "$(ROOT_DIR)" && debuild -b -us -uc --lintian-opts --pedantic -i -I && echo 'Building is OK!'

populate4danerepo: populate
	cd "$(ROOT_DIR)" && ../hack-danerepo hack

build4danerepo: populate4danerepo build

build_sign: populate
	cd "$(ROOT_DIR)" && debuild -sa --lintian-opts --pedantic -i -I && echo 'Building is OK!'


