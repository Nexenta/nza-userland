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
# Copyright (c) 2014, Nexenta Systems, Inc. All rights reserved.
#

include ../../make-rules/shared-macros.mk

COMPONENT_NAME         = dpkg
COMPONENT_VERSION      = 1.16.1.1
COMPONENT_SRC          = $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL  = http://debian.org
COMPONENT_ARCHIVE      = $(COMPONENT_NAME)_$(COMPONENT_VERSION).tar.bz2
COMPONENT_ARCHIVE_HASH = sha1:578c312accfaabf240f1cb8f6e13cfdabd8d8027
COMPONENT_ARCHIVE_URL  = http://ftp.de.debian.org/debian/pool/main/d/dpkg/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/configure.mk
include $(WS_TOP)/make-rules/ips.mk


CPPFLAGS += -Du_int32_t=uint32_t -Du_int64_t=uint64_t -Du_int8_t=uint8_t

CONFIGURE_OPTIONS += ac_cv_header_kvm_h=no
CONFIGURE_OPTIONS += --disable-linker-optimisations
CONFIGURE_OPTIONS += --without-start-stop-daemon
CONFIGURE_OPTIONS += --localstatedir=/var
CONFIGURE_OPTIONS += --with-zlib
CONFIGURE_OPTIONS += --with-bz2

build:		$(BUILD_32)

install:	$(INSTALL_32)

test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk
