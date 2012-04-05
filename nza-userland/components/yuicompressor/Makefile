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

COMPONENT_NAME         = yuicompressor
COMPONENT_VERSION      = 2.4.7
COMPONENT_SRC          = $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL  = http://developer.yahoo.com/yui/compressor/
COMPONENT_ARCHIVE      = $(COMPONENT_SRC).zip
COMPONENT_ARCHIVE_HASH = sha1:64d209cae769cee2b89217ba226543001c59d27b
COMPONENT_ARCHIVE_URL  = http://yui.zenfs.com/releases/yuicompressor/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/ant.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/prep.mk

build:		$(BUILD_32)

#install:	$(INSTALL_32)

test:
	cd tests; bash ./suite.sh

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk
