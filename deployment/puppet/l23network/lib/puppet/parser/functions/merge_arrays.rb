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
# merge_arrays.rb
#

module Puppet::Parser::Functions
  newfunction(:merge_arrays, :type => :rvalue, :doc => <<-EOS
This function get arrays, merge it and return.

*Examples:*

    merge_arrays(['a','b'], ['c','d'])
   

Would result in: ['a','b','c','d']
    EOS
  ) do |arguments|
    raise(Puppet::ParseError, "merge_arrays(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size < 1

    rv = []

    for arg in arguments
      if arg.is_a?(Array)
        rv += arg
      else
        raise(Puppet::ParseError, 'merge_arrays(): Requires only array as argument')
      end
    end

    return rv
  end
end

# vim: set ts=2 sw=2 et :
