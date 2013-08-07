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


require 'facter'

#begin
#  Timeout::timeout(60) do
#    until File.exists?("/etc/naily.facts")
#      File.open("/tmp/facter.log", "a") {|f| f.write("#{Time.now} Waiting for facts\n")}
#      sleep(1)
#    end
#  end
#rescue Timeout::Error
#  File.open("/tmp/facter.log", "a") {|f| f.write("#{Time.now} Tired of waiting\n")}
#end

if File.exist?("/etc/naily.facts")
    File.open("/var/log/facter.log", "a") {|f| f.write("#{Time.now} facts exist\n")}
    File.readlines("/etc/naily.facts").each do |line|
        if line =~ /^(.+)=(.+)$/
            var = $1.strip; 
            val = $2.strip

            Facter.add(var) do
                setcode { val }
            end
            File.open("/var/log/facter.log", "a") {|f| f.write("#{Time.now} fact '#{var}' = '#{val}'\n")}
        end
    end
else
    File.open("/var/log/facter.log", "a") {|f| f.write("#{Time.now} facts NOT exist\n")}
end
