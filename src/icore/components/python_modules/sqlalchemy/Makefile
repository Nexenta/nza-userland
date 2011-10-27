include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  SQLAlchemy
COMPONENT_VERSION  =  0.7.3
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:9b29a712b1138a24e9d04228f80b004f2e33a4f8
COMPONENT_ARCHIVE_URL  = http://pypi.python.org/packages/source/S/SQLAlchemy/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/setup.py.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

