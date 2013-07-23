#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'lib'))
require 'openstack'

os = OpenStack::Connection.create({:username => 'admin', :api_key => 'nova', :auth_method => 'password', :auth_url => 'http://192.168.122.114:5000/v2.0/',
                                   :authtenant_name => 'admin', :service_type => 'compute'} )

#puts os.get_floating_ips.inspect
#puts os.get_floating_ip_polls.inspect
puts os.get_floating_ips_bulk.inspect

#os.create_floating_ips_bulk( { :interface => 'eth0', :ip_range => '192.168.1.10', :pool => 'nova'})
#os.delete_floating_ips_bulk({:ip_range => '192.168.1.0/32'})
os.create_floating_ips_bulk( { :ip_range => '192.168.1.3'})

