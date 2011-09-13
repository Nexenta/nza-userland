AC_INIT(cppunit-test-example,1.0)
AM_INIT_AUTOMAKE

AC_PROG_CXX
AC_PROG_LIBTOOL

# Locate CppUnit (minimum version 1.8.0) for testing.  
AM_PATH_CPPUNIT(1.8.0)

# You can set up an automake conditional and use it to conditionally
# build cppunit-using test programs.
AM_CONDITIONAL(HAVE_CPPUNIT, test "$CPPUNIT_LIBS")

AC_CONFIG_FILES([
Makefile
ClockerPlugIn/Makefile
DumperPlugIn/Makefile
cppunittest/Makefile
hierarchy/Makefile
money/Makefile
simple/Makefile
])
AC_OUTPUT

