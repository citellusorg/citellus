#!/bin/bash

# Copyright (C) 2017   Robin Cernin (rcernin@redhat.com)

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

if [ ! -f "${CITELLUS_ROOT}/var/log/httpd/error_log" ]; then
  echo "file /var/log/httpd/error_log not found." >&2
  exit $RC_SKIPPED
fi
if grep -q "MaxRequestWorkers" "${CITELLUS_ROOT}/var/log/httpd/error_log"; then
  echo "https://bugzilla.redhat.com/show_bug.cgi?id=1406417" >&2
  exit $RC_FAILED
else
  exit $RC_OKAY
fi
