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
# Copyright (C) 2013, Nexenta Systems, Inc. All rights reserved.
#

include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		watch
COMPONENT_VERSION=	3.2.7
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:b974daef61424b6a1f2fc72bc0337a058da4fe8f
COMPONENT_ARCHIVE_URL=	http://ftp.ussg.iu.edu/solaris/freeware/SOURCES/$(COMPONENT_ARCHIVE)

UNPACK_ARGS= -r $(COMPONENT_SRC)

include ../../make-rules/prep.mk
include ../../make-rules/justmake.mk
include ../../make-rules/ips.mk

build:		$(SOURCE_DIR)/.prep

install:	build
		@cd $(SOURCE_DIR); $(MAKE) all
		$(MKDIR) $(PROTO_DIR)/usr/bin
		$(MKDIR) $(PROTO_DIR)/usr/share/man/man1
		$(CP) $(SOURCE_DIR)/watch $(PROTO_DIR)/usr/bin/
		$(CP) $(SOURCE_DIR)/watch.1 $(PROTO_DIR)/usr/share/man/man1/

test:	$(NO_TESTS)

clean::
	$(RM) -r $(BUILD_DIR)

include ../../make-rules/depend.mk
