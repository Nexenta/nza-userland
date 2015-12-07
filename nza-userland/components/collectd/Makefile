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
# Copyright (c) 2014 Nexenta Systems, Inc. All rights reserved.
#

include ../..//make-rules/shared-macros.mk

COMPONENT_NAME         := collectd
COMPONENT_VERSION      := 5.4.1
COMPONENT_SRC          := collectd-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE      := collectd-$(COMPONENT_VERSION).tar.bz2
COMPONENT_ARCHIVE_HASH := sha1:cea47e3936ed081bd71efacf7ba825fc837dc347
COMPONENT_ARCHIVE_URL  := http://collectd.org/files/$(COMPONENT_ARCHIVE)
DEBVERSION:=40-0-2

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/configure.mk
include $(WS_TOP)/make-rules/ips.mk

COMPILER = gcc
#CONFIGURE_SCRIPT = ./configure
CONFIGURE_OPTIONS +=	--prefix=/usr
CONFIGURE_OPTIONS += 	--mandir=/usr/share/man 
CONFIGURE_OPTIONS +=	--sysconfdir=/etc 
CONFIGURE_OPTIONS +=	--bindir=/usr/bin 
CONFIGURE_OPTIONS +=	--libdir=/usr/lib
CONFIGURE_OPTIONS +=	--libexecdir=/usr/libexec 
CONFIGURE_OPTIONS +=	--sbindir=/usr/sbin
CONFIGURE_OPTIONS +=	--localstatedir=/var

CPPFLAGS += -I/usr/include/hal -I/usr/include/dbus-1.0

#COMPONENT_PRE_CONFIGURE_ACTION = \
#	($(CLONEY) $(SOURCE_DIR) $(@D))

build:          $(BUILD_32)

install:        $(INSTALL_32)

test:           $(TEST_NONE)

BUILD_PKG_DEPENDENCIES =        $(BUILD_TOOLS)

include ../../make-rules/depend.mk
