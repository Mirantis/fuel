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


class osnailyfacter::rpmcache {

  $rh_base_channels = "rhel-6-server-rpms rhel-6-server-optional-rpms rhel-lb-for-rhel-6-server-rpms rhel-rs-for-rhel-6-server-rpms rhel-ha-for-rhel-6-server-rpms rhel-server-ost-6-folsom-rpms"
  $rh_openstack_channel = "rhel-server-ost-6-3-rpms"

  $sat_base_channels = "rhel-x86_64-server-6 rhel-x86_64-server-optional-6 rhel-x86_64-server-lb-6 rhel-x86_64-server-rs-6 rhel-x86_64-server-ha-6"
  $sat_openstack_channel = "rhel-x86_64-server-6-ost-3"

  class { 'rpmcache::rpmcache':
    releasever => "6Server",
    pkgdir => "/var/www/nailgun/rhel/6.4/nailgun/x86_64",
    rh_username => $rh_username,
    rh_password => $rh_password,
    rh_base_channels => $rh_base_channels,
    rh_openstack_channel => $rh_openstack_channel,
    use_satellite => $use_satellite,
    sat_hostname => $sat_hostname,
    activation_key => $activation_key,
    sat_base_channels => $sat_base_channels,
    sat_openstack_channel => $sat_openstack_channel
  }

}