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

describe 'merge_arrays' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it 'should exist' do
    Puppet::Parser::Functions.function('merge_arrays').should == 'function_merge_arrays'
  end

  it 'should throw an error on invalid types' do
    lambda {
      scope.function_merge_arrays([{:foo => :bar}])
    }.should(raise_error(Puppet::ParseError))
  end

  it 'should throw an error on invalid arguments number' do
    lambda {
      scope.function_merge_arrays([])
    }.should(raise_error(Puppet::ParseError))
  end

  it 'should return array' do
    scope.function_merge_arrays([[1,2,3],[4,5,6],[7,8,9]]).should == [1,2,3,4,5,6,7,8,9]
  end
end