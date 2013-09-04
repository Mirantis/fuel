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


# == Class: cluster
#
# Module for configuring cluster resources.
#
class cluster {
    if $use_unicast_corosync != 'false' {
      #todo: make as parameter
      $unicast_addresses = $controller_internal_addresses
    } else {
      $unicast_addresses = undef
    }

    #todo: move half of openstack::corosync to this module, another half -- to quantum
    if defined(Stage['corosync_setup']) {
      class {'openstack::corosync':
        bind_address      => $internal_address,
        unicast_addresses => $unicast_addresses,
        stage             => 'corosync_setup'
      }
    } else {
      class {'openstack::corosync':
        bind_address      => $internal_address,
        unicast_addresses => $unicast_addresses
      }
    }
    file {'ocf-mirantis-path':
      path=>'/usr/lib/ocf/resource.d/mirantis', 
      #mode => 755,
      ensure => directory,
      recurse => true,
      owner => root,
      group => root,
    } 
    Package['corosync'] -> File['ocf-mirantis-path']
}
#
###
