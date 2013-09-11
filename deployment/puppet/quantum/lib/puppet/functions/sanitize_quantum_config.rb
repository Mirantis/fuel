require 'ipaddr'
# require 'forwardable'
# require 'puppet/parser'
# require 'puppet/parser/templatewrapper'
# require 'puppet/resource/type_collection_helper'
# require 'puppet/util/methodhelper'

def default_amqp_provider()
  "rabbitmq"
end

def default_netmask()
  "/24"
end

def get_management_vip()
  lookupvar('management_vip') # may be a Puppet::Parser::Functions::lookupvar('management_vip')
end

def get_database_vip()
  lookupvar('management_vip')
end

def sanitize_hash(cfg)
  def process_array(aa)
    rv = []
    aa.each do |v|
      if v.is_a? Hash
        rv.insert(-1, process_hash(v))
      elsif v.is_a? Array
        rv.insert(-1, process_array(v))
      else
        rv.insert(-1, v)
      end
    end
    return rv
  end
  def process_hash(hh)
    rv = {}
    hh.each do |k, v|
      #info("xx>>#{k}--#{k.to_sym}<<")
      if v.is_a? Hash
        rv[k.to_sym] = process_hash(v)
      elsif v.is_a? Array
        rv[k.to_sym] = process_array(v)
      else
        rv[k.to_sym] = v
      end
    end
    return rv
  end
  process_hash(cfg)
end

