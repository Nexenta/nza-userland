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

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME         = libdtrace
COMPONENT_VERSION      = 0.0.2
COMPONENT_SRC          = $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE      = $(COMPONENT_SRC).tgz
COMPONENT_ARCHIVE_HASH = sha1:21fc4436eaf25115e2f72f38ebe5ecd771161022
COMPONENT_ARCHIVE_URL  = file://$(COMPONENT_ARCHIVE)
COMPONENT_PROJECT_URL  = https://github.com/bcantrill/node-libdtrace
SOURCE_DIR             = $(COMPONENT_DIR)/package

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/justmake.mk
include $(WS_TOP)/make-rules/ips.mk

build: download
	mkdir -p $(BUILD_DIR)
	$(ENV) $(COMPONENT_BUILD_ENV) npm install $(COMPONENT_ARCHIVE)

install:

test:

clean::
	$(RM) -r node_modules

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk
