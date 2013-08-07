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

describe 'cidr_to_ipaddr' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it 'should exist' do
    Puppet::Parser::Functions.function('cidr_to_ipaddr').should == 'function_cidr_to_ipaddr'
  end

  it 'should throw an error on invalid types' do
    lambda {
      scope.function_cidr_to_ipaddr([{:foo => :bar}])
    }.should(raise_error(Puppet::ParseError))
  end

  it 'should throw an error on invalid CIDR' do
    invalid_cidrs = ['192.168.33.66', '192.256.33.66/23', 'jhgjhgghggh']
    for cidr in invalid_cidrs
	    lambda {
	      scope.function_cidr_to_ipaddr([cidr])
	    }.should(raise_error(Puppet::ParseError))
    end
  end

  it 'should throw an error on invalid CIDR masklen' do
    cidr = '192.168.33.66/33'
    lambda {
      scope.function_cidr_to_ipaddr([cidr])
    }.should(raise_error(Puppet::ParseError))
  end

  it 'should return IP address from CIDR' do
    cidr = '192.168.33.66/25'
    ipaddr = '192.168.33.66'
    scope.function_cidr_to_ipaddr([cidr]).should == ipaddr
  end
end