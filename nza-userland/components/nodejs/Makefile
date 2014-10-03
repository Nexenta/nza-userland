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
# Copyright (c) 2014, Nexenta Systems, Inc. All rights reserved.
#

include ../../make-rules/shared-macros.mk

DEBVERSION := 40-0-9

# make sure dtrace is found:
export PATH := /usr/sbin:$(PATH)
export CC = gcc

COMPONENT_NAME         = nodejs
COMPONENT_VERSION      = 0.10.29
COMPONENT_REVISION     = 
COMPONENT_SRC          = node-v$(COMPONENT_VERSION)
COMPONENT_ARCHIVE      = $(COMPONENT_SRC)$(COMPONENT_REVISION).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:0d5dc62090404f7c903f29779295758935529242
COMPONENT_ARCHIVE_URL  = http://nodejs.org/dist/v$(COMPONENT_VERSION)/$(COMPONENT_ARCHIVE)
COMPONENT_PROJECT_URL  = http://nodejs.org

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/configure.mk
include $(WS_TOP)/make-rules/ips.mk

COMPONENT_PRE_CONFIGURE_ACTION = ( \
	$(CLONEY) $(SOURCE_DIR) $(@D); \
	)

CONFIG_SHELL= python

# Reset configure options.
# configure is a wrapper to waf.
CONFIGURE_OPTIONS = --dest-cpu=x64
CONFIGURE_OPTIONS += --with-dtrace
CONFIGURE_OPTIONS += --shared-zlib
CONFIGURE_OPTIONS += --shared-openssl
CONFIGURE_OPTIONS += --no-ssl2
CONFIGURE_OPTIONS += --prefix=/usr


build:		$(BUILD_32)

install:	$(INSTALL_32)

test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk
