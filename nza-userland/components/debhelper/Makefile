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
# Copyright (c) 2012, Nexenta Sysytems, Inc. All rights reserved.
#

include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		debhelper
IPS_COMPONENT_VERSION=	8.9.13
COMPONENT_VERSION=	$(IPS_COMPONENT_VERSION)~bpo60+1
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_NAME)_$(COMPONENT_VERSION).tar.gz
COMPONENT_ARCHIVE_HASH=	sha1:e490c73b3af89857875bca80303e831f4c84d1fd
COMPONENT_ARCHIVE_URL=	http://snapshot.debian.org/archive/debian-backports/20111222T214010Z/pool/main/d/debhelper/$(COMPONENT_ARCHIVE)
COMPONENT_PROJECT_URL=	http://kitenet.net/~joey/code/debhelper/

include ../../make-rules/prep.mk
include ../../make-rules/ips.mk
include $(WS_TOP)/make-rules/deb.mk

PATH=/usr/gnu/bin:/usr/bin:$(PERL_PATH)/$(PERL_VERSION)/bin

COMPONENT_BUILD_ENV += PATH="$(PATH)"
COMPONENT_BUILD_ARGS = build
COMPONENT_INSTALL_ARGS = install -P$(PROTO_DIR)

# common targets
build:		$(BUILD_32)

install:	$(INSTALL_32)

# build does this always
test:		$(TEST_32)

clean::
	$(RM) -r $(BUILD_DIR)

# build the configured source
$(BUILD_DIR)/%/.built:	$(SOURCE_DIR)/.prep
	$(FIND) $(SOURCE_DIR) -name '*~' | xargs $(RM)
	$(RM) -r $(@D) ; $(MKDIR) $(@D)
	$(CP) -rp $(SOURCE_DIR)/. $(@D)
	$(CP) -p $(COMPONENT_DIR)/patches/dh_* $(@D)
	(cd $(@D) ; \
	$(ENV) $(COMPONENT_BUILD_ENV) \
		./run dh $(COMPONENT_BUILD_ARGS))
	$(TOUCH) $@

# install the built source into a prototype area
$(BUILD_DIR)/%/.installed:	$(BUILD_DIR)/%/.built
	(cd $(@D) ; \
	$(ENV) $(COMPONENT_INSTALL_ENV) \
		./run dh $(COMPONENT_INSTALL_ARGS))
	$(TOUCH) $@

BUILD_PKG_DEPENDENCIES =	$(BUILD_TOOLS)

include ../../make-rules/depend.mk
