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
# Copyright (c) 2011, Nexenta Systems, Inc. and/or its affiliates. All rights reserved.
#

include ../../../make-rules/shared-macros.mk
COMPONENT_NAME=     Text-CharWidth
COMPONENT_VERSION=  0
COMPONENT_SRC=      $(COMPONENT_NAME)-$(COMPONENT_VERSION).04
COMPONENT_ARCHIVE=  $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH= sha1:b369ce7a531539ebf5b9cf1c1b09d66846f56aa4
COMPONENT_ARCHIVE_URL=  http://search.cpan.org/CPAN/authors/id/K/KU/KUBOTA/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/makemaker.mk

COMPILER = gcc
CONFIGURE_OPTIONS<----->+=CC=gcc

build:      $(BUILD_32)

install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES =        $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

