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
# Copyright (c) 2011, Nexenta Systems, Inc. All rights reserved.
#
include ../../make-rules/shared-macros.mk

COMPONENT_NAME         = libssh
COMPONENT_VERSION      = 0.5.2
COMPONENT_GIT_UPDATE   = +git20111227
COMPONENT_SRC          = $(COMPONENT_NAME)-$(COMPONENT_VERSION)$(COMPONENT_GIT_UPDATE)
COMPONENT_PROJECT_URL  = http://www.libssh.org
COMPONENT_ARCHIVE      = $(COMPONENT_SRC).tar.bz2
COMPONENT_ARCHIVE_HASH = sha1:bbb9d58e9c0eaf1a0b018322ecd42921c0024b52
COMPONENT_ARCHIVE_URL  = http://www.libssh.org/files/0.5/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/cmake.mk
include ../../make-rules/ips.mk

build: $(BUILD_32_and_64)

install: $(INSTALL_32_and_64)

test: $(TEST_32_and_64)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk
