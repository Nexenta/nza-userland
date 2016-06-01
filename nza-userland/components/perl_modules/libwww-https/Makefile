include ../../../make-rules/shared-macros.mk
COMPONENT_NAME     =  LWP-Protocol-https
COMPONENT_VERSION  =  6
COMPONENT_SRC      =  $(COMPONENT_NAME)-$(COMPONENT_VERSION).06
COMPONENT_ARCHIVE  =  $(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH = sha1:210a2f7ba3f82ffc7a18836d0a4356986080d407
COMPONENT_ARCHIVE_URL  = http://search.cpan.org/CPAN/authors/id/M/MS/MSCHILLI/$(COMPONENT_ARCHIVE)
DEBVERSION:=40-0-1

include $(WS_TOP)/make-rules/prep.mk
include $(WS_TOP)/make-rules/ips.mk
include $(WS_TOP)/make-rules/makemaker.mk

build:      $(BUILD_32)
install:    $(INSTALL_32)

COMPONENT_TEST_TARGETS = test
test:       $(TEST_32)

BUILD_PKG_DEPENDENCIES = $(BUILD_TOOLS)

include $(WS_TOP)/make-rules/depend.mk

