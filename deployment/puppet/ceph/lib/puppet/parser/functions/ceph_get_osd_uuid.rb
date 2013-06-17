require 'puppet'
require 'puppet/util/execution'
require 'facter'

module Puppet::Parser::Functions
    newfunction(:ceph_get_osd_uuid, :type => :rvalue) do |args|
        dev = arg[0]
        osd_uuid = Facter::Util::Resolution.exec("/sbin/blkid | grep #{dev} | awk -F '\"' '{print $2}'")
	osd_uuid
    end
end


