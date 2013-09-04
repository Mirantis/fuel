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


# Fact: openvswitch ports
#
# Purpose: On any OS - return info about ovs ports for all bridges
#
# Resolution:
#
# Caveats:

def vsctl_cmd
  "/usr/bin/ovs-vsctl"
end

def ofctl_cmd
  "/usr/bin/ovs-ofctl"
end

module OpenVSwitch
    def self.exec(bin, cmd)
        result = Facter::Util::Resolution.exec(bin + " " + cmd)
        if result
            result = result.split("\n")
        end
        return result
    end

    # vSwitch
    def self.vsctl(cmd)
        return exec(vsctl_cmd, cmd)
    end

    def self.list_br
        return vsctl("list-br")
    end

    def self.list_ports(bridge)
        return vsctl("list-ports " + bridge)
    end

    # OpenFlow
    def self.ofctl(cmd)
        return exec(ofctl_cmd, cmd)
    end

    def self.of_show(bridge="")
        return ofctl("show " + bridge)
    end
end

if Facter.value(:kern_module_ovs_loaded) == true && File.exists?(vsctl_cmd)
    bridges = OpenVSwitch.list_br || []

    Facter.add("openvswitch_bridges") do
        setcode do
            bridges.join(",")
        end
    end

    bridges.each do |bridge|
        ports = OpenVSwitch.list_ports(bridge)
        if ports
            Facter.add("openvswitch_ports_#{bridge}") do
                setcode do
                    ports.join(",")
                end
            end
        end
    end
end
