#
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
# Copyright (c) 2012, Nexenta Systems, Inc. All rights reserved.
#
include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=         dpkg-brand-zone
COMPONENT_VERSION=      1.1

include $(WS_TOP)/make-rules/ips.mk

download prep build:
	@echo "nothing to be done for $@"

install: 
	$(MKDIR) $(PROTO_DIR)
	$(CP) -r src/* $(PROTO_DIR)

test:	$(NO_TESTS)

clean::
	$(RM) -r $(BUILD_DIR)

include $(WS_TOP)/make-rules/depend.mk
