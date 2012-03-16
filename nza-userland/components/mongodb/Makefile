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
# Copyright (c) 2012, Nexenta Systems, Inc. All rights reserved.
#
#
include ../../make-rules/shared-macros.mk

COMPONENT_NAME         := mongodb
COMPONENT_VERSION      := 2.0.3
COMPONENT_SRC          := $(COMPONENT_NAME)-src-r$(COMPONENT_VERSION)
COMPONENT_ARCHIVE      := $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH := sha1:b6821a8436ce1867b49cad86a855df81499a831c
COMPONENT_ARCHIVE_URL  := http://downloads.mongodb.org/src/$(COMPONENT_ARCHIVE)
COMPONENT_PROJECT_URL  := http://www.mongodb.org

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk


# Scons really sucks. Clone everything to build dir:
$(BUILD_DIR)/%/.configured:	$(SOURCE_DIR)/.prep
	$(RM) -r $(@D) ; $(MKDIR) $(@D)
	$(CLONEY) $(SOURCE_DIR) $(@D)
	touch $@

# Scons sucks even more. Will build when installing:
$(BUILD_DIR)/%/.built:	$(BUILD_DIR)/%/.configured
	touch $@

# Never ever use Scons. bindir and friends are not supported,
# will move files in IPS manifest:
$(BUILD_DIR)/%/.installed:	$(BUILD_DIR)/%/.built
	cd $(@D) && scons \
		--cc="$(CC)" \
		--cxx="$(CXX)" \
		--prefix="$(PROTO_DIR)/$*/usr" \
		install
	touch $@

build: $(BUILD_32_and_64)

install: $(INSTALL_32_and_64)


test: $(NO_TESTS)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

