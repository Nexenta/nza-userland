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

COMPONENT_NAME=		clamav
COMPONENT_VERSION=	0.97.2
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL=	http://downloads.sourceforge.net/clamav
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:27d47c6ad22edc87c030f6d483fab1e13320cbf7
COMPONENT_ARCHIVE_URL=	http://downloads.sourceforge.net/clamav/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk

CONFIGURE_OPTIONS +=		--prefix=/usr
CONFIGURE_OPTIONS +=		--disable-clamuko
CONFIGURE_OPTIONS +=		--disable-unrar
CONFIGURE_OPTIONS +=		--disable-milter
CONFIGURE_OPTIONS +=		--with-dbdir=/var/lib/clamav
CONFIGURE_OPTIONS +=		--sysconfdir=/etc/clamav
CONFIGURE_OPTIONS +=		--with-system-tommath
CONFIGURE_OPTIONS +=		--enable-dns-fix


build: $(BUILD32)

test: 
	$(TEST_32)

install: $(INSTALL_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk

