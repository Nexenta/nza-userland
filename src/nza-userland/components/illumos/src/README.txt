developer-illumos-deb package is providing tools for generation DEB packages for 
illumos-gate build.

You have to identify variables in Makefile.conf

How it works.

1. You can find installed directory at: /usr/src/illumos-deb
You can copy it to another location if you want

2. go to the directoy where are Makefiles.

3. update Makefile.conf with your variables
Primary variable is: CODEMGR_WS

4. generate Debian stuff:
gmake gen

5. generate DEB files:
gmake pkgs

Note: you ca use flag -j<number> for paralles

Example:
gmake -j8 pkgs

Note: if you want to build one package you can run command:
gmake `pwd`/debs/stemps/<pkg name>.stamp

Example: rebuild package:
rm -f `pwd`/debs/stemps/diagnostic-cpu-counters.stamp
gmake `pwd`/debs/stemps/diagnostic-cpu-counters.stamp

You can find log file at:
`pwd`/debs/pkgsdir/<pkg name>/build.log

Example:
more `pwd`/debs/pkgsdir/diagnostic-cpu-counters/build.log

6. You can find all DEB packages with .changes files at:
<your dir>/debs/pkgs

7. you can install one package by:
dpkg -i <filename.deb>

Example:
dpkg -i text-locale_1.0.2-1_solaris-i386.deb

Note: at this moment if you have to install new driver you have to run 'rem_drv' by hands
after uninstalling by: dpkg -r <pkg name>.
It is problem will be fixed later.

8. you can learn tool 'reprepro' and prepare local APT repo

9. upgrade your local system from your local APT repo by:
apt-clone upgrade

Note: you have to prepare packages with versions: <original>-XX
Example:
original version: 1.0.1
your version: 1.0.1-1

Upgrade proccedure possible only if you have version higher then original.
