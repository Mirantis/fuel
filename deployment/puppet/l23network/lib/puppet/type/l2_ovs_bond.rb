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


Puppet::Type.newtype(:l2_ovs_bond) do
    @doc = "Manage a Open vSwitch port"
    desc @doc

    ensurable

    newparam(:bond) do
      isnamevar
      desc "The bond name"
      #
      validate do |val|
        if not val =~ /^[a-z][0-9a-z\.\-\_]*[0-9a-z]$/
          fail("Invalid bond name: '#{val}'")
        end
      end
    end

    newparam(:ports) do
      desc "List of ports that will be added to the bond"
      #
      validate do |val|
        if not val.is_a?(Array)
          fail("Ports parameter must be an array (not #{val.class}).")
        end
        for port in val
          if not port =~ /^[a-z][0-9a-z\.\-\_]*[0-9a-z]$/
            fail("Invalid port name: '#{port}'")
          end
        end
      end
    end

    newparam(:skip_existing) do
      defaultto(false)
      desc "Allow to skip existing bond"
    end

    newparam(:properties) do
      defaultto([])
      desc "Array of bond properties"
    end

    newparam(:bridge) do
      desc "What bridge to use"
      #
      validate do |val|
        if not val =~ /^[a-z][0-9a-z\.\-\_]*[0-9a-z]$/
          fail("Invalid bridge name: '#{val}'")
        end
      end
    end

    autorequire(:l2_ovs_bridge) do
      [self[:bridge]]
    end
end
