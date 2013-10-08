# require 'ipaddr'
# require 'yaml'
# require 'json'

class MrntQuantumNR
  def initialize(scope, cfg)
    @scope = scope
    @quantum_config = cfg
  end

  #class method
  def self.sanitize_array(aa)
    aa.reduce([]) do |rv, v|
      rv << case v.class
          when Hash  then sanitize_hash(v)
          when Array  then sanitize_array(v)
          else v
      end
    end
  end

  #class method
  def self.sanitize_hash(hh)
    rv = {}
    hh.each do |k, v|
      rv[k.to_sym] = case v.class.to_s
        when "Hash"  then sanitize_hash(v)
        when "Array" then sanitize_array(v)
        else v
      end
    end
    return rv
  end

  def default_netmask()
    "/24"
  end

  def get_default_network_config()
    Marshal.load(Marshal.dump({
      :net => {
        :name         => nil,
        :tenant       => nil,
        :network_type => nil,
        :physnet      => nil,
        :router_ext   => nil,
        :shared       => nil,
        :segment_id   => nil,
      },
      :subnet => {
        :name    => nil,
        :tenant  => nil,
        :network => nil,  # Network id or name this subnet belongs to
        :cidr    => nil,  # CIDR of subnet to create
        :gateway => nil,
        :alloc_pool  => nil,  # Allocation pool IP addresses
        :nameservers => nil,  # DNS name servers used by hosts
      },
    }))
  end

  def create_resources()
    res__quantum_net = Puppet::Type.type(:quantum_net)
    res__quantum_subnet = Puppet::Type.type(:quantum_subnet)
    res__quantum_router = Puppet::Type.type(:quantum_router)
    previous = nil
    @quantum_config[:predefined_networks].each do |net, ncfg|
      # config network resources parameters
      network_config = self.get_default_network_config()
      network_config[:net][:name] = net.to_s
      network_config[:net][:tenant] = @quantum_config[:keystone][:admin_tenant_name]
      network_config[:net][:network_type] = ncfg[:L2][:network_type]
      network_config[:net][:physnet] = ncfg[:L2][:physnet]
      network_config[:net][:router_ext] = ncfg[:L2][:router_ext]
      network_config[:net][:shared] = ncfg[:shared]
      network_config[:net][:segment_id] = ncfg[:L2][:segment_id]
      network_config[:subnet][:name] = "#{net.to_s}__subnet"
      network_config[:subnet][:tenant] = @quantum_config[:keystone][:admin_tenant_name]
      network_config[:subnet][:network] = network_config[:net][:name]
      network_config[:subnet][:cidr] = ncfg[:L3][:subnet]
      network_config[:subnet][:gateway] = ncfg[:L3][:gateway]
      network_config[:subnet][:nameservers] = ncfg[:L3][:nameservers]
      if ncfg[:L3][:floating]
        floating_a = ncfg[:L3][:floating].split(/[\:\-]/)
        if floating_a.size != 2
          raise(Puppet::ParseError, "You must define floating range for network '#{net}' as pair of IP addresses, not a #{ncfg[:L3][:floating]}")
        end
        network_config[:subnet][:alloc_pool] = "start=#{floating_a[0]},end=#{floating_a[1]}"
      end
      # create quantum_net resource
      p_res = Puppet::Parser::Resource.new(
        res__quantum_net.to_s,
        network_config[:net][:name],
        :scope => @scope,
        :source => res__quantum_net
      )
      previous && p_res.set_parameter(:require, [previous])
      network_config[:net].each do |k,v|
        v && p_res.set_parameter(k,v)
      end
      @scope.compiler.add_resource(@scope, p_res)
      previous = p_res.to_s
      # create quantum_subnet resource
      p_res = Puppet::Parser::Resource.new(
        res__quantum_subnet.to_s,
        network_config[:subnet][:name],
        :scope => @scope,
        :source => res__quantum_subnet
      )
      p_res.set_parameter(:require, [previous])
      network_config[:subnet].each do |k,v|
        v && p_res.set_parameter(k,v)
      end
      @scope.compiler.add_resource(@scope, p_res)
      previous = p_res.to_s
    end
    # endpoints.each do |endpoint_name, endpoint_body|
    #   # create resource
    #   resource = res_factory[:ifconfig][:resource]
    #   p_resource = Puppet::Parser::Resource.new(
    #       res_factory[:ifconfig][:name_of_resource],
    #       endpoint_name,
    #       :scope => self,
    #       :source => resource
    #   )
    #   p_resource.set_parameter(:interface, endpoint_name)
    #   # set ipaddresses
    #   if endpoint_body[:IP].empty?
    #     p_resource.set_parameter(:ipaddr, 'none')
    #   elsif ['none','dhcp'].index(endpoint_body[:IP][0])
    #     p_resource.set_parameter(:ipaddr, endpoint_body[:IP][0])
    #   else
    #     ipaddrs = []
    #     endpoint_body[:IP].each do |i|
    #       if i =~ /\/\d+$/
    #         ipaddrs.insert(-1, i)
    #       else
    #         ipaddrs.insert(-1, "#{i}#{default_netmask()}")
    #       end
    #     end
    #     p_resource.set_parameter(:ipaddr, ipaddrs)
    #   end
    #   #set another (see L23network::l3::ifconfig DOC) parametres
    #   endpoint_body[:properties].each do |k,v|
    #     p_resource.set_parameter(k,v)
    #   end
    #   p_resource.set_parameter(:require, [previous]) if previous
    #   resource.instantiate_resource(self, p_resource)
    #   compiler.add_resource(self, p_resource)
    #   transformation_success.insert(-1, "endpoint(#{endpoint_name})")
    #   previous = p_resource.to_s
    # end
    # return transformation_success.join(" -> ")
  end
end

module Puppet::Parser::Functions
  newfunction(:create_predefined_networks_and_routers , :doc => <<-EOS
    This function get Hash of Quantum configuration
    and create predefined networks and routers.

    Example call:
    $config = create_predefined_networks_and_routers($quantum_settings_hash)

    EOS
  ) do |argv|
    #Puppet::Parser::Functions.autoloader.loadall
    nr_conf = MrntQuantumNR.new(self, MrntQuantumNR.sanitize_hash(argv[0]))
    nr_conf.create_resources()
  end
end
# vim: set ts=2 sw=2 et :