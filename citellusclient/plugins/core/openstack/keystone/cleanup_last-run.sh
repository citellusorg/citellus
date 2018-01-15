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

# long_name: Keystone token clean-up last execution date
# description: Checks for token cleanup last execution
# priority: 900

# this can run against live and also fs snapshot

# Load common functions
[ -f "${CITELLUS_BASE}/common-functions.sh" ] && . "${CITELLUS_BASE}/common-functions.sh"

is_required_file "${CITELLUS_ROOT}/var/log/keystone/keystone.log"

if [[ "${CITELLUS_LIVE}" = "1" ]]; then
    NOW=$(date "+%s")
else
    is_required_file "${CITELLUS_ROOT}/date"
    NOW=$(date -d "$(cat ${CITELLUS_ROOT}/date)" "+%s" 2>/dev/null)
    if [[ "$?" == "1" ]]; then
        # failure when converting date, happened with one specific TZ, so let's approx by removing TZ
        NOW=$(date -d "$(cat ${CITELLUS_ROOT}/date |awk '{print $1" "$2" "$3" "$4" "$6}')" "+%s")
    fi
fi

LASTRUN=$(awk '/Total expired tokens removed/ { print $1 " " $2 }' "${CITELLUS_ROOT}/var/log/keystone/keystone.log" | tail -1)
if [[ "x${LASTRUN}" = "x" ]];then
    echo "no recorded last run of token removal" >&2
    exit $RC_FAILED
else
    # Not just last run, but we also want it to be 'recent'
    epochdate=$(date -d "${LASTRUN}" "+%s")

    if are_dates_diff_over 2 "$NOW" "$epochdate"; then
        echo $"Last token run was more than two days ago" >&2
        echo $RC_FAILED
    fi
    echo "${LASTRUN}" >&2
    exit $RC_OKAY
fi
