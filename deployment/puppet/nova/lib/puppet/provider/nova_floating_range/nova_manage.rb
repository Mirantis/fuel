$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'..','..','..','..','..'))
require 'ruby-openstack/lib/openstack'
require 'netaddr'
Puppet::Type.type(:nova_floating_range).provide :nova_manage do
  desc 'Create nova floating range'

  commands :nova_manage => 'nova-manage'

  def exists?
    if @resource[:ensure] == :absent
      operate_range.any?
    else
      operate_range.empty?
    end
  end

  def create
    operate_range.each_slice(100) do |range|
      range.each do |ip|
        begin
          connect.create_floating_ips_bulk :ip_range => ip, :pool => @resource[:pool]
        rescue => e
          sleep 5
          retry
        end
      end
      sleep 20
    end
  end

  def destroy
    operate_range.each do |ip|
      nova_manage("floating", "delete", ip )
    end
  end

  def operate_range
    exist_range = []
    connect.get_floating_ips_bulk.each do |element|
      exist_range << element.address
    end
    if @resource[:ensure] == :absent
      ip_range & exist_range
    else
      ip_range - exist_range
    end
  end

  def ip_range
    ip = @resource[:name].split('-')
    ip_range = NetAddr.range NetAddr::CIDR.create(ip.first), NetAddr::CIDR.create(ip.last)
    ip_range.unshift(ip.first).push(ip.last)
  end

  def connect
    @connect ||= OpenStack::Connection.create :username => @resource[:username],
                                 :api_key => @resource[:api_key],
                                 :auth_method => @resource[:auth_method],
                                 :auth_url => @resource[:auth_url],
                                 :authtenant_name => @resource[:authtenant_name],
                                 :service_type => @resource[:service_type]
  end
end
