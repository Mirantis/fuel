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


class osnailyfacter::tinyproxy {
  # Allow connection to the tinyproxy for ostf tests
  firewall {'007 tinyproxy':
    dport   => [ 8888 ],
    source  => $master_ip,
    proto   => 'tcp',
    action  => 'accept',
    require => Class['openstack::firewall'],
  }
  package{'tinyproxy':} ->
  exec{'tinyproxy-init':
    command => "/bin/echo Allow $master_ip >> /etc/tinyproxy/tinyproxy.conf;
      /sbin/chkconfig tinyproxy on;
      /etc/init.d/tinyproxy restart; ",
    unless  => "/bin/grep -q '^Allow $master_ip' /etc/tinyproxy/tinyproxy.conf",
  }
}

