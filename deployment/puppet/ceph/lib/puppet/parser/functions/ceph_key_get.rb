require 'puppet'
require 'puppet/util/execution'

module Puppet::Parser::Functions
  newfunction(:ceph_key_get, :type => :rvalue) do |args|
        user = args[0]
        if Puppet::Util::Execution.respond_to?('execute')
            Puppet::Util::Execution.execute("/usr/bin/ceph auth get-key client.#{user}")
        else
            Puppet::Util.execute("/usr/bin/ceph auth get-key client.#{user}")
        end
     end
end


