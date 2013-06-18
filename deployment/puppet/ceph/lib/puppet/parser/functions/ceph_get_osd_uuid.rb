require 'puppet'
require 'puppet/util/execution'

module Puppet::Parser::Functions
    newfunction(:ceph_get_osd_uuid, :type => :rvalue) do |args|
        dev = args[0]
        if Puppet::Util::Execution.respond_to?('execute')
            uuid = Puppet::Util::Execution.execute("/sbin/blkid | grep #{dev} | awk -F '\"' '{print $2}'")
        else
            uuid = Puppet::Util.execute("/sbin/blkid | grep #{dev} | awk -F '\"' '{print $2}'")
        end
        uuid
    end
end


