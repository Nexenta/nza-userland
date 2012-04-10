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
# Copyright (c) 2012 Nexenta Systems, Inc.  All rights reserved.

include ../../make-rules/shared-macros.mk

COMPONENT_NAME=		iometer
COMPONENT_VERSION=	1.1.0-rc1
#IPS_COMPONENT_VERSION = 1.1.0
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_PROJECT_URL=	http://downloads.sourceforge.net/iometer
COMPONENT_ARCHIVE=	$(COMPONENT_SRC)-src.tar.bz2
COMPONENT_ARCHIVE_HASH=	sha1:33b1f6e35bfefa7a8ccaf5afad2344288a6be7ac
COMPONENT_ARCHIVE_URL=	http://downloads.sourceforge.net/iometer/$(COMPONENT_ARCHIVE)

include ../../make-rules/prep.mk
include ../../make-rules/justmake.mk
include ../../make-rules/ips.mk


#COMPONENT_PRE_CONFIGURE_ACTION = ($(CLONEY) $(SOURCE_DIR) $(@D))

COMPONENT_PREP_ACTION = \
			( cd $(COMPONENT_SRC)/src	;\
			 sed -i -r '/using namespace std;/d;s/([^a-z])(cout|endl|ends|flush|cerr|ostringstream|map<|ifstream)/\1std::\2/g' *.cpp *.h )
				   	



COMPONENT_BUILD_ARGS +=-f src/Makefile-Solaris.i386 dynamo
COMPONENT_BUILD_TARGET +=generic CC=$(CC)


build:		$(BUILD_32)
		$(MKDIR)  $(BUILD_DIR)/proto/i386/usr/bin
		cp $(BUILD_DIR)/$(MACH32)/dynamo $(BUILD_DIR)/proto/i386/usr/bin

test:		
install:	
		

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include ../../make-rules/depend.mk