def generate_default_quantum_config()
  rv = {
    :amqp => {
      :provider => default_amqp_provider(),
      :username => "nova",
      :passwd => "nova",
      #:hosts => "hostname1:5672, hostname2:5672" # rabbit_nodes.map {|x| x + ':5672'}.join ',' # calculate from $controller_nodes
      :hosts => "#{get_management_vip()}:5672",
      :control_exchange => "quantum",
      :heartbeat => 60,
      :protocol => "tcp",
      :rabbit_virtual_host => "/",
      :rabbit_ha_queues => true,
    },
    :database => {,
      :provider => "mysql",
      :host => get_database_vip(),
      :port => 0,
      :database => "quantum",
      :username => "quantum",
      :passwd   => "quantum",
      :reconnects => -1,
      :reconnect_interval => 2,
    },
    :keystone => {
      :auth_host => 10.20.1.200,
      :auth_port => 35357,
      :auth_protocol => "http",
      :admin_tenant_name => "services",
      :admin_user => "quantum",
      :admin_password => "quantum_pass",
      :signing_dir => "/var/lib/quantum/keystone-signing",
    },
#   :server => {
#     :bind_host => get_management_vip(),  # Address to bind the API server
#     :bind_port => 9696,        # Port the bind the API server to
#   },
    :metadata => {
      :nova_metadata_ip => "10.20.1.200",
      :nova_metadata_port => 8775,
      :metadata_proxy_shared_secret => "secret-word",
    },
    :L2 => {
      :base_mac => "fa:16:3e:00:00:00",
      :segmentation_type => "gre",
      :tunnel_id_ranges => "300:500",
      :bridge_mappings => ["physnet1:br-ex", "physnet2:br-prv"],
      :network_vlan_ranges => ["physnet1", "physnet2:1000:2999"],
      :integration_bridge => "br-int",
      :tunnel_bridge => "br-tun",
      :int_peer_patch_port => "patch-tun",
      :tun_peer_patch_port => "patch-int",
      :local_ip => nil,
    },
    :L3 => {
      :router_id => nil,
      :gateway_external_network_id => nil,
      :use_namespaces => true,
      :allow_overlapping_ips => false,
      :public_bridge => "br-ex",
      :public_network => "net04_ext",
      :send_arp_for_ha => 8
      :resync_interval => 40
      :resync_fuzzy_delay => 5
      :dhcp_agent => {
        :enable_isolated_metadata => false,
        :enable_metadata_network => false,
        :lease_duration => 120,
      },
    # predefined_routers =>
    #   router04 =>
    #     external_network => net04_ext
    #     internal_networks => #       - net04
    :predefined_networks => {},
    :root_helper => "sudo quantum-rootwrap /etc/quantum/rootwrap.conf",

  }
  case rv[:database][:provider].upcase().to_sym()
    when :MYSQL then rv[:database][:port] = 3306
    when :PGSQL then rv[:database][:port] = 5432
    else
      raise(Puppet::ParseError, "Unknown database provider '#{rv[:database][:provider]}'")
  end
  if ['gre', 'vxlan', 'lisp'].index(rv[:L2][:segmentation_type])
    rv[:L2][:enable_tunneling] = true
  else
    rv[:L2][:enable_tunneling] = false
    rv[:L2][:tunnel_id_ranges] = nil
  end
  return rv
end

# def sanitize_quantum_config(cfg)
#   action = trans[:action].downcase()
#   # Setup defaults
#   rv = case action
#     when "add-br" then {
#       :name => nil,
#       #:stp_enable => true,
#       :skip_existing => true
#     }
#     when "add-port" then {
#       :name => nil,
#       :bridge => nil,
#       :type => "internal",
#       :tag => 0,
#       :trunks => [],
#       :port_properties => [],
#       :interface_properties => [],
#       :skip_existing => true
#     }
#     when "add-bond" then {
#       :name => nil,
#       :bridge => nil,
#       :interfaces => [],
#       :tag => 0,
#       :trunks => [],
#       :properties => [],
#       #:port_properties => [],
#       #:interface_properties => [],
#       :skip_existing => true
#     }
#     when "add-patch" then {
#       :name => "unnamed", # calculated later
#       :peers => [nil, nil],
#       :bridges => [],
#       :tags => [0, 0],
#       :trunks => [],
#     }
#     else
#       raise(Puppet::ParseError, "Unknown transformation: '#{action}'.")
#   end
#   # replace defaults to real parameters
#   rv[:action] = action
#   rv.each do |k,v|
#     if trans[k]
#       rv[k] = trans[k]
#     end
#   end
#   # Check for incorrect parameters
#   if not rv[:name].is_a? String
#     raise(Puppet::ParseError, "Unnamed transformation: '#{action}'.")
#   end
#   name = rv[:name]
#   if not rv[:bridge].is_a? String and not ["add-patch", "add-br"].index(action)
#     raise(Puppet::ParseError, "Undefined bridge for transformation '#{action}' with name '#{name}'.")
#   end
#   if action == "add-patch"
#     if not rv[:bridges].is_a? Array  and  rv[:bridges].size() != 2
#       raise(Puppet::ParseError, "Transformation patch have wrong 'bridges' parameter.")
#     end
#     name = "patch__#{rv[:bridges][0]}__#{rv[:bridges][1]}"
#     if not rv[:peers].is_a? Array  and  rv[:peers].size() != 2
#       raise(Puppet::ParseError, "Transformation patch '#{name}' have wrong 'peers' parameter.")
#     end
#     rv[:name] = name
#   end
#   if action == "add-bond"
#     if not rv[:interfaces].is_a? Array or rv[:interfaces].size() != 2
#       raise(Puppet::ParseError, "Transformation bond '#{name}' have wrong 'interfaces' parameter.")
#     end
#     # rv[:interfaces].each do |i|
#     #   if
#     # end
#   end
#   return rv
# end

Puppet::Parser::Functions::newfunction(:sanitize_quantum_config, :type => :rvalue, :doc => <<-EOS
    This function get Hash of Quantum configuration
    and sanitize it.

    Example call this:
    $config = sanitize_quantum_config(parse_json($quantum_json_config))

    EOS
  ) do |argv|

  given_config = sanitize_hash(argv[0])
  return sanitize_quantum_config(given_config)
end

# vim: set ts=2 sw=2 et :