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


#
# array_or_string_to_array.rb
#

module Puppet::Parser::Functions
  newfunction(:array_or_string_to_array, :type => :rvalue, :doc => <<-EOS
This function get array or string with separator (comma, colon or space).
and return array without empty or false elements.

*Examples:*

    array_or_string_to_array(['a','b','c','d'])
    array_or_string_to_array('a,b:c d')

Would result in: ['a','b','c','d']
    EOS
  ) do |arguments|
    raise(Puppet::ParseError, "array_or_string_to_array(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size != 1

    in_data = arguments[0]

    if in_data.is_a?(String)
      rv = in_data.split(/[\:\,\s]+/).delete_if{|a| a=='' or !a}
    elsif in_data.is_a?(Array)
      rv = in_data.delete_if{|a| a==''}
    else
      raise(Puppet::ParseError, 'array_or_string_to_array(): Requires array or string to work with')
    end

    return rv
  end
end

# vim: set ts=2 sw=2 et :
