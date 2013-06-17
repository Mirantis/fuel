require 'puppet'
require 'puppet/util/execution'
require 'facter'

module Puppet::Parser::Functions
    newfunction(:ceph_get_osd_id, :type => :rvalue) do |args|
        uuid = args[0]
        osd_id = Facter::Util::Resolution.exec("/usr/bin/ceph osd create #{uuid}")
	osd_id
    end
end


