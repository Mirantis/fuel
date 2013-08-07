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

describe 'cidr_to_netmask' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it 'should exist' do
    Puppet::Parser::Functions.function('cidr_to_netmask').should == 'function_cidr_to_netmask'
  end

  it 'should throw an error on invalid types' do
    lambda {
      scope.function_cidr_to_netmask([{:foo => :bar}])
    }.should(raise_error(Puppet::ParseError))
  end

  it 'should throw an error on invalid CIDR' do
    invalid_cidrs = ['192.168.33.66', '192.256.33.66/23', 'jhgjhgghggh']
    for cidr in invalid_cidrs
	    lambda {
	      scope.function_cidr_to_netmask([cidr])
	    }.should(raise_error(Puppet::ParseError))
    end
  end

  it 'should throw an error on invalid CIDR masklen' do
    cidr = '192.168.33.66/33'
    lambda {
      scope.function_cidr_to_netmask([cidr])
    }.should(raise_error(Puppet::ParseError))
  end

  it 'should return netmask from CIDR' do
    cidr = '192.168.33.66/25'
    netmask = '255.255.255.128'
    scope.function_cidr_to_netmask([cidr]).should == netmask
  end
end