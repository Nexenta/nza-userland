include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  PasteDeploy
COMPONENT_VERSION  =  1.5.0
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:4bae6b28b5243af0e4c0f40b7f20037d1a0ae846
COMPONENT_ARCHIVE_URL  = http://pypi.python.org/packages/source/P/PasteDeploy/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/setup.py.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

