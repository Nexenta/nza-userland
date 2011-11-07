include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  pycryptopp
COMPONENT_VERSION  =  0.5.29
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:53127f9f9748c159f99700684c86098c2e96573d
COMPONENT_ARCHIVE_URL  = http://pypi.python.org/packages/source/p/pycryptopp/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/setup.py.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

