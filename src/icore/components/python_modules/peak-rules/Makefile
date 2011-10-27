include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  PEAK-Rules
COMPONENT_VERSION  =  0.5a1.dev
COMPONENT_REV      =  r2707
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION)-$(COMPONENT_REV)
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:2a64e0cd55abcbe1686c9731c085bc7a8982fd1e
COMPONENT_ARCHIVE_URL  = http://peak.telecommunity.com/snapshots/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/setup.py.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

