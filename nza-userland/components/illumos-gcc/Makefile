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
#
# Copyright (C) 2012, Nexenta Systems, Inc. All rights reserved.
#

include ../../make-rules/shared-macros.mk

# ******************************
# *   THIS IS BINARY PACKAGE   *
# *    WE DO NOT COMPILE IT    *
# ******************************


COMPONENT_NAME         := illumos-gcc
COMPONENT_VERSION      := 4.4.4
COMPONENT_SRC          := $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL  := https://github.com/richlowe/gcc
COMPONENT_ARCHIVE      := il-gcc-444-i386.tar.bz2
COMPONENT_ARCHIVE_HASH := sha1:a72c5fa66b89db05d7823aafcfca140d410b756d
COMPONENT_ARCHIVE_URL  := http://richlowe.openindiana.org/~richlowe/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/ips.mk


build:

install:
	tar xf $(COMPONENT_ARCHIVE)
	mkdir -p $(PROTO_DIR)/opt
	cp -r gcc $(PROTO_DIR)/opt/

clean::
	rm -rf gcc
	rm -rf $(BUILD_DIR)

test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
