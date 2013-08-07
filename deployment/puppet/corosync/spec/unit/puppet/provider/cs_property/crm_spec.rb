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

describe Puppet::Type.type(:cs_property).provider(:crm) do

  let(:resource) { Puppet::Type.type(:cs_property).new(:name => 'myproperty', :provider=> :crm ) }
  let(:provider) { resource.provider }

  describe "#create" do
    before(:each) do
      provider.class.stubs(:exec_withenv).returns(0)
    end

    xit "should create property with corresponding value" do
      resource[:value]= "myvalue"
      provider.expects(:crm).with('configure', 'property', '$id="cib-bootstrap-options"', "myproperty=myvalue")
      provider.create
      provider.flush
    end
  end

  describe "#destroy" do
    it "should destroy property with corresponding name" do
      provider.expects(:cibadmin).with('--scope', 'crm_config', '--delete', '--xpath', "//nvpair[@name='myproperty']")
      provider.destroy
      provider.flush
    end
  end

  describe "#instances" do
    it "should find instances" do
      provider.class.stubs(:block_until_ready).returns(true)
      out=File.open(File.dirname(__FILE__) + '/../../../../fixtures/cib/cib.xml')
      provider.class.stubs(:dump_cib).returns(out,nil)
      instances = provider.class.instances
      instances[0].instance_eval{@property_hash}.should eql({:name=>"dc-version",:value=>"1.1.6-9971ebba4494012a93c03b40a2c58ec0eb60f50c", :ensure=>:present, :provider=>:crm})
    end
  end
end

