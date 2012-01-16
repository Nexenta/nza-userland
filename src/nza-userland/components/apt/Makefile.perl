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

include ../../make-rules/shared-macros.mk

COMPONENT_NAME         = libapt-pkg-perl
COMPONENT_VERSION      = 0.1.25
COMPONENT_SRC          = $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE      = $(COMPONENT_NAME)_$(COMPONENT_VERSION).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:6a868c587728a857481089dcc37bd984b79d80db
COMPONENT_ARCHIVE_URL  = http://ftp.de.debian.org/debian/pool/main/liba/libapt-pkg-perl/$(COMPONENT_ARCHIVE)

PATCH_DIR = patches.perl

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/makemaker.mk

LIBS ?= -lapt-pkg
COMMON_PERL_ENV += LIBS="$(LIBS)"

build:		$(BUILD_32)

install:	$(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:		$(TEST_32)

BUILD_PKG_DEPENDENCIES =        $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk
