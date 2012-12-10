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
# Copyright (c) 2012 Nexenta Systems, Inc. All rights reserved.
#

include ../..//make-rules/shared-macros.mk

COMPONENT_NAME         := c-icap
COMPONENT_VERSION      := 0.2.3
COMPONENT_SRC          := c_icap-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE      := c_icap-$(COMPONENT_VERSION).tar.gz
COMPONENT_ARCHIVE_HASH := sha1:5bcb877e17aa667645c352c3ea6c7394cf115ec9
COMPONENT_ARCHIVE_URL  := http://sourceforge.net/projects/c-icap/files/c-icap/0.2.x/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/configure.mk
include $(WS_TOP)/make-rules/ips.mk

COMPILER = gcc
CONFIGURE_OPTIONS       +=CC=gcc
CONFIGURE_OPTIONS       +=CXX=


#CONFIGURE_OPTIONS += "CPPFLAGS= -Iinclude/ -I$(SOURCE_DIR)/include"
CONFIGURE_OPTIONS += --prefix=/
CONFIGURE_OPTIONS += --includedir=/usr/include
CONFIGURE_OPTIONS += --sysconfdir=/etc/c-icap
CONFIGURE_OPTIONS += --localstatedir=/var
CONFIGURE_OPTIONS += --libexecdir=/usr/lib/c_icap

CONFIGURE_SCRIPT = ./configure

COMPONENT_PRE_CONFIGURE_ACTION = \
	($(CLONEY) $(SOURCE_DIR) $(@D))

build:          $(BUILD_32)

install:        $(INSTALL_32)

test:           $(TEST_32)

BUILD_PKG_DEPENDENCIES =        $(BUILD_TOOLS)

include ../../make-rules/depend.mk
