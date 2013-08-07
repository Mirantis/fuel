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


module Puppet
  newtype(:cs_commit) do
    @doc = "This type is an implementation detail. DO NOT use it directly"
    newproperty(:cib) do
      def sync
        provider.sync(self.should)
      end

      def retrieve
        :absent
      end

      def insync?(is)
        false
      end

      defaultto { @resource[:name] }
    end

    newparam(:name) do
      isnamevar
    end

    autorequire(:cs_shadow) do
      [ @parameters[:cib].should ]
    end

    autorequire(:service) do
      [ 'corosync' ]
    end

    autorequire(:cs_resource) do
      resources_with_cib :cs_resource
    end

    autorequire(:cs_location) do
      resources_with_cib :cs_location
    end

    autorequire(:cs_colocation) do
      resources_with_cib :cs_colocation
    end

    autorequire(:cs_order) do
      resources_with_cib :cs_order
    end

    autorequire(:cs_property) do
      resources_with_cib :cs_order
    end

    autorequire(:cs_group) do
      resources_with_cib :cs_order
    end

    def resources_with_cib(cib)
      autos = []

      catalog.resources.find_all { |r| r.is_a?(Puppet::Type.type(cib)) and param = r.parameter(:cib) and param.value == @parameters[:cib].should }.each do |r|
        autos << r
      end

      autos
    end
  end
end
