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
# Copyright (C) 2013, Nexenta Systems, Inc. All rights reserved.
#
include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		tcpdrop
COMPONENT_VERSION=	1.4
COMPONENT_SRC=		$(COMPONENT_NAME)-solaris
COMPONENT_ARCHIVE=	tcpdrop_solaris-20080516.tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:c3d4d8de2fff230d81ec89baad1e5fb9c8563ade
COMPONENT_ARCHIVE_URL=http://sunfreeware.cc.uoc.gr/ftp/pub/freeware/SOURCES/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/justmake.mk
include ../../make-rules/ips.mk


build:		$(SOURCE_DIR)/.prep

install:	build
		@cd $(SOURCE_DIR); $(MAKE)
		$(MKDIR) $(PROTO_DIR)/usr/bin
		$(MKDIR) $(PROTO_DIR)/usr/share/man/man8
		$(CP) $(SOURCE_DIR)/tcpdrop $(PROTO_DIR)/usr/bin/
		$(CP) $(SOURCE_DIR)/tcpdrop.8 $(PROTO_DIR)/usr/share/man/man8/

test:	$(NO_TESTS)

clean::
	$(RM) -r $(BUILD_DIR)

include ../../make-rules/depend.mk
