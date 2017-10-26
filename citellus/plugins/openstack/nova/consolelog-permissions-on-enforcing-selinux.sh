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

# Load common functions
[ -f "${CITELLUS_BASE}/common-functions.sh" ] && . "${CITELLUS_BASE}/common-functions.sh"

# check if we are running against compute

is_processs nova-compute || echo "works only on compute node" >&2 && exit $RC_SKIPPED


# sos_commands/logs/journalctl_--no-pager_--boot:Oct 26 09:48:13 <$HOST> audispd[2931]: node=<$HOST> type=AVC msg=audit(1509018493.996:37841): avc:  denied  { unlink } for  pid=11312 comm="virtlogd" name="console.log" dev="dm-2"  ino=78 scontext=system_u:system_r:virtlogd_t:s0-s0:c0.c1023 tcontext=system_u:object_r:svirt_image_t:s0:c185,c643 tcl ass=file


MESSAGE=$"AVC denial for console.log: https://bugzilla.redhat.com/show_bug.cgi?id=1501957 https://bugzilla.redhat.com/show_bug.cgi?id=1491767"

if [ "x$CITELLUS_LIVE" = "x0" ];  then
    if [ -z "${journalctl_file}" ]; then
        echo "file /sos_commands/logs/journalctl_--no-pager_--boot not found." >&2
        echo "file /sos_commands/logs/journalctl_--all_--this-boot_--no-pager not found." >&2
        exit $RC_SKIPPED
    fi
    is_lineinfile '.*avc:.*denied.*unlink.*virtlogd.*name="console.log".*' ${journalctl_file} && echo "$MESSAGE" >&2 && exit $RC_FAILED
elif [ "x$CITELLUS_LIVE" = "x1" ]; then
    if journalctl --no-pager --boot | grep -qe '.*avc:.*denied.*unlink.*virtlogd.*name="console.log".*'; then
        echo "$MESSAGE" >&2
        exit $RC_FAILED
    fi
fi

exit $RC_OKAY