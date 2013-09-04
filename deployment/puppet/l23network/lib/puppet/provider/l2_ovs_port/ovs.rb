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


Puppet::Type.type(:l2_ovs_port).provide(:ovs) do
  optional_commands :vsctl => "/usr/bin/ovs-vsctl"

  def exists?
    vsctl("list-ports", @resource[:bridge]).include? @resource[:interface]
  end

  def create
    begin
      vsctl('port-to-br', @resource[:interface])
      if @resource[:skip_existing]
        return true
      else
        raise Puppet::ExecutionFailure, "Port '#{@resource[:interface]}' already exists."
      end
    rescue Puppet::ExecutionFailure
      # pass
    end
    # Port create begins from definition brodge and port
    cmd = [@resource[:bridge], @resource[:interface]]
    # add port properties (k/w) to command line
    if @resource[:port_properties]
      for option in @resource[:port_properties]
        cmd += [option]
      end
    end
    # set interface type
    #TODO: implement type=>patch sintax as type=>'patch:peer-name'
    if @resource[:type] and @resource[:type].to_s != ''
      tt = "type=" + @resource[:type].to_s
      cmd += ['--', "set", "Interface", @resource[:interface], tt]
    end
    # executing OVS add-port command
    cmd = ["add-port"] + cmd
    begin
      vsctl(cmd)
    rescue Puppet::ExecutionFailure => error
      raise Puppet::ExecutionFailure, "Can't add port '#{@resource[:interface]}'\n#{error}"
    end
    # set interface properties
    if @resource[:interface_properties]
      for option in @resource[:interface_properties]
        begin
          vsctl('--', "set", "Interface", @resource[:interface], option.to_s)
        rescue Puppet::ExecutionFailure => error
          raise Puppet::ExecutionFailure, "Interface '#{@resource[:interface]}' can't set option '#{option}':\n#{error}"
        end
      end
    end
  end

  def destroy
    vsctl("del-port", @resource[:bridge], @resource[:interface])
  end
end
