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
# Copyright (C) 2012, Nexenta Systems, Inc. All rights reserved.
#

include ../../make-rules/shared-macros.mk

COMPONENT_NAME         = apt-file
COMPONENT_VERSION      = 2.5.0
COMPONENT_SRC          = $(COMPONENT_NAME)
COMPONENT_PROJECT_URL  = http://packages.debian.org/source/sid/apt-file
COMPONENT_ARCHIVE      = $(COMPONENT_SRC)_$(COMPONENT_VERSION).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:fc38d9da1bcb976260301c12360d0f8dbf4a7e2f
COMPONENT_ARCHIVE_URL  = http://ftp.de.debian.org/debian/pool/main/a/$(COMPONENT_NAME)/$(COMPONENT_ARCHIVE)


include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/justmake.mk
include $(WS_TOP)/make-rules/ips.mk


build:		$(BUILD_32)

install:	$(INSTALL_32)

test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
