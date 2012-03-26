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

include ../../make-rules/shared-macros.mk

COMPONENT_NAME         := corosync
COMPONENT_VERSION      := 1.4.2
COMPONENT_PROJECT_URL  := http://www.corosync.org
COMPONENT_SRC          := $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE      := $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH := sha1:0412f7651e81db9a4741ac98e7f9118e57809477
COMPONENT_ARCHIVE_URL  := ftp://ftp:downloads@corosync.org/downloads/$(COMPONENT_SRC)/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/configure.mk
include $(WS_TOP)/make-rules/autoreconf.mk
include $(WS_TOP)/make-rules/ips.mk


# Corosync build system is BS.
LDFLAGS.32 = -L/usr/lib/mps -R/usr/lib/mps
LDFLAGS.64 = -L/usr/lib/mps/64 -R/usr/lib/mps/64
LD.32 = /usr/bin/ld -32
LD.64 = /usr/bin/ld -64
COMPONENT_BUILD_ENV += LD="$(LD.$(BITS))"
COMPONENT_INSTALL_ENV += LD="$(LD.$(BITS))"
LDFLAGS += $(LDFLAGS.$(BITS))
CONFIGURE_OPTIONS += --localstatedir=/var

build:		$(BUILD_32_and_64)

install:	$(INSTALL_32_and_64)

test:		$(NO_TESTS)

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

