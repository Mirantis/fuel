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


# == Define: l23network::l3::defaultroute
#
# Do not use this directly,
# use l23network::l3::route instead
#
define l23network::l3::defaultroute (
    $gateway = $name,
    $metric  = undef,
){
  case $::osfamily {
    /(?i)debian/: {
        fail("Unsupported for ${::osfamily}/${::operatingsystem}!!! Specify gateway directly for network interface.")
    }
    /(?i)redhat/: {
        if ! defined(Cfg[$gateway]) {
          cfg { $gateway:
              file  => '/etc/sysconfig/network',
              key   => 'GATEWAY',
              value => $gateway,
          }
        }
    }
    default: {
        fail("Unsupported OS: ${::osfamily}/${::operatingsystem}")
    }
  }

}
#
###
