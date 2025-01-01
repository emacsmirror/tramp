#  Autoconf script for Tramp                            -*- Autoconf -*-
# To rebuild the `configure' script from this, execute the command
#     autoconf
# in the directory containing this script.

#  Copyright (C) 2003-2025 Free Software Foundation, Inc.

#  This file is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
#  by the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.

#  This file is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

### Code:

# I've tested it with 2.52.  According to the Changelog of Autoconf,
# incompatible changes (with quotation) have appeared since 2.50.
AC_PREREQ([2.50])

# Initialize configure script.  This is the only place Tramp revision
# needs to be set.
AC_INIT([Tramp], [2.8.0-pre], [tramp-devel@gnu.org], ,
	[https://www.gnu.org/software/tramp/])
AC_MSG_NOTICE([$PACKAGE_STRING])

# Declare required Emacs version.  This is the only place Emacs
# revision needs to be set.
EMACS_REQUIRED_VERSION="28.1"
AC_SUBST(EMACS_REQUIRED_VERSION)

# Check suitable make version.
AC_CHECK_PROGS([MAKE], [gmake make], [no])
if test "${MAKE}" = no; then
   AC_MSG_ERROR([make not found])
fi

AC_PROG_MAKE_SET

# Find the Emacs program to be used.  Check version.
AC_EMACS_INFO

# Check suitable makeinfo version.
AC_CHECK_PROG([MAKEINFO], [makeinfo], [makeinfo], [no])
if test "${MAKEINFO}" = no; then
   AC_MSG_ERROR([makeinfo not found])
fi

AC_MSG_CHECKING([for reasonable makeinfo version])
${MAKEINFO} texi/test.texi -o /dev/null 2>/dev/null >/dev/null
if test $? -eq 0; then
   AC_MSG_RESULT([ok])
else
   AC_MSG_RESULT([nok])
   AC_MSG_ERROR([makeinfo is not up-to-date, you need at least Texinfo 4.6])
fi

# Check suitable texi2dvi and texi2pdf versions.  Here we produce a
# warning only, because this shouldn't prevent Tramp exploitation.
if test "${MAKEINFO}" != no; then
   AC_MSG_CHECKING([for reasonable makeinfo --dvi])
   # "-o /dev/null" changes permissions of /dev/null. Not applicable.
   ${MAKEINFO} --dvi texi/test.texi 2>/dev/null >/dev/null
   if test $? -eq 0; then
      TEXI2DVI="yes"
      AC_MSG_RESULT([ok])
   else
      TEXI2DVI="no"
      AC_MSG_RESULT([nok])
      AC_MSG_WARN([makeinfo --dvi doesn't work])
   fi
   AC_SUBST(TEXI2DVI)
   test -e test.log && rm -f test.log
   test -e test.dvi && rm -f test.dvi

AC_MSG_CHECKING([for reasonable makeinfo --pdf])
   # "-o /dev/null" changes permissions of /dev/null. Not applicable.
   ${MAKEINFO} --pdf texi/test.texi 2>/dev/null >/dev/null
   if test $? -eq 0; then
      TEXI2PDF="yes"
      AC_MSG_RESULT([ok])
   else
      TEXI2PDF="no"
      AC_MSG_RESULT([nok])
      AC_MSG_WARN([makeinfo --pdf doesn't work])
   fi
   AC_SUBST(TEXI2PDF)
   test -e test.log && rm -f test.log
   test -e test.pdf && rm -f test.pdf
fi

# Check existence of install-info.  Again, we produce a warning only,
# because this shouldn't prevent Tramp exploitation.
AC_CHECK_PROG([INSTALL_INFO], [install-info], [install-info])
if test -z "${INSTALL_INFO}"; then
   AC_PATH_PROG([INSTALL_INFO], [install-info], [no],
		[$PATH:/usr/sbin:/sbin:/usr/local/bin])
fi
if test "${INSTALL_INFO}" = no; then
   AC_MSG_WARN([install-info not found])
fi

# Checks whether Tramp installation chapter is needed.
# Necessary for maintainers only.
AC_EMACS_INSTALL

# Check target installation directories.
AC_PATH_LISPDIR
AC_PATH_INFODIR

AC_SUBST(abs_builddir)
AC_SUBST(prefix)
AC_SUBST(prefix_default)
AC_SUBST(datarootdir)
AC_SUBST(datarootdir_default)
AC_SUBST(datadir)
AC_SUBST(datadir_default)
AC_SUBST(lispdir)
AC_SUBST(lispdir_default)
AC_SUBST(infodir)
AC_SUBST(infodir_default)

# Define files to be cleaned up.  Applicable in all directories.
TRAMP_CLEAN_FILES=".\\\\\#* \\\\\#* .*~ *~"
TRAMP_CLEAN_FILES="$TRAMP_CLEAN_FILES *.aux *.cp *.cps *.diff *.dvi *.elc"
TRAMP_CLEAN_FILES="$TRAMP_CLEAN_FILES *.fn *.fns *.html *.info *.ky *.log"
TRAMP_CLEAN_FILES="$TRAMP_CLEAN_FILES *.pdf *.pg *.tmp *.toc *.tp *.vr *.vrs"
AC_SUBST([TRAMP_CLEAN_FILES])
# *.elc files must be removed always.  Otherwise, there could be problems
# if they are created with the wrong Emacs flavor.
rm -f lisp/*.elc test/*.elc

# Produce the Makefiles.
TRAMP_CONFIG_FILES="Makefile test/Makefile"
TRAMP_CONFIG_FILES="$TRAMP_CONFIG_FILES lisp/Makefile lisp/trampver.el"
TRAMP_CONFIG_FILES="$TRAMP_CONFIG_FILES texi/Makefile texi/trampver.texi"
AC_SUBST(TRAMP_CONFIG_FILES)
AC_CONFIG_FILES([$TRAMP_CONFIG_FILES])

AC_OUTPUT

# Regenerate autoloads.
AC_MSG_NOTICE([regenerate autoloads])
rm -f lisp/tramp-loaddefs.el
make EMACS=${EMACS} -s -C lisp autoloads
