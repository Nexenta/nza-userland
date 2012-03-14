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
# Copyright (c) 2011 Nexenta Systems, Inc.  All rights reserved.

include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		lsof
COMPONENT_VERSION=	4.85
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:7e532d06c20dd6fb9021a821f0fa569c0dbd1f58
COMPONENT_ARCHIVE_URL=	ssh:/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk

CONFIGURE_OPTIONS =	-n solaris
CONFIGURE_SCRIPT =	$(@D)/Configure$(BITS)

COMPONENT_PRE_CONFIGURE_ACTION = \
    ( $(CLONEY) $(SOURCE_DIR) $(BUILD_DIR)/$(MACH$(BITS)))

COMPONENT_POST_INSTALL_ACTION = \
	( $(MKDIR) $(PROTO_DIR)/usr/bin/amd64; \
	$(MKDIR) $(PROTO_DIR)/usr/bin/i86; \
	$(MKDIR) $(PROTO_DIR)/usr/share/man/man8; \
	cd $(BUILD_DIR)/i86 && ginstall -m 2755 -g sys lsof $(PROTO_DIR)/usr/bin/i86/; \
	cd $(BUILD_DIR)/amd64 && ginstall -m 2755 -g sys lsof $(PROTO_DIR)/usr/bin/amd64/; \
	cd $(SOURCE_DIR) && ginstall -m 444 lsof.8 $(PROTO_DIR)/usr/share/man/man8 )

build:		$(BUILD_32_and_64)

install:	$(INSTALL_32)

test:		$(TEST_32)


BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk

