#!/bin/bash

# Copyright (C) 2017   Pablo Iranzo Gómez (Pablo.Iranzo@redhat.com)

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

# we can run this against fs snapshot or live system

# Load common functions
[ -f "${CITELLUS_BASE}/common-functions.sh" ] && . "${CITELLUS_BASE}/common-functions.sh"

is_required_rpm sos

exitoudated(){
  echo "outdated sosreport package <3.4-6: please do update sos package to ensure required info is collected" >&2
  exit $RC_FAILED
}

# Latest sos for el7.4 is 3.4-6.el7
if [ "x$CITELLUS_LIVE" = "x1" ]; then
  SOS_VERSION=$(rpm -qa sos | sed -n -r -e 's/^sos.*-3.4-([0-9]+).*$/\1/p' "${CITELLUS_ROOT}/installed-rpms")
elif [ "x$CITELLUS_LIVE" = "x0" ]; then
  SOS_VERSION=$(sed -n -r -e 's/^sos.*-3.4-([0-9]+).*$/\1/p' "${CITELLUS_ROOT}/installed-rpms")
fi

if [[ -z ${SOS_VERSION} ]]; then
  exitoudated
fi

for package in ${SOS_VERSION}
do
  if [[ "${package}" -lt "6" ]]
  then
    exitoudated
  fi
done
exit $RC_OKAY
