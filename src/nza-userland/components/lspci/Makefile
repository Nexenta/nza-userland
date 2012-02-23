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
# Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved.
#
# Copyright (c) 2011 Nexenta Systems, Inc.  All rights reserved.

include ../..//make-rules/shared-macros.mk

COMPONENT_NAME         = pciutils
COMPONENT_VERSION      = 3.1.9
COMPONENT_SRC          = $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE      = $(COMPONENT_SRC).tar.bz2
COMPONENT_ARCHIVE_HASH = sha1:4ecf2eab484377d07f6ca4014a7033c091a40cef
COMPONENT_ARCHIVE_URL  = ftp://ftp.kernel.org/pub/software/utils/$(COMPONENT_NAME)/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/justmake.mk
include $(WS_TOP)/make-rules/ips.mk


build:		$(BUILD_32)

install:	$(INSTALL_32)

test:		$(TEST_32)


BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

