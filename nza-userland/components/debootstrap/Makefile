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
# Copyright (c) 2012, Nexenta Systems, Inc. All rights reserved.
#

include ../../make-rules/shared-macros.mk

# This APT is ported to autotools and gnulib.
# See https://code.launchpad.net/~pashev-igor/+junk/apt
# for updates

COMPONENT_NAME         = debootstrap
COMPONENT_VERSION  = 1.0.39
COMPONENT_SRC          = $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL  = http://debian.org
COMPONENT_ARCHIVE      = $(COMPONENT_NAME)_$(COMPONENT_VERSION).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:3db3a8085dcae09f882ab0d35b8ed1455f1c402f
COMPONENT_ARCHIVE_URL  = http://ftp.de.debian.org/debian/pool/main/d/debootstrap/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/justmake.mk
include $(WS_TOP)/make-rules/ips.mk

clean::
	rm -rf $(BUILD_DIR)
	rm -rf $(COMPONENT_DIR)/debootstrap.8


build:	$(BUILD_32) 


install:  $(INSTALL_32)
	$(CP) $(SOURCE_DIR)/debootstrap.8 $(COMPONENT_DIR)

test:		$(NO_TESTS)

include $(WS_TOP)/make-rules/depend.mk
