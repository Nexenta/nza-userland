include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  WWW-RobotRules
COMPONENT_VERSION  =  6
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION).01
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:426920bbfc73a38dffa319dd2f53b0eb9b294b5b
COMPONENT_ARCHIVE_URL  = http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/$(COMPONENT_ARCHIVE)

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/makemaker.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

