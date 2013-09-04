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
  newtype(:cs_shadow) do
    @doc = "cs_shadow resources represent a Corosync shadow CIB. Any corosync
      resources defined with 'cib' set to the title of a cs_shadow resource
      will not become active until all other resources with the same cib
      value have also been applied."

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
      desc "Name of the shadow CIB to create and manage"
      isnamevar
    end

    newparam(:isempty) do
      desc "If newly created shadow CIB should be empty. Be really careful with this
      as it can destroy your cluster"
      newvalues(:true,:false)
      defaultto(:false)
    end

    def generate
      options = { :name => @title }
      Puppet.notice("generating cs_commit #{@title}")
      [ Puppet::Type.type(:cs_commit).new(options) ]
    end

    autorequire(:service) do
      [ 'corosync' ]
    end
  end
end
