#!/bin/bash

PATH=/usr/gnu/bin:/usr/bin:/usr/sbin:/sbin

# check the os version
check_os_ver()
{
	ver="`uname -v`"
	oiver=""
	resp="can't determine goodness"

	case "$ver" in
		oi_*)
			oiver=`echo $ver | sed -e 's/^oi_//'`
			;;
		*)
			;;
	esac

	case "$oiver" in
		[0-9][0-9][0-9])
			resp="too old"
			[ "$oiver" -ge 151 ] && resp="ok"
			;;
		*)
			;;
	esac

	echo "OS version: $ver ... $resp"
}

# check the studio version for a given path
_studio_ver()
{
	ver="`"$1/bin/version" | grep '^Sun Studio [0-9]\+'`"
	resp="can't determine goodness"

	case "$ver" in
		"Sun Studio 12 update 1")
			resp="ok"
			;;
		*)
			;;
	esac

	echo "Sun Studio version: $ver ... $resp"
}

# find the right path for studio
check_studio()
{
	for p in /opt/SUNWspro /opt/sunstudio12.1 ; do
		[ ! -x "$p/bin/version" ] && continue

		echo "Sun Studio found ... $p"
		_studio_ver "$p"
		return 0
	done

	echo "Sun Studio not found, skipping version check"
}

# is pkg the right version?
check_pkg_ver()
{
	ver="`/usr/bin/pkg list -H pkg:/package/pkg | \
		/usr/bin/awk '{print $2}' | /usr/bin/sed 's/.*-//g'`"
	resp="can't determine goodness"

	okver=1.1
	ok=`echo "if ($ver >= $okver) r=1 ; if ($ver < $okver) r=2 ; r" | bc`

	case "$ok" in
		2)
			resp="too old"
			;;
		1)
			resp="ok"
			;;
		*)
			;;
	esac

	echo "pkg version: $ver ... $resp"
}

DEF='\e[0m'
BLUE='\e[1;32m'
YELLOW='\e[1;33m'
GREEN='\e[0;32m'
RED='\e[1;31m'

index=0

# check that a given package is installed
_check_pkg()
{
	if dpkg -l | grep $1 > /dev/null 2> /dev/null ; then
		echo "package $1 ... $GREEN installed $DEF"
	else
		echo "package $1 ... $RED not installed $DEF"
		let index++
		missed[index]=$1
	fi


}

# we need all these packages for oi-build
check_pkg_list()
{
	for p in \
		archiver-gnu-tar \
		compress-p7zip \
		compress-unzip \
		developer-build-ant \
		developer-build-autoconf \
		developer-build-automake-110 \
		developer-build-gnu-make \
		developer-build-libtool \
		developer-build-make \
		developer-gcc-44 \
		developer-gcc-gcc \
		developer-library-lint \
		system-library-gcc-44-runtime \
		developer-gnome-gettext \
		developer-java-jdk \
		developer-java-junit \
		developer-lexer-flex \
		developer-macro-cpp \
		developer-macro-gnu-m4 \
		developer-object-file \
		developer-parser-bison \
		developer-versioning-mercurial \
		file-gnu-coreutils \
		file-gnu-findutils \
		library-libtool-libltdl \
		library-libxslt \
		library-python-2-python-extra-26 \
		library-python-2-ply-26 \
		library-python-2-pycurl-26 \
		library-python-2-m2crypto \
		library-python-2-paramiko-26 \
		library-pcre \
		runtime-perl-512 \
		package-pkg \
		system-library-math-header-math \
		text-gawk \
		text-gnu-diffutils \
		text-gnu-gettext \
		text-gnu-grep \
		text-gnu-patch \
		text-gnu-sed \
		text-groff \
		text-texinfo \
		developer-build-autoconf \
		developer-build-automake-110 \
		library-apr \
		library-apr-util \
		library-openldap \
		library-apr-util-apr-ldap \
	; do
		_check_pkg $p
	done
	if [[ ! "${#missed[@]}" -eq "0" ]]; then
	echo
	echo "Warning! These packages are missing:"
	echo ${missed[@]}
	echo "Do you want to install them? [Yes|No]"
	while read answer
	do
	case "$answer" in
	    Yes|yes|Y|y)
		apt-get -y install ${missed[@]}
		break
		;;
	    No|no|N|n)
		echo "Don't forget to install missing packages!"
		break
		;;
	    *)
		echo "Choices are Yes, No"
		continue
	    ;;
	    esac
	done
	fi

}

check_os_ver
check_studio

pkg_path="`which apt-get`"
if [ -z "$pkg_path" ]; then
	echo "apt-get not found, skipping pkg related checks"
	exit 0
fi

echo "apt-get found ... $pkg_path"
#check_pkg_ver
check_pkg_list
