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


# Fact: galera_gcomm_empty
#
# Purpose: Return 'true' if gcomm:// cluster address is empty for Galera MySQL master-master replication engine 
#
# Resolution:
#   Greps mysql config files for wsrep_cluster_address option 
#
# Caveats:
#

## Cfkey.rb
## Facts related to cfengine
##

result = "true"
#FIXME: do not hardcode wsrep config file location. We need to start from 
#FIXME:  mysql config file and go through all the include directives

if File.exists?("/etc/mysql/conf.d/wsrep.cnf")   
    if open("/etc/mysql/conf.d/wsrep.cnf").read.split("\n").grep(/^\s*wsrep_cluster_address=[\"\']gcomm:\/\/\s*[\"\']\s*/).any?
        result="true"
    else
        result="false"
    end
end

Facter.add("galera_gcomm_empty") do
 setcode do
   result
   end
end
