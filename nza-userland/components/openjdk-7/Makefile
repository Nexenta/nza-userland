#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# Copyright 2013 Alexander Pyhalov.  All rights reserved.
# Copyright (c) 2014, Nexenta Systems, Inc. All rights reserved.

include ../../make-rules/shared-macros.mk

COMPONENT_NAME= oppenjdk-7
DEBVERSION=40-0-0

OPENJDK_BUILD_NUMBER=60
COMPONENT_VERSION=1.7.$(OPENJDK_BUILD_NUMBER)
COMPONENT_SUMMARY= Open-source implementation of the Java Platform, Standard Edition
COMPONENT_SRC= openjdk
COMPONENT_ARCHIVE= openjdk-$(COMPONENT_VERSION)-20140614.tar.bz2
COMPONENT_ARCHIVE_HASH= \
  sha256:6b2a05e609b0772490e7d68e20efcd76f13881132b0234905bb2b09da680fb82
COMPONENT_ARCHIVE_URL= \
  http://ftp.edgebsd.org/pub/pkgsrc/distfiles/openjdk7/$(COMPONENT_ARCHIVE)
COMPONENT_PROJECT_URL = http://openjdk.java.net/

COMPONENT_ARCHIVE_1=cups-headers.tar.gz
COMPONENT_ARCHIVE_URL_1=http://mirrors.omniti.com/cups/$(COMPONENT_ARCHIVE_1)
COMPONENT_ARCHIVE_2=openwin.tar.gz
COMPONENT_ARCHIVE_URL_2=http://mirrors.omniti.com/Xstuff/$(COMPONENT_ARCHIVE_2)


CLEAN_PATHS += $(BUILD_DIR)

include ../../make-rules/prep.mk
include ../../make-rules/ips.mk

PATCH_LEVEL=0
COMPONENT_PREP_ACTION += $(UNPACK) $(USERLAND_ARCHIVES)$(COMPONENT_ARCHIVE_1) ;
COMPONENT_PREP_ACTION += $(UNPACK) $(USERLAND_ARCHIVES)$(COMPONENT_ARCHIVE_2) ;

COMPONENT_PREP_ACTION += cp -a openwin /tmp ;
COMPONENT_PREP_ACTION += cp -a cups /tmp ;

# build the configured source
# We need to copy, not use CLONEY, so this part of Makefile is rewritten
$(BUILD_DIR)/%/.built: $(SOURCE_DIR)/.prep
	$(RM) -r $(@D) ; $(MKDIR) $(@D)
	chmod -R u+r  $(SOURCE_DIR)
	cp -a $(SOURCE_DIR)/* $(@D)
	$(COMPONENT_PRE_BUILD_ACTION)
	(cd $(@D) ; $(ENV) $(COMPONENT_BUILD_ENV) \
		$(GMAKE) $(COMPONENT_BUILD_GMAKE_ARGS) $(COMPONENT_BUILD_ARGS) \
		$(COMPONENT_BUILD_TARGETS))
	$(COMPONENT_POST_BUILD_ACTION)
ifeq   ($(strip $(PARFAIT_BUILD)),yes)
	-$(PARFAIT) build
endif
	$(TOUCH) $@

PATH=/opt/SUNWspro/bin:/usr/gnu/bin:/usr/bin
COMPILER=studio

COMPONENT_ENV+=      LANG=C
COMPONENT_ENV+=      ALT_BOOTDIR=/usr/java
COMPONENT_ENV+=      ALT_FREETYPE_HEADERS_PATH=/usr/include/freetype2
COMPONENT_ENV+=      HOTSPOT_BUILD_JOBS=1
COMPONENT_ENV+=      NO_DOCS=true
COMPONENT_ENV+=	     MILESTONE="fcs"
COMPONENT_ENV+=	     BUILD_HEADLESS_ONLY=true 
COMPONENT_ENV+=	     BUILD_HEADLESS=true
COMPONENT_ENV+=	     FULL_DEBUG_SYMBOLS=0
COMPONENT_ENV+=	     ENABLE_FULL_DEBUG_SYMBOLS=0
COMPONENT_ENV+=	     ALT_BOOTDIR="/usr/java"
COMPONENT_ENV+=	     ALT_COMPILER_PATH="/opt/SUNWspro/bin"
COMPONENT_ENV+=	     ALT_UNIXCCS_PATH=/usr/bin
COMPONENT_ENV+=      ALT_OPENWIN_HOME=/tmp/openwin/X11
COMPONENT_ENV+=	     ALT_CUPS_HEADERS_PATH=/tmp/cups/include

COMPONENT_BUILD_ENV =   $(COMPONENT_ENV)

COMPONENT_BUILD_ARGS =

$(BUILD_DIR)/%/.installed: $(BUILD_DIR)/%/.built
		$(MKDIR) $(PROTO_DIR)/usr/jdk/instances/openjdk1.7.0
		cp -a $(@D)/build/solaris-*/j2sdk-image/* $(PROTO_DIR)/usr/jdk/instances/openjdk1.7.0
		$(TOUCH) $@
clean::
	rm -rf $(BUILD_DIR)
	rm -rf $(COMPONENT_DIR)/openwin*
	rm -rf $(COMPONENT_DIR)/cups*

build: $(BUILD_32)

install: $(INSTALL_32)

.NOTPARALLEL:
