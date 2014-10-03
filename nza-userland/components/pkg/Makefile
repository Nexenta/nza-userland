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

COMPONENT_VERSION = 0.5.11
COMPONENT_NAME = pkg
DEBVERSION:=40-0-3

include $(WS_TOP)/make-rules/ips.mk

clean::
	rm -rf $(BUILD_DIR)

build:
	$(MKDIR) $(BUILD_DIR)
	git clone git://github.com/OpenIndiana/pkg5.git $(BUILD_DIR)
	$(GPATCH) -d $(BUILD_DIR) -p1 < patches/01-pkgdep.patch
	cd $(BUILD_DIR)/src && python setup.py install
	$(MKDIR) $(BUILD_DIR)/proto/i386
	$(MV) $(BUILD_DIR)/proto/root_i386/* $(BUILD_DIR)/proto/i386/

install:

test:

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk
