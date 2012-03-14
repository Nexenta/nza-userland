#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license
# at http://www.opensource.org/licenses/CDDL-1.0
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each file.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
# Copyright (c) 2012, Nexenta Systems, Inc. All rights reserved.
#
#
include ../../make-rules/shared-macros.mk

COMPONENT_NAME         := boost
COMPONENT_VERSION      := 1.49.0
# 1_49_0:
TARBALL_VERSION        := $(subst .,_,$(COMPONENT_VERSION))
COMPONENT_SRC          := $(COMPONENT_NAME)_$(TARBALL_VERSION)
COMPONENT_ARCHIVE      := $(COMPONENT_SRC).tar.bz2
COMPONENT_ARCHIVE_HASH := sha1:26a52840e9d12f829e3008589abf0a925ce88524
COMPONENT_ARCHIVE_URL  := http://sourceforge.net/projects/boost/files/boost/$(COMPONENT_VERSION)/$(COMPONENT_ARCHIVE)
COMPONENT_PROJECT_URL  := http://www.boost.org

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/justmake.mk
include $(WS_TOP)/make-rules/ips.mk

# For wmemcmp and friends:
CFLAGS += -D_XPG5

PREFIX = /usr
LIBDIR.32 = $(PREFIX)/lib
LIBDIR.64 = $(PREFIX)/lib/$(MACH64)

COMPONENT_BUILD_ENV += PREFIX=$(PREFIX)
COMPONENT_BUILD_ENV += LIBDIR=$(LIBDIR.$(BITS))

# Makefile - wrapper around bjam:
COMPONENT_PRE_BUILD_ACTION = ( \
	ln -sf $(COMPONENT_DIR)/make-boost.mk $(@D)/Makefile && \
	echo 'using gcc : : $(CXX) ;' >> $(@D)/user-config.jam && \
	true )

build: $(BUILD_32_and_64)

install: $(INSTALL_32_and_64)

test: $(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

