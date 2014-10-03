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

COMPONENT_VERSION = 13.0.2
COMPONENT_NAME = libsodium
DEBVERSION:=40-0-0

include $(WS_TOP)/make-rules/ips.mk

clean::
	rm -rf $(BUILD_DIR)

build:
	$(MKDIR) $(BUILD_DIR)
	git clone https://github.com/jedisct1/libsodium.git $(BUILD_DIR)
	cd $(BUILD_DIR) && ./autogen.sh
	cd $(BUILD_DIR) && ./configure --disable-ssp
	cd $(BUILD_DIR) && gmake
	$(MKDIR) $(BUILD_DIR)/proto/i386/usr/include
	$(MKDIR) $(BUILD_DIR)/proto/i386/usr/lib
	$(CP) -a $(BUILD_DIR)/src/libsodium/.libs/* $(BUILD_DIR)/proto/i386/usr/lib
	$(CP) -a $(BUILD_DIR)/src/libsodium/include/* $(BUILD_DIR)/proto/i386/usr/include
	cd $(BUILD_DIR) && gmake clean
	cd $(BUILD_DIR) && (CFLAGS=-m64 ./configure --disable-ssp)
	cd $(BUILD_DIR) && gmake
	$(MKDIR) $(BUILD_DIR)/proto/i386/usr/lib/amd64
	$(CP) -a $(BUILD_DIR)/src/libsodium/.libs/* $(BUILD_DIR)/proto/i386/usr/lib/amd64

install:

test:

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk
