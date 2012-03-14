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
# Copyright (c) 2012 Nexenta Systems, Inc. All rights reserved.
#

include ../..//make-rules/shared-macros.mk

COMPONENT_NAME         := icu4c
COMPONENT_VERSION      := 4.8.1.1
tarball_version        := $(subst .,_,$(COMPONENT_VERSION))
COMPONENT_SRC          := icu
COMPONENT_PROJECT_URL  := http://site.icu-project.org/
COMPONENT_ARCHIVE      := $(COMPONENT_NAME)-$(tarball_version)-src.tgz
COMPONENT_ARCHIVE_HASH := sha1:7146ee269b39273fa98d750f73136b14f781758a
COMPONENT_ARCHIVE_URL  := http://download.icu-project.org/files/icu4c/$(COMPONENT_VERSION)//$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/configure.mk
include $(WS_TOP)/make-rules/ips.mk

CONFIGURE_SCRIPT = $(SOURCE_DIR)/source/configure


build:		$(BUILD_32_and_64)

install:	$(INSTALL_32_and_64)

test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk
