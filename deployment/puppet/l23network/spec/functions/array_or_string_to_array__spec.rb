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

describe 'array_or_string_to_array' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it 'should exist' do
    Puppet::Parser::Functions.function('array_or_string_to_array').should == 'function_array_or_string_to_array'
  end

  it 'should throw an error on invalid types' do
    lambda {
      scope.function_array_or_string_to_array([{:foo => :bar}])
    }.should(raise_error(Puppet::ParseError))
  end

  it 'should throw an error on invalid arguments number' do
    lambda {
      scope.function_array_or_string_to_array([])
    }.should(raise_error(Puppet::ParseError))
    lambda {
      scope.function_array_or_string_to_array([[1,2],[3,4]])
    }.should(raise_error(Puppet::ParseError))
  end

  it 'should return array if given array' do
    scope.function_array_or_string_to_array([[1,2,3,4,5,6,7,8,9]]).should == [1,2,3,4,5,6,7,8,9]
  end

  it 'should return array of strings if given string with separators' do
    scope.function_array_or_string_to_array(['1,2,3,4,5:6,7 8,9']).should == ['1','2','3','4','5','6','7','8','9']
  end
end