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



def check_kern_module(mod)
  mods = File.readlines("/proc/modules")
  if  mods.select {|x| x =~ mod}.length > 0
    return true
  else
    return false
  end
end

Facter.add('kern_module_ovs_loaded') do
  case Facter.value('osfamily')
    when /(?i)(debian)/
      mod = /^openvswitch_mod\s+/
    when /(?i)(redhat)/
      mod = /^openvswitch\s+/
  end
  setcode do
    check_kern_module(mod)
  end
end

Facter.add('kern_module_bridge_loaded') do
  setcode do
    check_kern_module(/^bridge\s+/)
  end
end
