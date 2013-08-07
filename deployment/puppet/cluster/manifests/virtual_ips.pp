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


# == Define: cluster::virtual_ips
#
# Configure set of VirtualIP resources for corosync/pacemaker.
#
# === Parameters
#
# [*vips*]
#   Specify dictionary of VIPs describing. Ex:
#   {
#     virtual_ip1_name => {
#       nic    => 'eth0',	
#       ip     => '10.1.1.253'
#     },
#     virtual_ip2_name => {
#       nic    => 'eth2',
#       ip     => '192.168.12.254',
#     },
#   }
#
# [*name*]
#   keys($vips) list, need for emulating loop in puppet.
#
define cluster::virtual_ips (
  $vips
){
  cluster::virtual_ip {"$name":
    vip => $vips[$name],
  }
}
#
###