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
# Copyright (C) 2011, Nexenta Systems, Inc. All rights reserved.
#
include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		xapian-core
COMPONENT_VERSION=	1
FULL_VERSION=		1.2.7	
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION).2.7
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:c6c5c5b14d5d64481858ac2b181429a9b8bdc9a1
COMPONENT_ARCHIVE_URL=	http://oligarchy.co.uk/xapian/1.2.7/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk

COMPILER = gcc
CONFIGURE_OPTIONS	+=CC=cc
CONFIGURE_OPTIONS	+=CXX=

CONFIGURE_PREFIX	=/usr
CONFIGURE_OPTIONS	+=--disable-static
CONFIGURE_OPTIONS	+=--enable-shared

# common targets
build:		$(BUILD_32)

install:	$(INSTALL_32)

test:		$(TEST_32)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
