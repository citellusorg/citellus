#!/bin/bash
# Copyright (C) 2017   Pablo Iranzo Gómez (Pablo.Iranzo@redhat.com)
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Load common functions
[ -f "${CITELLUS_BASE}/common-functions.sh" ] && . "${CITELLUS_BASE}/common-functions.sh"

checksettings(){

    FILE=${CITELLUS_ROOT}/etc/ceilometer/ceilometer.conf
    is_required_file $FILE

    RC=$RC_OKAY

    if [ ${RELEASE} -gt 7 ]; then
        for string in alarm_history_time_to_live event_time_to_live metering_time_to_live; do
            # check for string
            grep -qe ^${string} $FILE
            result=$?
            if [ "$result" -ne "0" ]; then
                echo "$string missing on file" >&2
                RC=$RC_FAILED
            else
                if [ $(grep -c -e ^${string} $FILE) -ne "1" ]; then
                    echo "$string is listed more than once on file" >&2
                    RC=$RC_FAILED
                else
                    if [ $(grep -e ^${string} $FILE|cut -d "=" -f2) -le 0 ]; then
                        RC=$RC_FAILED
                        grep -e ^${string} $FILE >&2
                    fi
                fi
            fi
        done
    else
        for string in time_to_live; do
            if [ $(grep -c -e ^${string} $FILE) -ne "1" ]; then
                echo "$string is listed more than once on file" >&2
                RC=$RC_FAILED
            else
                if [ $(grep -e ^${string} $FILE|cut -d "=" -f2) -le 0 ]; then
                    RC=$RC_FAILED
                    grep -e ^${string} $FILE >&2
                fi
            fi
        done
    fi
}


# Actually run the check

RELEASE=$(discover_osp_version)

if is_process nova-compute;then
    echo "works only on controller node" >&2
    exit $RC_SKIPPED
else
    checksettings
    exit $RC
fi
