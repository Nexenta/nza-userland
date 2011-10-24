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

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		File-DesktopEntry
COMPONENT_VERSION=	0
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION).04
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:2ab7e9056b745ff5a8530431666c437328b7c7a0
COMPONENT_ARCHIVE_URL=	http://www.cpan.org/authors/id/P/PA/PARDUS/$(COMPONENT_NAME)/$(COMPONENT_ARCHIVE)
COMPONENT_PROJECT_URL=	http://search.cpan.org/~pardus/

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/makemaker.mk

COMPILER = gcc
CONFIGURE_OPTIONS<----->+=CC=cc
COMPONENT_INSTALL_TARGETS=	install


build:		$(BUILD_32)

#install:	$(INSTALL_32)
install:	
	$(COMPONENT_PRE_INSTALL_ACTION)
	(cd $(BUILD_DIR)/i86-5.12; $(ENV) $(COMPONENT_INSTALL_ENV) \
	/usr/perl5/5.12/bin/perl Build --destdir=$(PROTO_DIR) install )
	$(COMPONENT_POST_INSTALL_ACTION)



COMPONENT_TEST_TARGETS = test
test:		$(TEST_32)

BUILD_PKG_DEPENDENCIES =        $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk
