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
# Copyright (c) 2012. Nexenta Systems, Inc. All rights reserved.
#

include ../../make-rules/shared-macros.mk

COMPONENT_NAME         := hyperload
COMPONENT_VERSION      := 0.0.2
COMPONENT_SRC          := $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL  := https://hg.nexenta.com/projects/hyperload
COMPONENT_ARCHIVE      := $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH := sha1:8d4cfee5d6fa272f2a48e46e0fe018ccb9c6f36e
COMPONENT_ARCHIVE_URL  := file://$(COMPONENT_ARCHIVE)


include ../../make-rules/prep.mk
include ../../make-rules/configure.mk
include ../../make-rules/ips.mk

COMPONENT_PRE_CONFIGURE_ACTION = $(CLONEY) $(SOURCE_DIR) $(@D);

build:		$(BUILD_32) build-module

build-module:	
	cd $(BUILD_DIR_32)/solaris.kernel && \
		$(MAKE) CC="$(CC)"

install:	$(INSTALL_32) install-module
install-module:	build-module
	mkdir -p $(PROTO_DIR)/usr/kernel/amd64
	mkdir -p $(PROTO_DIR)/usr/sbin
	cp $(BUILD_DIR_32)/solaris.kernel/ivshmemctl \
		$(PROTO_DIR)/usr/sbin/

	cp $(BUILD_DIR_32)/solaris.kernel/kvm_ivshmem \
		$(PROTO_DIR)/usr/kernel/amd64/


test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
