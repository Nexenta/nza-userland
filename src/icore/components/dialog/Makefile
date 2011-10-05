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

COMPONENT_NAME=		dialog
COMPONENT_VERSION=	1.1
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)-20100428
COMPONENT_ARCHIVE=	$(COMPONENT_NAME)_$(COMPONENT_VERSION)-20100428.orig.tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:6945b302bf5b107c12f6009c25699d265b45579c
COMPONENT_ARCHIVE_URL=	http://ftp.de.debian.org/debian/pool/main/d/dialog/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk

COMPILER = gcc
CONFIGURE_OPTIONS	+=CC=cc
CONFIGURE_OPTIONS	+=CXX=

CONFIGURE_PREFIX	=/usr

# common targets
build:		$(BUILD_32)

install:	$(INSTALL_32)

test:		$(TEST_32)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
