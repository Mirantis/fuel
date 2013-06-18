require 'puppet'
require 'puppet/util/execution'

module Puppet::Parser::Functions
    newfunction(:ceph_get_osd_id, :type => :rvalue) do |args|
        uuid = args[0]
        if Puppet::Util::Execution.respond_to?('execute')
            id = Puppet::Util::Execution.execute("/usr/bin/ceph osd create #{uuid}")
        else
            id = Puppet::Util.execute("/usr/bin/ceph osd create #{uuid}")
        end
        id
    end
end


