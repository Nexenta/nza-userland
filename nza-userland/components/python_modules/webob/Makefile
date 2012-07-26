#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license
# at http://www.opensource.org/licenses/CDDL-1.0
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each file.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright (C) 2011, Nexenta Systems, Inc. and/or its affiliates. All rights reserved.
#

include ../../../make-rules/shared-macros.mk
COMPONENT_NAME         := WebOb
COMPONENT_VERSION      := 1.0.8
GIT_ID                 := 5982a58
COMPONENT_SRC          := $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE      := Pylons-webob-$(COMPONENT_VERSION)-0-g$(GIT_ID).tar.gz
COMPONENT_SRC          := Pylons-webob-$(GIT_ID)
COMPONENT_ARCHIVE_HASH := sha1:cc62dd2ce37c8d497997f2a4d2613df6efbba28b
COMPONENT_ARCHIVE_URL  := https://github.com/Pylons/webob/tarball/$(COMPONENT_VERSION)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/setup.py.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

