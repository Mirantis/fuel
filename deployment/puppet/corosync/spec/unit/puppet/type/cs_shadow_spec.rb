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

describe Puppet::Type.type(:cs_shadow) do
  subject do
    Puppet::Type.type(:cs_shadow)
  end

  it "should have a 'name' parameter" do
    subject.new(:name => "mock_resource")[:name].should == "mock_resource"
  end

  describe "basic structure" do
    it "should be able to create an instance" do
      provider_class = Puppet::Type::Cs_shadow.provider(Puppet::Type::Cs_shadow.providers[0])
      Puppet::Type::Cs_shadow.expects(:defaultprovider).returns(provider_class)

      subject.new(:name => "mock_resource").should_not be_nil
    end

    [:name,:isempty].each do |param|
      it "should have a #{param} parameter" do
        subject.validparameter?(param).should be_true
      end

      it "should have documentation for its #{param} parameter" do
        subject.paramclass(param).doc.should be_instance_of(String)
      end
    end
    [:cib].each do |property|
      it "should have a #{property} property" do
        subject.validproperty?(property).should be_true
      end

      it "should have documentation for its #{property} property" do
        subject.propertybyname(property).doc.should be_instance_of(String)
      end
    end

  end

  describe "when autorequiring resources" do

    before do
      @catalog = Puppet::Resource::Catalog.new
      @resource = described_class.new(:name => 'dummy', :cib=>"baz")
      @catalog.add_resource @resource
    end

    it "should generate the cs_commit resource with correct name" do
      generated = @resource.generate
      generated[0].name == [@resource[:name]]
      generated[0].class.should == Puppet::Type::Cs_commit

    end

  end

end
