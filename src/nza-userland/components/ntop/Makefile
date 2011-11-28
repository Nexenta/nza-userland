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
CXX=/usr/bin/g++
COMPONENT_NAME=		ntop
COMPONENT_VERSION=	4.1
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION).0
COMPONENT_PROJECT_URL=	
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:11cd397e5524fa72652d840ce1b92631f8bf39a2
COMPONENT_ARCHIVE_URL= http://citylan.dl.sourceforge.net/project/ntop/ntop/Stable/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk

CONFIGURE_OPTIONS +=		--sysconfdir=/etc
CONFIGURE_OPTIONS +=		--localstatedir=/var/lib
CONFIGURE_OPTIONS +=		--bindir=/usr/sbin
CONFIGURE_OPTIONS +=		--enable-tcpwrap
CONFIGURE_OPTIONS +=		--disable-plugins
CONFIGURE_OPTIONS +=		--with-gd-lib=/usr/lib
CONFIGURE_OPTIONS +=		--with-gd-include=/usr/include
CONFIGURE_OPTIONS +=		--with-zlib-lib=/usr/lib
CONFIGURE_OPTIONS +=		--with-zlib-include=/usr/include
CONFIGURE_OPTIONS +=		--with-libpng-lib=/usr/lib
CONFIGURE_OPTIONS +=		--with-libpng-include=/usr/include
CONFIGURE_OPTIONS +=		--with-sslv3
CONFIGURE_OPTIONS +=		--enable-i18n

build: $(BUILD32)

test: $(TEST32)

install: $(INSTALL_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk

