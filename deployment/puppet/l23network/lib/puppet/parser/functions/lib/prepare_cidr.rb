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


def prepare_cidr(cidr)
  if ! cidr.is_a?(String)
    raise(Puppet::ParseError, "Can't recognize IP address in non-string data.")
  end

  re_groups = /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\/(\d{1,2})$/.match(cidr)
  if ! re_groups or re_groups[2].to_i > 32
    raise(Puppet::ParseError, "cidr_to_ipaddr(): Wrong CIDR: '#{cidr}'.")
  end 
  
  for octet in re_groups[1].split('.')
    raise(Puppet::ParseError, "cidr_to_ipaddr(): Wrong CIDR: '#{cidr}'.") if octet.to_i > 255
  end
  
  return re_groups[1], re_groups[2].to_i
end
