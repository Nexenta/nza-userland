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

COMPONENT_NAME         = apt
IPS_COMPONENT_VERSION  = 0.8.10.3
COMPONENT_VERSION      = $(IPS_COMPONENT_VERSION)+squeeze1
COMPONENT_SRC          = $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL  = http://debian.org
COMPONENT_ARCHIVE      = $(COMPONENT_NAME)_$(COMPONENT_VERSION).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:1039d7989ceec5651214cfc13b8f092716a535d8
COMPONENT_ARCHIVE_URL  = http://ftp.de.debian.org/debian/pool/main/a/apt/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/configure.mk
include $(WS_TOP)/make-rules/ips.mk


COMPONENT_PRE_CONFIGURE_ACTION = \
	rm $(SOURCE_DIR)/buildlib/config.{sub,guess} && \
	ln -sf /usr/share/automake-1.10/config.sub   $(SOURCE_DIR)/buildlib/ && \
	ln -sf /usr/share/automake-1.10/config.guess $(SOURCE_DIR)/buildlib/ && \
	ln -sf /usr/share/gettext/config.rpath       $(SOURCE_DIR)/buildlib/


PKG_PROTO_DIRS += $(BUILD_DIR_32) # build/i86

build:		$(BUILD_32)

install:

test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk
