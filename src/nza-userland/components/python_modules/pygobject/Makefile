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
# Copyright (C) 2011, Nexenta Systems, Inc. All rights reserved.
#

include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  pygobject
COMPONENT_VERSION_MAIN = 2.21
COMPONENT_VERSION  =  $(COMPONENT_VERSION_MAIN).5
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).tar.bz2
COMPONENT_ARCHIVE_HASH = sha1:8017d5dba28278727501194d45310d3156937c70
COMPONENT_ARCHIVE_URL  = http://ftp.gnome.org/pub/GNOME/sources/pygobject/$(COMPONENT_VERSION_MAIN)/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/configure.mk


CONFIGURE_OPTIONS += --disable-introspection
CONFIGURE_OPTIONS += am_cv_python_pythondir=$(PYTHON_VENDOR_PACKAGES)
CONFIGURE_OPTIONS += am_cv_python_pyexecdir=$(PYTHON_VENDOR_PACKAGES)

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

