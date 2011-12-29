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
# Copyright (c) 2011, Nexenta Systems, Inc. All rights reserved.
#

include ../../make-rules/shared-macros.mk

COMPONENT_NAME         = db
COMPONENT_VERSION      = 4.6.21
COMPONENT_SRC          = $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE      = $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:5be3beb82e42a78ff671a3f5a4c30e5652972119
COMPONENT_ARCHIVE_URL  = http://download.oracle.com/berkeley-db/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk


CONFIGURE_SCRIPT = $(SOURCE_DIR)/dist/configure

CXX +=	$(gcc_NORUNPATH)

CFLAGS   += $(CPP_LARGEFILES) $(CC_PIC)
CXXFLAGS += $(CPP_LARGEFILES)

CONFIGURE_ENV += PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)"
CONFIGURE_ENV += JAVA_HOME="$(JAVA_HOME)"

CONFIGURE_OPTIONS += --disable-static
CONFIGURE_OPTIONS += --enable-cxx
CONFIGURE_OPTIONS += --enable-java
CONFIGURE_OPTIONS += --enable-jdbc
CONFIGURE_OPTIONS += --enable-shared
CONFIGURE_OPTIONS += --enable-tcl
CONFIGURE_OPTIONS += --enable-test
CONFIGURE_OPTIONS += --with-tcl=/usr/lib


build:		$(BUILD_32_and_64)

install:	$(INSTALL_32_and_64)

test:		$(TEST_32_and_64) 


BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
