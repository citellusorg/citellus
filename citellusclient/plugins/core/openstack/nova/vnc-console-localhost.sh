#!/bin/bash

# Copyright (C) 2017 Robin Černín (rcernin@redhat.com)

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

# this can run against live and also any sort of snapshot of the filesystem

# description: Checks nova's vnc console ip address is set to localhost

# Reference: https://bugzilla.redhat.com/show_bug.cgi?id=1468101


# Load common functions
[ -f "${CITELLUS_BASE}/common-functions.sh" ] && . "${CITELLUS_BASE}/common-functions.sh"

is_required_file "${CITELLUS_ROOT}/etc/nova/nova.conf"

if is_lineinfile "^vncserver_listen.*=.*127.0.0.1" "${CITELLUS_ROOT}/etc/nova/nova.conf"; then
    echo $"nova's vnc console listening on 127.0.0.1" >&2
    exit $RC_FAILED
elif ! is_lineinfile "^vncserver_listen" "${CITELLUS_ROOT}/etc/nova/nova.conf"; then
    echo $"nova's vnc console listening on 127.0.0.1" >&2
    exit $RC_FAILED
else
    grep "^vncserver_listen" "${CITELLUS_ROOT}/etc/nova/nova.conf" >&2
    exit $RC_OKAY
fi
