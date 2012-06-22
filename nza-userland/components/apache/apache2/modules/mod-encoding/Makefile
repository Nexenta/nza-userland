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
#
include $(WS_TOP)/make-rules/shared-macros.mk

COMPILER               = studio
COMPONENT_NAME         = mod_encoding
COMPONENT_VERSION      = 20060316
COMPONENT_SRC          = $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE      = $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:3677e991d7b0b0fef81f229ab6c51fcce81bc0d5
COMPONENT_ARCHIVE_URL  = http://iij.dl.sourceforge.jp/webdav/19350/$(COMPONENT_ARCHIVE)
COMPONENT_DIR          = $(shell pwd)
SOURCE_DIR             = $(COMPONENT_DIR)/mod_encoding

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/configure.mk
include $(WS_TOP)/make-rules/ips.mk

APACHE_USR_PREFIX=/usr/apache2/2.2

APXS.32=	$(APACHE_USR_PREFIX)/bin/apxs
APXS.64=	$(APACHE_USR_PREFIX)/bin/$(MACH64)/apxs

$(BUILD_DIR_32)/.built: APXS=$(APXS.32)
$(BUILD_DIR_64)/.built: APXS=$(APXS.64)


CONFIGURE_OPTIONS += --with-apxs=$(APXS.$(BITS))
CONFIGURE_OPTIONS += --with-apr=`$(APXS.$(BITS)) -q APR_CONFIG`
CONFIGURE_OPTIONS += --with-apu=`$(APXS.$(BITS)) -q APU_CONFIG`

# Need to get right version of C compiler and GNU sed first.
PATH=$(SPRO_VROOT)/bin:/usr/gnu/bin:/usr/bin

# Some patches need configure script re-creation.

CONFIGURE_SCRIPT = $(PWD)/mod_encoding/lib/configure




build: $(BUILD_32_and_64)
	cd $(COMPONENT_DIR)/mod_encoding/
	$(APXS.32) -c mod_encoding.so mod_encoding/mod_encoding.c
	mv mod_encoding/.libs/mod_encoding.so build/i86/.libs/
	$(APXS.64) -c mod_encoding.so mod_encoding/mod_encoding.c
	mv mod_encoding/.libs/mod_encoding.so build/amd64/.libs/

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk
