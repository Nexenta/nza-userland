include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  MarkupSafe
COMPONENT_VERSION  =  0.15
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:81e0c898c289721d5b1aa70ffc0dfc35886ea92a
COMPONENT_ARCHIVE_URL  = http://pypi.python.org/packages/source/M/MarkupSafe/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/setup.py.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

