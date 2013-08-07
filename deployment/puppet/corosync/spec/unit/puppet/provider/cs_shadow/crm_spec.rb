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


require 'spec_helper'

describe Puppet::Type.type(:cs_shadow).provider(:crm) do

  let(:resource) { Puppet::Type.type(:cs_shadow).new(:name => 'myshadow',  :provider=> :crm, :cib => 'myshadow' ) }
  let(:provider) { resource.provider }

  describe "#create" do
    it "should create  non-empty shadow" do
      provider.expects(:crm).with('cib','delete','myshadow')
      provider.expects(:crm).with('cib','new','myshadow')
      provider.sync('myshadow')
    end
    it "should create  empty shadow" do
      resource[:isempty] = :true
      provider.expects(:crm).with('cib','delete','myshadow')
      provider.expects(:crm).with('cib','new','myshadow','empty')
      provider.sync('myshadow')
    end
  end

end

