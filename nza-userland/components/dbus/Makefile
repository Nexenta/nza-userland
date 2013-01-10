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
# Copyright (c) 2013 Nexenta Systems, Inc.  All rights reserved.
#
#
include ../../make-rules/shared-macros.mk

DEBVERSION = 40-0-9

COMPONENT_NAME         = dbus
COMPONENT_VERSION      = 1.4.24
COMPONENT_SRC          = $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE      = $(COMPONENT_NAME)-$(COMPONENT_VERSION).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:02de59fe8a05a04b81e96acbac7d88c9513d1a0b
COMPONENT_ARCHIVE_URL  = http://dbus.freedesktop.org/releases/dbus/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk

CONFIGURE_PREFIX =	/usr
CONFIGURE_OPTIONS += --localstatedir=/var
CONFIGURE_OPTIONS += --with-dbus-user=root
CONFIGURE_OPTIONS += --without-x
CONFIGURE_OPTIONS += --disable-tests

CONFIGURE_OPTIONS.32 += --bindir=$(CONFIGURE_PREFIX)/bin
CONFIGURE_OPTIONS.32 += --libdir=$(CONFIGURE_PREFIX)/lib
CONFIGURE_OPTIONS.32 += --libexecdir=$(CONFIGURE_PREFIX)/lib
CONFIGURE_OPTIONS.32 += --with-dbus-daemondir=$(CONFIGURE_PREFIX)/lib

CONFIGURE_OPTIONS.64 += CFLAGS="$(CFLAGS) -m64"
CONFIGURE_OPTIONS.64 += --bindir=$(CONFIGURE_PREFIX)/bin/$(MACH64)
CONFIGURE_OPTIONS.64 += --libdir=$(CONFIGURE_PREFIX)/lib/$(MACH64)
CONFIGURE_OPTIONS.64 += --libexecdir=$(CONFIGURE_PREFIX)/lib/$(MACH64)
CONFIGURE_OPTIONS.64 += --with-dbus-daemondir=$(CONFIGURE_PREFIX)/lib/$(MACH64)

build: $(BUILD_32_and_64)

install: $(INSTALL_32_and_64)

test: $(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
