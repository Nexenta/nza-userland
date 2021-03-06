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

#
# Copyright (c) 2010, 2013, Oracle and/or its affiliates. All rights reserved.
#

include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		ntp
COMPONENT_PATCH_VERSION=
COMPONENT_VERSION=	4.2.8p2
COMPONENT_REVISION=	2
HUMAN_VERSION=		$(COMPONENT_VERSION)
IPS_COMPONENT_VERSION=	4.2.8
COMPONENT_PROJECT_URL=	http://www.ntp.org/
COMPONENT_SRC_NAME=	ntp
COMPONENT_SRC=		$(COMPONENT_SRC_NAME)-$(HUMAN_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	 \
    sha256:0d69bc0e95caad43ea04fdad410e756bae1a71e67b1c2bd799b76b55e04c9b31
COMPONENT_ARCHIVE_URL=	http://archive.ntp.org/ntp4/$(COMPONENT_ARCHIVE)
COMPONENT_BUGDB= service/ntp
DEBVERSION=40-0-8

PATCH_LEVEL = 0

ASLR_MODE= $(ASLR_ENABLE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk

COMPONENT_BUILD_ARGS=

CFLAGS +=	-std=c99 -D_XOPEN_SOURCE=600 -D__EXTENSIONS__

CONFIGURE_OPTIONS +=	--bindir=/usr/sbin
CONFIGURE_OPTIONS +=	--with-binsubdir=sbin
CONFIGURE_OPTIONS +=	--libexecdir=/usr/lib/inet
CONFIGURE_OPTIONS +=	--sysconfdir=/etc/inet
CONFIGURE_OPTIONS +=	--enable-all-clocks
CONFIGURE_OPTIONS +=	--enable-debugging
CONFIGURE_OPTIONS +=	--enable-debug-timing
CONFIGURE_OPTIONS +=	--disable-optional-args
CONFIGURE_OPTIONS +=	--enable-parse-clocks
CONFIGURE_OPTIONS +=	--enable-ignore-dns-errors
CONFIGURE_OPTIONS +=	--without-ntpsnmpd
CONFIGURE_OPTIONS +=	--with-openssl-libdir=/lib

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

build:		$(BUILD_32)
install:	$(INSTALL_32)
test:		$(NO_TESTS)

include ../../make-rules/depend.mk
