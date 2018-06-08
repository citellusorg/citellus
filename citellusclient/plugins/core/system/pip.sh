#!/bin/bash

# Copyright (C) 2017 David Vallee Delisle (dvd@redhat.com)

# Modifications (2018) by David Valle Delisle <dvd@redhat.com>
# Modifications (2018) by Pablo Iranzo Gómez <Pablo.Iranzo@redhat.com>

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

# long_name: Check if pip is installed
# description: pip can create conflicts and have a hard impact on openstack services
# priority: 800

# Load common functions
[[ -f "${CITELLUS_BASE}/common-functions.sh" ]] && . "${CITELLUS_BASE}/common-functions.sh"

if is_rpm python*-pip*  > /dev/null 2>&1; then
    echo $"python pip is detected" >&2
    exit ${RC_FAILED}
else
    echo "no python pip package detected" >&2
    exit ${RC_OKAY}
fi

