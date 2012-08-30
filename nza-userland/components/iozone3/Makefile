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

COMPONENT_NAME=		iozone3
COMPONENT_VERSION=	408
COMPONENT_SRC=		$(COMPONENT_NAME)_$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar
COMPONENT_ARCHIVE_HASH=	sha1:3dc56a251949151d12fc033f179cb6852abc71de
COMPONENT_ARCHIVE_URL=	http://www.iozone.org/src/current/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/justmake.mk
include ../../make-rules/ips.mk


COMPONENT_PRE_CONFIGURE_ACTION = \
    ($(CLONEY) $(SOURCE_DIR) $(@D))


# common targets

COMPONENT_BUILD_ARGS.32 += -f src/current/makefile Solaris10gcc

build:		$(BUILD_32)
		$(MKDIR) $(BUILD_DIR)/proto/i386/usr/bin
		cp $(BUILD_DIR)/$(MACH32)/src/current/iozone $(BUILD_DIR)/proto/i386/usr/bin
		cp $(BUILD_DIR)/$(MACH32)/src/current/fileop $(BUILD_DIR)/proto/i386/usr/bin
		cp $(BUILD_DIR)/$(MACH32)/src/current/pit_server $(BUILD_DIR)/proto/i386/usr/bin

		


#install:	$(INSTALL_32)


BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
