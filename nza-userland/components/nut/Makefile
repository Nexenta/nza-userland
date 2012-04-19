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
# Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved.
#
include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		nut
COMPONENT_VERSION=	2.6.2
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:f6ebf1a1835b1ad5a0e5de498451d22e48479943
COMPONENT_ARCHIVE_URL=	http://www.networkupstools.org/source/2.6/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk


CONFIGURE_OPTIONS	+=--with-cgi
CONFIGURE_OPTIONS	+=--with-dev
CONFIGURE_OPTIONS	+=--sysconfdir=/etc/nut
CONFIGURE_OPTIONS	+=--with-drvpath=/usr/lib/nut
CONFIGURE_OPTIONS	+=--with-statepath=/var/run/nut
CONFIGURE_OPTIONS	+=--with-cgipath=/usr/lib/cgi-bin/nut
CONFIGURE_OPTIONS	+=--with-htmlpath=/usr/share/nut/www
CONFIGURE_OPTIONS	+=--with-pidpath=/var/run/nut
CONFIGURE_OPTIONS	+=--with-pkgconfig-dir=/usr/lib/pkgconfig
CONFIGURE_OPTIONS	+=--with-user=nut
CONFIGURE_OPTIONS	+=--with-group=nut
CONFIGURE_OPTIONS	+=--mandir=/usr/share/man
# common targets
build:		$(BUILD_32)

install:	$(INSTALL_32)

test:		$(TEST_32)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
