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
# Copyright (c) 2012, David Höppner
# Copyright (c) 2012, Nexenta Systems, Inc.
#

include ../../make-rules/shared-macros.mk

COMPONENT_NAME         = redis
COMPONENT_VERSION      = 2.4.7
COMPONENT_SRC          = $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE      = $(COMPONENT_SRC).tar.gz
COMPONENT_PROJECT_URL  = http://redis.io
COMPONENT_ARCHIVE_HASH = sha1:cd0835f1076ad36797ed6543af187ac28a29953f
COMPONENT_ARCHIVE_URL  = http://redis.googlecode.com/files/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/justmake.mk
include $(WS_TOP)/make-rules/ips.mk


# Redis' Makefiles expect GCC.
# If building with other compiler, overwrite CFLAGS.
COMPONENT_BUILD_ENV = ARCH=""
COMPONENT_BUILD_ENV += CC="$(CC)"

COMPONENT_INSTALL_ARGS += PREFIX=/$(PROTO_DIR)/usr

build:		$(BUILD_32)

install:	$(INSTALL_32)

test:		$(TEST_32)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk
