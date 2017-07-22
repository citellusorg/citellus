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

if [ ! -f "${CITELLUS_ROOT}/var/spool/cron/keystone" ]; then
  echo "file /var/spool/cron/keystone not found." >&2
  exit 2
fi
if ! grep -q "keystone-manage token_flush" "${CITELLUS_ROOT}/var/spool/cron/keystone"; then
  echo "crontab keystone cleanup is not set" >&2
  exit 1
elif grep -q "keystone-manage token_flush" "${CITELLUS_ROOT}/var/spool/cron/keystone"; then
  exit 0
fi
exit 3
