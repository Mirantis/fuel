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

describe Puppet::Type.type(:cs_order) do
  subject do
    Puppet::Type.type(:cs_order)
  end

  it "should have a 'name' parameter" do
    subject.new(:name => "mock_resource")[:name].should == "mock_resource"
  end

  describe "basic structure" do
    it "should be able to create an instance" do
      provider_class = Puppet::Type::Cs_order.provider(Puppet::Type::Cs_order.providers[0])
      Puppet::Type::Cs_order.expects(:defaultprovider).returns(provider_class)
      subject.new(:name => "mock_resource").should_not be_nil
    end

    [:cib, :name ].each do |param|
      it "should have a #{param} parameter" do
        subject.validparameter?(param).should be_true
      end

      it "should have documentation for its #{param} parameter" do
        subject.paramclass(param).doc.should be_instance_of(String)
      end
    end

    [:first,:second,:score].each do |property|
      it "should have a #{property} property" do
        subject.validproperty?(property).should be_true
      end
      it "should have documentation for its #{property} property" do
        subject.propertybyname(property).doc.should be_instance_of(String)
      end

    end

    it "should validate the score values" do
      ['fadsfasdf', '10a', nil].each do |value|
        expect { subject.new(
          :name       => "mock_colocation",
          :primitives => ['foo','bar'],
          :score => value
          ) }.to raise_error(Puppet::Error)
      end

    end
  end

  describe "when autorequiring resources" do

    before :each do
      @csresource_foo = Puppet::Type.type(:cs_resource).new(:name => 'foo', :ensure => :present)
      @csresource_bar = Puppet::Type.type(:cs_resource).new(:name => 'bar', :ensure => :present)
      @shadow = Puppet::Type.type(:cs_shadow).new(:name => 'baz',:cib=>"baz")
      @catalog = Puppet::Resource::Catalog.new
      @catalog.add_resource @shadow, @csresource_bar, @csresource_foo
    end

    it "should autorequire the corresponding resources" do

      @resource = described_class.new(:name => 'dummy', :first => 'foo',:second=>'bar', :cib=>"baz", :score=>"inf")

      @catalog.add_resource @resource
      req = @resource.autorequire
      req.size.should == 3
      req.each do |e|
        #rewrite this f*cking should method of property type by the ancestor method
        class << e.target
          def should(*args)
            Object.instance_method(:should).bind(self).call(*args)
          end
        end
        e.target.should eql(@resource)
        [@csresource_bar,@csresource_foo,@shadow].should include(e.source)
      end
    end

  end
end
