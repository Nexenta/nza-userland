#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright (c) 2011, Nexenta Systems, Inc. All rights reserved.
#

include ../../make-rules/shared-macros.mk

# This APT is ported to autotools and gnulib.
# See https://code.launchpad.net/~pashev-igor/+junk/apt
# for updates

COMPONENT_NAME         = apt
IPS_COMPONENT_VERSION  = 0.8.15.10
COMPONENT_VERSION      = $(IPS_COMPONENT_VERSION)+1
COMPONENT_SRC          = $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL  = http://debian.org
COMPONENT_ARCHIVE      = $(COMPONENT_NAME)-$(COMPONENT_VERSION).tar.bz2
COMPONENT_ARCHIVE_HASH = sha1:3d35f3212f4b7534d61086d89d94db2a9e87f992
COMPONENT_ARCHIVE_URL  = $(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/configure.mk
include $(WS_TOP)/make-rules/ips.mk

CONFIGURE_OPTIONS += --libexecdir=/usr/lib/apt/methods
CONFIGURE_OPTIONS += --disable-static

LD_OPTIONS =

build:	$(BUILD_32) run-parts perl-build-stamp
install:  $(INSTALL_32) run-parts perl-install-stamp

# run-parts is a part of debianutils,
# it is used by apt-key. No other program from debianutils
# is used, so run-parts shipped with APT.
run-parts: BITS=32
run-parts: run-parts.c
	$(CC) \
		-DPACKAGE_VERSION="\"4.1 (a part of APT)\"" \
		-DHAVE_GETOPT_H=1 \
		-o $@ $<

# We will use local -lapt-pkg:
perl-build-stamp: $(BUILD_32)
	LIBS="-L$(BUILD_DIR_32)/apt-pkg/.libs -lapt-pkg" \
	$(GMAKE) -f Makefile.perl build
	touch $@

perl-install-stamp: perl-build-stamp
	$(GMAKE) -f Makefile.perl install
	touch $@

clean::
	$(GMAKE) -f Makefile.perl clean
	$(RM) run-parts
	$(RM) perl-*-stamp


test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk
