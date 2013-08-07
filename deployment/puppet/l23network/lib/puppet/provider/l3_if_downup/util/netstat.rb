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


module Facter::Util::NetStat
  def self.column_map
    {
      :bsd     => {
        :aliases => [:sunos, :freebsd, :netbsd, :darwin],
        :dest    => 0,
        :gw      => 1,
        :iface   => 5
      },
      :linux   => {
        :dest   => 0,
        :gw     => 1,
        :iface  => 7
      },
      :openbsd => {
        :dest   => 0,
        :gw     => 1,
        :iface  => 6
      }
    }
  end 

  def self.supported_platforms
    column_map.inject([]) do |result, tmp|
      key, map = tmp
      if map[:aliases]
        result += map[:aliases]
      else
        result << key
      end
      result
    end
  end

  def self.get_ipv4_output
    output = ""
    case Facter.value(:kernel)
    when 'SunOS', 'FreeBSD', 'NetBSD', 'OpenBSD'
      output = %x{/usr/bin/netstat -rn -f inet}
    when 'Darwin' 
      output = %x{/usr/sbin/netstat -rn -f inet}
    when 'Linux'
      output = %x{/bin/netstat -rn -A inet}
    end
    output
  end

  def self.get_route_value(route, label)
    tmp1 = []

    kernel = Facter.value(:kernel).downcase.to_sym

    # If it's not directly in the map or aliased in the map, then we don't know how to deal with it.
    unless map = column_map[kernel] || column_map.values.find { |tmp| tmp[:aliases] and tmp[:aliases].include?(kernel) }
      return nil
    end

    c1 = map[:dest]
    c2 = map[label.to_sym]

    get_ipv4_output.to_a.collect { |s| s.split}.each { |a|
      if a[c1] == route
        tmp1 << a[c2]
      end
    }

    if tmp1
      return tmp1.shift
    end
  end
end
