dnl  Copyright (C) 2003-2024 Free Software Foundation, Inc.

dnl  This file is free software: you can redistribute it and/or modify
dnl  it under the terms of the GNU General Public License as published by
dnl  the Free Software Foundation, either version 3 of the License, or
dnl (at your option) any later version.

dnl  This file is distributed in the hope that it will be useful,
dnl  but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl  GNU General Public License for more details.

dnl  You should have received a copy of the GNU General Public License
dnl  along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

dnl Most functions are initially stolen from gnus.  Thanks for all the fish!

dnl
dnl Execute Lisp code
dnl
AC_DEFUN(AC_EMACS_LISP, [
  EM="${EMACS} --no-site-file -batch -eval"
  elisp="$2"
  if test -z "$3"; then
     AC_MSG_CHECKING(for $1)
  fi

  AC_CACHE_VAL(EMACS_cv_SYS_$1, [
    OUTPUT=./conftest-$$
    echo ${EM} "(let ((x ${elisp})) (write-region (if (stringp x) (princ x) (prin1-to-string x)) nil \"${OUTPUT}\"))" >& AS_MESSAGE_LOG_FD 2>&1
    ${EM} "(let ((x ${elisp})) (write-region (if (stringp x) (princ x 'ignore) (prin1-to-string x)) nil \"${OUTPUT}\"nil 5))" >& AS_MESSAGE_LOG_FD 2>&1
    if test ! -e "${OUTPUT}"; then
      AC_MSG_RESULT()
      AC_MSG_ERROR([calling ${EMACS}])
    fi
    retval=`cat ${OUTPUT}`
    echo "=> ${retval}" >& AS_MESSAGE_LOG_FD 2>&1
    rm -f ${OUTPUT}
    EMACS_cv_SYS_$1=$retval
  ])
  $1=${EMACS_cv_SYS_$1}
  if test -z "$3"; then
     AC_MSG_RESULT($$1)
  fi
])

