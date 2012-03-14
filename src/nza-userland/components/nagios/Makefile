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

COMPONENT_NAME=		nagios
COMPONENT_VERSION=	3.2.3
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL=	http://downloads.sourceforge.net/nagios
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:fcb2c016c1b803bac71442d0ee8375b737906421
COMPONENT_ARCHIVE_URL=	http://citylan.dl.sourceforge.net/project/nagios/nagios-3.x/nagios-3.2.3/$(COMPONENT_ARCHIVE)
#COMPONENT_DIR = $(shell pwd)
#SOURCE_DIR=$(COMPONENT_DIR)/nagios

include ../../make-rules/prep.mk

COMPONENT_PRE_CONFIGURE_ACTION = \
    ($(CLONEY) $(SOURCE_DIR) $(@D))



BUILD_DIR_32 = $(BUILD_DIR)/$(MACH32)

include ../../make-rules/configure.mk
include ../../make-rules/ips.mk


CONFIGURE_SCRIPT =$(BUILD_DIR_32)/configure


CONFIGURE_OPTIONS +=	--sbindir=/var/apache2/2.2/cgi-bin/nagios3
CONFIGURE_OPTIONS += 	--datadir=/usr/share/nagios3/htdocs
CONFIGURE_OPTIONS +=	--libexecdir=/usr/lib/nagios/plugins
CONFIGURE_OPTIONS +=	--sysconfdir=/etc/nagios3
CONFIGURE_OPTIONS +=	--localstatedir=/var/lib/nagios3
CONFIGURE_OPTIONs +=	--bindir=/usr/sbin
CONFIGURE_OPTIONS +=	--with-gd-inc=/usr/include
CONFIGURE_OPTIONS +=	--with-gd-lib=/usr/lib
CONFIGURE_OPTIONS += 	--with-httpd-conf=/etc/apache2/2.2
CONFIGURE_OPTIONS +=	--with-nagios-user=nagios
CONFIGURE_OPTIONS +=	--with-nagios-group=nagios
CONFIGURE_OPTIONS +=	--with-command-group=nagios
CONFIGURE_OPTIONS +=	--with-command-user=nagios
CONFIGURE_OPTIONS +=	--with-htmurl=/nagios3
CONFIGURE_OPTIONS +=	--with-cgiurl=/cgi-bin/nagios3


build:		$(BUILD_32)
		cd $(BUILD_DIR_32)
		$(GMAKE) -C $(BUILD_DIR_32) all	

test:		$(TEST_32)

install:	$(INSTALL_32)
		$(GMAKE) -C $(BUILD_DIR_32) install-config

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk

