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

# description: Checks for various DPDK configuration parameters

# Load common functions
[ -f "${CITELLUS_BASE}/common-functions.sh" ] && . "${CITELLUS_BASE}/common-functions.sh"

# Actual code execution
flag=0

# Execute only on OSP nodes
is_required_rpm openstack.*common

# Run this code on controllers, not on computes nor director
if ! is_process nova-compute; then
    if ! is_lineinfile "^scheduler_defaults.*NUMATopologyFilter" "${CITELLUS_ROOT}/etc/nova/nova.conf"; then
        echo $"missing NUMATopologyFilter in nova.conf" >&2
        flag=1
    fi
fi

if [ $CITELLUS_LIVE -eq 0 ]; then
    FILEOVSVSCTL="${CITELLUS_ROOT}/sos_commands/openvswitch/ovs-vsctl_-t_5_get_Open_vSwitch_._other_config"
elif [ $CITELLUS_LIVE -eq 1 ];then
    FILEOVSVSCTL=$(mktemp)
    trap "rm $FILEOVSVSCTL" EXIT
    ovs-vsctl -t 5 get Open_vSwitch . other_config > $FILE
fi

if is_lineinfile "dpdk-init.*true" "${FILEOVSVSCTL}";then
    # DPDK is supposedly enabled, do further checks

    if ! is_lineinfile "dpdk-socket-mem=" "${FILEOVSVSCTL}";then
        echo $"missing dpdk-socket-mem in ovs-vsctl" >&2
        flag=1
    fi
    if ! is_lineinfile "dpdk-lcore-mask=" "${FILEOVSVSCTL}";then
        echo $"missing dpdk-lcore-mask= (Core list) in ovs-vsctl" >&2
        flag=1
    fi
    if ! is_lineinfile "pmd-cpu-mask=" "${FILEOVSVSCTL}";then
        echo $"missing pmd-cpu-mask= (pmd cpu mask) in ovs-vsctl" >&2
        flag=1
    fi
fi

if ! is_lineinfile "isolcpus" "${CITELLUS_ROOT}/proc/cmdline"; then
    # Check Systemd as alternative:
    # The only step required is hence to configure the CPUAffinity option in /etc/systemd/system.conf.
    # Systemd CPUAffinity should be 'negative' of ISOLCPU's so need to get all CPU's and reverse
    END=$(grep ^processor ${CITELLUS_ROOT}/proc/cpuinfo|sort|tail -1|cut -d ":" -f 2)
    procids=$(seq 0 $END)
    systemdaffinity=$(grep CPUAffinity ${CITELLUS_ROOT}/etc/systemd/system.conf|cut -d "=" -f 2)

    # Loop for getting reversed array (items not in)
    isolated=""
    for i in ${procids[@]}; do
        present=0
        for j in ${systemdaffinity[@]}; do
            if [ $i -eq $j ];then
                present=1
            fi
        done
        if [ $present -eq 0 ];then
            isolated="$isolated $i"
        fi
    done
    ISOLCPUS=$isolated
elif is_lineinfile isolcpus ${CITELLUS_ROOT}/proc/cmdline; then
    ISOLCPUS=$(cat ${CITELLUS_ROOT}/proc/cmdline|tr " " "\n"|grep isolcpus|cut -d "=" -f 2-)
else
    unset ISOLCPUS
fi


# Nova CPU PIN SET
VCPUPINSET=$(grep vcpu_pin_set ${CITELLUS_ROOT}/etc/nova/nova.conf)

# cat overcloud-compute-0/sos_commands/openvswitch/ovs-vsctl_-t_5_get_Open_vSwitch_._other_config
# {dpdk-init="true", dpdk-lcore-mask="41041", dpdk-socket-mem="2048,2048", pmd-cpu-mask="082082"}

# Mask provided is 00041041 hex, which translates to binary:
# H rL
# 1000001000001000001

# Expand MASK to binary
DPDK-LCORE-MASK=$(cat ${FILEOVSVSCTL}|tr " ," "\n"|grep dpdk-lcore-mask|cut -d "=" -f 2)
echo "obase=2; ibase=16; $DPDK-LCORE-MASK" | bc

LCORECPUS=""
# Expand LCORE MASK into CPU numbers in string
for CPU in $(seq 1 ${#DPDK-LCORE-MASK});do
    CPU=$(((CPU -1)))
    if [ ${DPDK-LCORE-MASK:$CPU:1} -eq 1 ];then
        LCORECPUS="$LCORECPUS $CPU"
    fi
done


# The pmd-cpu-mask is 082082, meaning:
# 1000 0010 0000 1000 0010

# CPU 1, CPU 7, CPU 13, CPU 19

# Expand MASK to binary
DPDK-PMD-MASK=$(cat ${FILEOVSVSCTL}|tr " ," "\n"|grep pmd-cpu-mask|cut -d "=" -f 2)
echo "obase=2; ibase=16; $DPDK-LCORE-MASK" | bc

PMDCPUS=""
# Expand PMD MASK into CPU numbers in string
for CPU in $(seq 1 ${#DPDK-PMD-MASK});do
    CPU=$(((CPU -1)))
    if [ ${DPDK-PMD-MASK:$CPU:1} -eq 1 ];then
        PMDCPUS="$PMDCPUS $CPU"
    fi
done


# DPDK: NeutronBridgeMappings: 'dpdk:br-link'
#  NeutronDpdkCoreList: "'4,6,20,22'"
#  NeutronDpdkMemoryChannels: "4"
#  NeutronDpdkDriverType: "vfio-pci"
#  NeutronDatapathType: "netdev"
# HostIsolatedCoreList
# HostCpusList
# NovaReservedHostMemory

# DPDK upstream: https://github.com/openvswitch/ovs/blob/v2.5.0/INSTALL.DPDK.md
# ovs-vswitchd --dpdk
# ifaces with dpdk$NUM


if [[ $flag -eq '1' ]]; then
    exit $RC_FAILED
else
    exit $RC_OKAY
fi
