#!/bin/bash

# Copyright (C) 2017   Jean-Francois Saucier (jsaucier@redhat.com)

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


# Load common functions
[ -f "${CITELLUS_BASE}/common-functions.sh" ] && . "${CITELLUS_BASE}/common-functions.sh"

# Find release
RELEASE=$(discover_osp_version)

# description: Checks if OSP12 deployment is using containers

# Containerized deployment is only supported option starting in OSP 12
if [ ${RELEASE} -ge 12 ]; then
    if [ -d "${CITELLUS_ROOT}/var/log/containers" ] && [ -d "${CITELLUS_ROOT}/var/lib/config-data" ]; then
        exit $RC_OKAY
    else
        echo $"the OSP 12 deployment seems to not be containerized" >&2
        exit $RC_FAILED
    fi
else
    echo "works only on OSP 12 and later" >&2
    exit $RC_SKIPPED
fi
