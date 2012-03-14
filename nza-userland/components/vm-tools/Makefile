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

include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		open-vm-tools
COMPONENT_VERSION=	2011.07.19
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)-450511
COMPONENT_ARCHIVE=	$(COMPONENT_NAME)-$(COMPONENT_VERSION)-450511.tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:9290ceab0343a5f8fc6e2b9b9f8125eb7d3756fa
COMPONENT_ARCHIVE_URL=	http://sourceforge.net/projects/open-vm-tools/files/open-vm-tools/2011.07.19/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk


COMPONENT_INSTALL_ARGS += DESTDIR=$(PROTO_DIR)
CONFIGURE_OPTIONS +=--prefix=/usr
CONFIGURE_OPTIONS +=--without-x
CONFIGURE_OPTIONS +=--without-dnet
CONFIGURE_OPTIONS +=--without-icu
CONFIGURE_OPTIONS +=--without-gtkmm
CONFIGURE_OPTIONS +=--enable-static=no

CONFIGURE_OPTIONS +=--bindir=$(CONFIGURE_PREFIX)/bin/$(MACH32)
CONFIGURE_OPTIONS +=--sbindir=$(CONFIGURE_PREFIX)/sbin/$(MACH32)

CONFIGURE_OPTIONS.2 +=CFLAGS="$(CFLAGS) -m64"
CONFIGURE_OPTIONS.2 +=--prefix=/usr
CONFIGURE_OPTIONS.2 +=--without-x
CONFIGURE_OPTIONS.2 +=--without-dnet
CONFIGURE_OPTIONS.2 +=--without-icu
CONFIGURE_OPTIONS.2 +=--without-gtkmm
CONFIGURE_OPTIONS.2 +=--enable-static=no

CONFIGURE_OPTIONS.2 +=--bindir=$(CONFIGURE_PREFIX)/bin/$(MACH64)
CONFIGURE_OPTIONS.2 +=--sbindir=$(CONFIGURE_PREFIX)/sbin/$(MACH64)
CONFIGURE_OPTIONS.2 +=--libdir=$(CONFIGURE_PREFIX)/lib/$(MACH64)
CONFIGURE_OPTIONS.2 +=--libexecdir=$(CONFIGURE_PREFIX)/lib/$(MACH64)


# common targets
build:		$(BUILD_32) 
		$(MKDIR) -p $(PROTO_DIR)/kernel/drv/amd64

install:	$(INSTALL_32)
		(cd $(SOURCE_DIR); $(ENV) sed 's/userSpaceBitness="32"/userSpaceBitness="64"/' \
		configure > configure.1; \
		mv configure.1 configure; chmod 755 configure; \
		$(CONFIGURE_SCRIPT) $(CONFIGURE_OPTIONS.2))
		$(COMPONENT_POST_CONFIGURE_ACTION)
		(cd $(SOURCE_DIR); $(ENV) $(COMPONENT_BUILD_ENV) \
		$(GMAKE))
		(cd $(SOURCE_DIR); $(ENV) $(COMPONENT_INSTALL_ENV) $(GMAKE) \
		$(COMPONENT_INSTALL_ARGS) $(COMPONENT_INSTALL_TARGETS))

test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk

