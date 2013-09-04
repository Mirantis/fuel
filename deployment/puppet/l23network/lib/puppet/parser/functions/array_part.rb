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
# array_part.rb
#

module Puppet::Parser::Functions
  newfunction(:array_part, :type => :rvalue, :doc => <<-EOS
This function get array, start and end positions 
and return sub-array between it. 

*Examples:*

    array_part(['a','b','c','d'], 1, 3)

Would result in: ['b','c','d']
    EOS
  ) do |arguments|
    if arguments.size != 3
      raise(Puppet::ParseError, "array_part(): Wrong number of arguments " +
        "given (#{arguments.size} for 3)") 
    end

    in_array = arguments[0]
    p_start  = arguments[1].to_i()
    p_end    = arguments[2].to_i()

    if ! in_array.is_a?(Array)
      raise(Puppet::ParseError, 'array_part(): Requires array as first argument.')
    end
    if (in_array.length == 0) or (p_start < 0) or (p_start > in_array.length-1)
      return nil
    end
    if (p_end == 0) or (p_end > in_array.length-1)
      p_end = in_array.length-1
    end
    if (p_end < p_start) 
      raise(Puppet::ParseError, 'array_part(): Ranges out of Array indexes.')
    end

    if p_start == p_end
      return Array(in_array[p_start])
    end

    return in_array[p_start..p_end]
  end
end

# vim: set ts=2 sw=2 et :
