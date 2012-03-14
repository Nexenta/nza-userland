include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  ToscaWidgets
COMPONENT_VERSION  =  0.9.12
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:289354c9424dfccc4c2ccc7a8689cb2033dd6e11
COMPONENT_ARCHIVE_URL  = http://pypi.python.org/packages/source/T/ToscaWidgets/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/setup.py.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

