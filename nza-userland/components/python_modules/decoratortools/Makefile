include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  DecoratorTools
COMPONENT_VERSION  =  1.8
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).zip
COMPONENT_ARCHIVE_HASH = sha1:f8876d4e2a744600a51ed126214b9729a713fa5d
COMPONENT_ARCHIVE_URL  = http://pypi.python.org/packages/source/D/DecoratorTools/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/setup.py.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

