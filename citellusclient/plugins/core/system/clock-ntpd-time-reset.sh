#!/bin/bash

# Copyright (C) 2017 Pablo Iranzo Gómez (Pablo.Iranzo@redhat.com)

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# long_name: NTPd time resets because of time syncs
# description: Checks for ntpd time resets

# Load common functions
[ -f "${CITELLUS_BASE}/common-functions.sh" ] && . "${CITELLUS_BASE}/common-functions.sh"

if ! is_active ntpd;then
    echo "ntpd is not active" >&2
    exit $RC_FAILED
fi

is_required_file "${CITELLUS_ROOT}/var/log/messages"
if is_lineinfile "time reset" "${CITELLUS_ROOT}/var/log/messages"; then
    grep "time reset" "${CITELLUS_ROOT}/var/log/messages" > &2
    exit $RC_FAILED
fi
exit $RC_OKAY
