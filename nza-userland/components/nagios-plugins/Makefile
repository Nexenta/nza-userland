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
# Copyright (c) 2011 Nexenta Systems, Inc.  All rights reserved.

include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		nagios-plugins
COMPONENT_VERSION=	1.4.15
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL=	http://www.nagios.org/
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:1faab309c06d37e559490fd852ecb0dc8a8ab610
COMPONENT_ARCHIVE_URL=	http://prdownloads.sourceforge.net/sourceforge/nagiosplug/$(COMPONENT_ARCHIVE)
#COMPONENT_DIR = $(shell pwd)
#aSOURCE_DIR=$(COMPONENT_DIR)/nagios

include ../../make-rules/prep.mk

COMPONENT_PRE_CONFIGURE_ACTION = \
    ($(CLONEY) $(SOURCE_DIR) $(@D))



BUILD_DIR_32 = $(BUILD_DIR)/$(MACH32)

include ../../make-rules/configure.mk
include ../../make-rules/ips.mk


CONFIGURE_OPTIONS += 	--with-nagios-user=nagios
CONFIGURE_OPTIONS += 	--with-nagios-group=nagios
CONFIGURE_OPTIONS +=	--libexecdir=/usr/lib/nagios3/plugins
CONFIGURE_OPTIONS +=	--with-cgiurl=/cgi-bin/nagios3


CONFIGURE_SCRIPT =$(BUILD_DIR_32)/configure




build:		$(BUILD_32)

test:		$(TEST_32)

install:	$(INSTALL_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk

