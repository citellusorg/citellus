#!/bin/bash

# Copyright (C) 2017   Robin Černín (rcernin@redhat.com)

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

# description: Checks for token cleanup last execution

# this can run against live and also fs snapshot

# Load common functions
[ -f "${CITELLUS_BASE}/common-functions.sh" ] && . "${CITELLUS_BASE}/common-functions.sh"

is_required_file "${CITELLUS_ROOT}/var/log/keystone/keystone.log"

LASTRUN=$(awk '/Total expired tokens removed/ { print $1 " " $2 }' "${CITELLUS_ROOT}/var/log/keystone/keystone.log" | tail -1)
[[ "x${LASTRUN}" = "x" ]] && exit $RC_FAILED || echo "${LASTRUN}" >&2 && exit $RC_OKAY
