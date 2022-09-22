#!/bin/sh

# Copyright (C) 2014 Nikos Mavrogiannopoulos
#
# This file is part of GnuTLS.
#
# GnuTLS is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3 of the License, or (at
# your option) any later version.
#
# GnuTLS is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GnuTLS; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

#set -e

: ${srcdir=.}
: ${CERTTOOL=../../src/certtool${EXEEXT}}
: ${DIFF=diff}
OUTFILE=provable-privkey.tmp

if ! test -x "${CERTTOOL}"; then
	exit 77
fi

if ! test -z "${VALGRIND}"; then
	VALGRIND="${LIBTOOL:-libtool} --mode=execute ${VALGRIND}"
fi

${VALGRIND} "${CERTTOOL}" --generate-privkey --provable --bits 2048 --dsa --seed "$SEED" --outfile "$OUTFILE"
rc=$?

if test "${rc}" != "0"; then
	echo "Could not generate a 2048-bit DSA key"
	exit 1
fi

${VALGRIND} "${CERTTOOL}" --verify-provable-privkey --load-privkey "$OUTFILE" &
PID1=$!

${VALGRIND} "${CERTTOOL}" --verify-provable-privkey --load-privkey "$OUTFILE" --seed "$SEED" &
PID2=$!

wait $PID1
rc1=$?

wait $PID2
rc2=$?

if test "${rc1}" != "0" || test "${rc2}" != "0"; then
	echo "Could not verify the generated parameters"
	exit 1
fi

rm -f "$OUTFILE"

exit 0
