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

if is_lineinfile "Intel" "${CITELLUS_ROOT}/proc/cpuinfo"; then
    is_lineinfile "intel_iommu=on" "${CITELLUS_ROOT}/proc/cmdline" || echo $"missing intel_iommu=on on kernel cmdline" >&2  && flag=1
    is_lineinfile "iommu=pt" "${CITELLUS_ROOT}/proc/cmdline" || echo $"missing iommu=pt on kernel cmdline" >&2  && flag=1
else
    is_lineinfile "amd_iommu=pt" "${CITELLUS_ROOT}/proc/cmdline" || echo $"missing amd_iommu=pt on kernel cmdline" >&2  && flag=1
fi

if [[ $flag -eq '1' ]]; then
    exit $RC_FAILED
else
    exit $RC_OKAY
fi
