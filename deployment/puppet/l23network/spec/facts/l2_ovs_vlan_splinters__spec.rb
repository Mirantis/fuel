require 'spec_helper'

describe 'Facter::Util::Fact' do
  before { Facter.clear }
  after  { Facter.clear }

  describe '2.6 kernel family' do

    it 'noexample.com' do
      Facter.fact(:kernelmajversion).stubs(:value).returns('3.3')
      subj = Facter.fact(:l2_ovs_vlan_splinters_need_for)
      subj.value.should == nil # "eth0,eth1"
    end

    # it 'some.example.com' do
    #   Facter.fact(:fqdn).stubs(:value).returns('some.example.com')
    #   Facter.fact(:is_example).value.should == true
    # end
  end
end

