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
# Copyright (c) 2013 Nexenta Systems, Inc. All rights reserved.
#

include ../../make-rules/shared-macros.mk

COMPONENT_NAME         := crypt-ca-certificates
COMPONENT_ARCHIVE_1    := src/SUNWcs-certs.tgz
COMPONENT_ARCHIVE_2    := src/crypto-ca-certificates.tgz

include $(WS_TOP)/make-rules/ips.mk

clean::
	rm -rf $(BUILD_DIR)

build:
	$(MKDIR) $(BUILD_DIR)

install:
	mkdir -p $(PROTO_DIR)
	tar xzf  $(COMPONENT_ARCHIVE_1) -C $(PROTO_DIR)
	tar xzf  $(COMPONENT_ARCHIVE_2) -C $(PROTO_DIR)

test:

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk
