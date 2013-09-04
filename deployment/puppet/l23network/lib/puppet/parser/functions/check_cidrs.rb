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
# check_cidrs.rb
#
begin
  require 'puppet/parser/functions/lib/prepare_cidr.rb'
rescue LoadError => e
  # puppet apply does not add module lib directories to the $LOAD_PATH (See
  # #4248). It should (in the future) but for the time being we need to be
  # defensive which is what this rescue block is doing.
  rb_file = File.join(File.dirname(__FILE__),'lib','prepare_cidr.rb')
  load rb_file if File.exists?(rb_file) or raise e
end

module Puppet::Parser::Functions
  newfunction(:check_cidrs, :doc => <<-EOS
This function get array of cidr-notated IP addresses and check it syntax.
Raise exception if syntax not right. 
EOS
  ) do |arguments|
    if arguments.size != 1
      raise(Puppet::ParseError, "check_cidrs(): Wrong number of arguments " +
        "given (#{arguments.size} for 1)") 
    end

    cidrs = arguments[0]

    if ! cidrs.is_a?(Array)
      raise(Puppet::ParseError, 'check_cidrs(): Requires array of IP addresses.')
    end
    if cidrs.length < 1
      raise(Puppet::ParseError, 'check_cidrs(): Must given one or more IP address.')
    end

    for cidr in cidrs do
      prepare_cidr(cidr)
    end

    return true
  end
end

# vim: set ts=2 sw=2 et :
