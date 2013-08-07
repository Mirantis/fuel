#    Copyright 2013 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.


# == Define: cluster::virtual_ip
#
# Configure VirtualIP resource for corosync/pacemaker.
#
# === Parameters
#
# [*name*]
#   Name of virtual IP resource
#
# [*vip*]
#   Specify dictionary of VIP parameters, ex:
#   {
#       nic    => 'eth0', 
#       ip     => '10.1.1.253'
#   }
#
define cluster::virtual_ip (
  $vip,
  $key = $name,
){
  $cib_name = "vip__${key}"
  $vip_name = "vip__${key}"

  cs_shadow { $cib_name: cib => $cib_name }
  cs_commit { $cib_name: cib => $cib_name }
  ::corosync::cleanup { $vip_name: }

  Cs_commit[$cib_name] -> ::Corosync::Cleanup[$vip_name]
  Cs_commit[$cib_name] ~> ::Corosync::Cleanup[$vip_name]

  cs_resource { $vip_name:
    ensure          => present,
    cib             => $cib_name,
    primitive_class => 'ocf',
    provided_by     => 'heartbeat',
    primitive_type  => 'IPaddr2',
    # multistate_hash => {
    #   'type' => 'clone',
    # },
    # ms_metadata => {
    #   'interleave' => 'true',
    # },
    parameters => {
      'nic'     => $vip[nic],
      'ip'      => $vip[ip],
      'iflabel' => $vip[iflabel] ? { undef => 'ka', default => $vip[iflabel] },
      #'lvs_support' => $vip[lvs_support] ? { undef => 'false', default => $vip[lvs_support] },
      #'unique_clone_address' => $vip[unique_clone_address] ? { undef => 'true', default => $vip[unique_clone_address] },
    },
    operations => {
      'monitor' => {
        'interval' => '2',
        'timeout'  => '30'
      },
      'start' => {
        'timeout' => '30'
      },
      'stop' => {
        'timeout' => '30'
      },
    },
  }
}

Class['corosync'] -> Cluster::Virtual_ip <||>
if defined(Corosync::Service['pacemaker']) {
  Corosync::Service['pacemaker'] -> Cluster::Virtual_ip <||>
}
#
###