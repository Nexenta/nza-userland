APR_CFLAGS = `apr-config --cppflags --includes --cflags`
SVN_INC = -I$(DEB_SRCDIR)/subversion/include
CFLAGS     += -Wall \
		$(SVN_INC) \
		$(APR_CFLAGS)

all: default-config

default-config: clean svn-make-config
	./svn-make-config

svn-make-config: svn-make-config.o
	libtool --mode=link gcc svn-make-config.o $(DEB_BUILDDIR)/subversion/libsvn_client/libsvn_client-1.la -o svn-make-config

clean:
	$(RM) svn-make-config svn-make-config.o
	rm -rf svn-defaults
	rm -rf .libs

.PHONY: clean
