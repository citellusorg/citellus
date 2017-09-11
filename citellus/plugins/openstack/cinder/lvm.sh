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



checksettings(){
FILE=${CITELLUS_ROOT}/etc/cinder/cinder.conf

if [ ! -f $FILE ];
then
    # Skip test if file is missing
    echo "${FILE#$CITELLUS_ROOT} does not exist" >&2
    exit $RC_SKIPPED
fi

RC=0
substring=cinder.volume.drivers.lvm.LVM

for string in volume_driver;
do
    # check for string
    grep -qe ^${string} $FILE
    result=$?
    if [ "$result" -ne "0" ];
    then
        echo "$string missing on file" >&2
        RC=$RC_FAILED
    else
        if [ $(grep -e ^${string} $FILE|cut -d "=" -f2|grep ${substring}|wc -l) -gt 0 ];
        then
            RC=$RC_FAILED
            grep -e ^${string} $FILE >&2
        fi
    fi
done
}


# Actually run the check

if [ "x$CITELLUS_LIVE" = "x0" ];  then
  # Check which version we are using
  if [ -f ${CITELLUS_ROOT}/installed-rpms ];
  then
    if grep -q nova-compute "${CITELLUS_ROOT}/ps";
    then
      echo "works only on controller node" >&2
      exit $RC_SKIPPED
    fi
    checksettings
    exit $RC
  else
    echo "Missing required file /installed-rpms" >&2
    exit $RC_SKIPPED
  fi
elif [ "x$CITELLUS_LIVE" = "x1" ];  then
  # Check which version we are using
  if ps -elf | grep -q [n]ova-compute;
  then
    echo "works only on controller node" >&2
    exit $RC_SKIPPED
  fi
  checksettings
  exit $RC
fi