dnl
dnl Checks Emacs for proper version.  Result for `EMACS' is the program to run.
dnl
AC_DEFUN(AC_EMACS_INFO, [

  dnl Apparently, if you run a shell window in Emacs, it sets the EMACS
  dnl environment variable to 't'.  Lets undo the damage.
  if test "x${EMACS}" = "x" -o "x${EMACS}" = "xt"; then
     EMACS=emacs
  fi

  dnl Check parameter.
  AC_ARG_WITH(
    emacs,
    AS_HELP_STRING([--with-emacs[=PROG]],
      [ use Emacs to build [PROG=emacs] ]),
    [ if test "${withval}" = "yes"; then EMACS=emacs; else EMACS=${withval}; fi ])

  dnl Check program availability.
  EMACS_NOT_FOUND="$EMACS not found"
  AC_PATH_PROG([EMACS], [$EMACS], [no], [$PATH:/])
  if test "${EMACS}" = no; then
    AC_MSG_ERROR([$EMACS_NOT_FOUND])
  fi

  TRAMP_EMACS_VERSION_CHECK="\
  (if (not (string-version-lessp emacs-version \"${EMACS_REQUIRED_VERSION}\"))
      \"ok\"
    (format \"${PACKAGE_STRING} is not fit for %s\"
            (replace-regexp-in-string \"\\n\" \"\" (emacs-version))))"
  AC_SUBST(TRAMP_EMACS_VERSION_CHECK)

  AC_MSG_CHECKING([for $EMACS version])
  AC_EMACS_LISP(emacs_version, $TRAMP_EMACS_VERSION_CHECK, "noecho")
  if test "${EMACS_cv_SYS_emacs_version}" = "ok"; then
     AC_MSG_RESULT(ok)
  else
     AC_MSG_RESULT(nok)
     AC_MSG_ERROR([$EMACS_cv_SYS_emacs_version])
  fi

  dnl Check gvfs support. It is assumed that D-Bus bindings are sufficient.
  AC_MSG_CHECKING([for $EMACS gvfs support])
  AC_EMACS_LISP(
    gvfsp,
    (if (featurep 'dbusbind) \"yes\" \"no\"),
    "noecho")
  EMACS_GVFS=$EMACS_cv_SYS_gvfsp
  AC_MSG_RESULT($EMACS_GVFS)
  AC_SUBST(EMACS_GVFS)
])

dnl
dnl Checks whether Tramp is prepared for Emacs package.  This case,
dnl the installation chapter is not part of the manual.  Necessary for
dnl maintainers only.
dnl
AC_DEFUN(AC_EMACS_INSTALL, [

  INSTALL_CHAPTER=yes

  dnl Check parameter.
  AC_MSG_CHECKING([for installation chapter])
  AC_ARG_WITH(
    packaging,
    AS_HELP_STRING([--with-packaging],
      [ installation chapter not needed in manual ]),
    [ if test "${withval}" = "yes"; then INSTALL_CHAPTER=no; fi ])

  dnl Check proper makeinfo version.  If it is older than 6.x, it is
  dnl not prepared for the trampinst.texi construct.
  if test "${MAKEINFO}" != "no" && test "${INSTALL_CHAPTER}" != "no" ; then
    case `($MAKEINFO --version) 2>/dev/null` in
      *' (GNU texinfo) '[[6-9]]* | \
      *' (GNU texinfo) '[[1-9][0-9]]* ) ;;
      *) INSTALL_CHAPTER=no;;
    esac
  fi

  AC_MSG_RESULT($INSTALL_CHAPTER)
  AC_SUBST(INSTALL_CHAPTER)

  TRAMP_BUGREPORT_TEXI=`\echo $PACKAGE_BUGREPORT | sed -n -e 's/@/@@/p'`
  AC_SUBST(TRAMP_BUGREPORT_TEXI)
])

dnl
dnl Return install target for Lisp files.
dnl
AC_DEFUN(AC_PATH_LISPDIR, [

  dnl Check prefix.
  AC_MSG_CHECKING([prefix])

  prefix_default=$ac_default_prefix
  if test "${prefix}" = NONE; then
     prefix=$prefix_default
  fi

  AC_MSG_RESULT([$prefix])

  dnl Check datarootdir.
  AC_MSG_CHECKING([datarootdir])

  datarootdir_default="\${prefix}/share"
  if test "${datarootdir}" = "\${prefix}/share"; then
     datarootdir=$datarootdir_default
  fi

  AC_MSG_RESULT([$datarootdir])

  dnl Check datadir.
  AC_MSG_CHECKING([datadir])

  datadir_default="\$datarootdir_default"

  if test "${datadir}" = NONE; then
     datadir=$datadir_default
  fi

  AC_MSG_RESULT([$datadir])

  dnl Check lispdir.
  AC_ARG_WITH(
    lispdir,
    AS_HELP_STRING([--with-lispdir=DIR],
      [ where to install lisp files [DATADIR/emacs/site-lisp] ]),
    lispdir=${withval})
  AC_MSG_CHECKING([lispdir])

  lispdir_default="\${datadir}/emacs/site-lisp"

  : ${lispdir:=$lispdir_default}

  dnl Expand $lispdir_default for trampinst.texi.  We need to apply `eval'
  dnl several times, because $prefix, $datarootdir and $datadir must be
  dnl expanded in an unknown order.
  lispdir_default=$(eval eval eval echo ${lispdir_default})

  AC_MSG_RESULT($lispdir)
])

dnl
dnl A user can still specify someplace else with
dnl '--infodir=DIR'.
dnl
AC_DEFUN(AC_PATH_INFODIR, [

  dnl Check infodir.
  AC_MSG_CHECKING([infodir])

  dnl Check default places.
  infodir_default="\${datadir}/info"

  dnl If default directory doesn't exist, derive from $prefix.
  dnl ${prefix} and ${datadir} must be expanded for test.
  if ! test -d $(eval eval eval echo ${infodir_default})
  then
     infodir_default="\${prefix}/info"
  fi

  dnl If default directory doesn't exist, derive from $prefix_default.
  dnl ${prefix} and ${datadir} must be expanded for test.
  if ! test -d $(eval eval eval echo ${infodir_default})
  then
     infodir_default="\${prefix_default}/info"
  fi

  dnl Set it if necessary.
  if test "${infodir}" = "\${prefix}/info"; then
     infodir=$infodir_default
  fi

  dnl Expand $datarootdir.
  infodir=$(echo ${infodir} | sed -e "s#[$][{]datarootdir[}]#$datarootdir#")

  dnl Expand $infodir_default for trampinst.texi.  We need to apply it
  dnl several times, because $prefix, $datarootdir and $datadir need
  dnl to be expanded in an unknown order.
  infodir_default=$(eval eval eval echo ${infodir_default})

  AC_MSG_RESULT([$infodir])
])
