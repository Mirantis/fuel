require 'puppet'
require 'puppet/util/execution'

module Puppet::Parser::Functions
  newfunction(:ceph_key_get, :type => :rvalue) do |args|
        user = args[0]
        msg = 'ceph_key_get():'
        begin
    	    notice("USER: #{user}")
	    user_id = Puppet::Util::Execution.execute("/usr/bin/ceph auth get-key client.#{user}")
	    rescue Puppet::ExecutionFailure => detail
	    msg += "\n#{detail}"
	    user_id = false
	end
	return user_id
     end
end


