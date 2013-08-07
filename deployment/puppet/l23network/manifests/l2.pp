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


# == Class: l23network::l2
#
# Module for configuring L2 network.
# Requirements, packages and services.
#
class l23network::l2 (
  $use_ovs   = true,
  $use_lnxbr = true,
){
  include ::l23network::params

  if $use_ovs {
    #include ::l23network::l2::use_ovs    
    package {$::l23network::params::ovs_packages:
      ensure  => present,
      before  => Service['openvswitch-service'],
    } 
    service {'openvswitch-service':
      ensure    => running,
      name      => $::l23network::params::ovs_service_name,
      enable    => true,
      hasstatus => true,
      status    => $::l23network::params::ovs_status_cmd,
    }
  }

  if $::osfamily =~ /(?i)debian/ {
    if !defined(Package["$l23network::params::lnx_bond_tools"]) {
      package {"$l23network::params::lnx_bond_tools":
        ensure => installed
      }
    }
  }

  if !defined(Package["$l23network::params::lnx_vlan_tools"]) {
    package {"$l23network::params::lnx_vlan_tools":
      ensure => installed
    } 
  }

  if !defined(Package["$l23network::params::lnx_ethernet_tools"]) {
    package {"$l23network::params::lnx_ethernet_tools":
      ensure => installed
    }
  }

  if $use_ovs {
    if $::osfamily =~ /(?i)debian/ {
      Package["$l23network::params::lnx_bond_tools"] -> Service['openvswitch-service']
    }
    Package["$l23network::params::lnx_vlan_tools"] -> Service['openvswitch-service']
    Package["$l23network::params::lnx_ethernet_tools"] -> Service['openvswitch-service']
  }

}
