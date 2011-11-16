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
# Copyright (C) 2011, Nexenta Systems, Inc. and/or its affiliates. All rights reserved.
#

include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  wmi
COMPONENT_VERSION  =  1.2
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).tar.bz2
COMPONENT_ARCHIVE_HASH = sha1:26ca3539e045c8cc776180550ddc53a3f1d9d435
COMPONENT_ARCHIVE_URL  = $(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/makemaker.mk

COMPONENT_PRE_BUILD_ACTION = \
	cd $(@D)/wmi/Samba/source && \
	./configure ac_cv_prog_gnu_ld="no" && \
	mkdir -p bin/static && \
	$(GMAKE) proto && \
	$(GMAKE) bin/wmic

build:      $(BUILD_32)
install:    $(INSTALL_32)



include $(WS_TOP)/make-rules/depend.mk

