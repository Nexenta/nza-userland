dnl
dnl		clamav-milter.m4
dnl
dnl configure sendmail to use clamav-milter
dnl
dnl written by Elrond <elrond@samba-tng.org> 2004
dnl
dnl
INPUT_MAIL_FILTER(`clamav', `S=local:/var/run/clamav/clamav-milter.ctl, F=, T=S:4m;R:4m')dnl
dnl
dnl INPUT_MAIL_FILTER usualy already does the right thing
dnl to confINPUT_MAIL_FILTERS, but to be sure, we do it
dnl again, if necessary.
dnl
dnl 	if confINPUT_MAIL_FILTERS set:
dnl 		if it contains clamav
dnl			do nothing
dnl		else
dnl			append ", clamav"
dnl	else
dnl		set it to "clamav"
dnl
ifdef(`confINPUT_MAIL_FILTERS',
  `ifelse(regexp(`,'defn(`confINPUT_MAIL_FILTERS')`,', `, *clamav *,'),
          `-1',
    `define(`confINPUT_MAIL_FILTERS',
      defn(`confINPUT_MAIL_FILTERS')`, clamav')')',
  `define(`confINPUT_MAIL_FILTERS', `clamav')')dnl
