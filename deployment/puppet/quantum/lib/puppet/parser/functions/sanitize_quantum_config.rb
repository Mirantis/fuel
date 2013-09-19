require 'ipaddr'


class Mrnt_Quantum

  def self.sanitize_hash(cfg)
    def self.__process_array(aa)
      rv = []
      aa.each do |v|
        if v.is_a? Hash
          rv.insert(-1, __process_hash(v))
        elsif v.is_a? Array
          rv.insert(-1, __process_array(v))
        else
          rv.insert(-1, v)
        end
      end
      return rv
    end
    def self.__process_hash(hh)
      rv = {}
      hh.each do |k, v|
        #info("xx>>#{k}--#{k.to_sym}<<")
        if v.is_a? Hash
          rv[k.to_sym] = __process_hash(v)
        elsif v.is_a? Array
          rv[k.to_sym] = __process_array(v)
        else
          rv[k.to_sym] = v
        end
      end
      return rv
    end
    __process_hash(cfg)
  end

  def default_amqp_provider()
    "rabbitmq"
  end

  def default_netmask()
    "/24"
  end

  def get_management_vip()
    @scope.lookupvar('management_vip')
  end

  def get_database_vip()
    @scope.lookupvar('management_vip')
  end

  def get_default_routers()
    {
      :router04 => {
        :tenant => 'admin',
        :external_network => "net04_ext",
        :internal_networks => ["net04"],
      }
    }
  end

  def get_default_networks()
    net_ext = "10.100.100"
    net_int = "192.168.111"
    {
      :net04_ext => {
        :subnet => "#{net_ext}.0/24",
        :gateway => "#{net_ext}.1",
        :nameservers => ["8.8.4.4", "8.8.8.8"],
        :public => true,
        :floating => "#{net_ext}.130:#{net_ext}.254",
      },
      :net04 => {
        :subnet => "#{net_int}.0/24",
        :gateway => "#{net_int}.1",
        :nameservers => [], # only for public
        :public => false,   # default
        :floating => nil,
      },
    }
  end


  def generate_default_quantum_config()
    # fields defined as NIL are required
    rv = {
      :amqp => {
        :provider => default_amqp_provider(),
        :username => "nova",
        :passwd => "nova",
        #:hosts => "hostname1:5672, hostname2:5672" # rabbit_nodes.map {|x| x + ':5672'}.join ',' # calculate from $controller_nodes
        :hosts => "#{self.get_management_vip()}:5672",
        :control_exchange => "quantum",
        :heartbeat => 60,
        :protocol => "tcp",
        :rabbit_virtual_host => "/",
        :rabbit_ha_queues => true,
      },
      :database => {
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
        :auth_host => get_management_vip(),
        :auth_port => 35357,
        :auth_protocol => "http",
        :admin_tenant_name => "services",
        :admin_user => "quantum",
        :admin_password => "quantum_pass",
        :signing_dir => "/var/lib/quantum/keystone-signing",
      },
      :server => {
        :bind_host => get_management_vip(),
        :bind_port => 9696,
      },
      :metadata => {
        :nova_metadata_ip => get_management_vip(),
        :nova_metadata_port => 8775,
        :metadata_proxy_shared_secret => "secret-word",
      },
      :L2 => {
        :base_mac => "fa:16:3e:00:00:00",
        :segmentation_type => "gre",
        :tunnel_id_ranges => "3000:65535",
        :bridge_mappings => ["physnet1:br-ex", "physnet2:br-prv"],
        :network_vlan_ranges => ["physnet1", "physnet2:3000:4094"],
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
        #:public_network => "net04_ext",
        :send_arp_for_ha => 8,
        :resync_interval => 40,
        :resync_fuzzy_delay => 5,
        :dhcp_agent => {
          :enable_isolated_metadata => false,
          :enable_metadata_network => false,
          :lease_duration => 120,
        },
      },
      :predefined_routers => get_default_routers(),
      :predefined_networks => get_default_networks(),
      :root_helper => "sudo quantum-rootwrap /etc/quantum/rootwrap.conf",
    }
    rv[:database][:port] = case rv[:database][:provider].upcase().to_sym()
      when :MYSQL then 3306
      when :PGSQL then 5432
      else
        raise(Puppet::ParseError, "Unknown database provider '#{rv[:database][:provider]}'")
    end
    if ['gre', 'vxlan', 'lisp'].include?(rv[:L2][:segmentation_type])
      rv[:L2][:enable_tunneling] = true
    else
      rv[:L2][:enable_tunneling] = false
      rv[:L2][:tunnel_id_ranges] = nil
    end
    return rv
  end

  def initialize(scope, cfg)
    @scope = scope
    @given_config = cfg
  end

  def generate_config()
    def generate_config__process_hash(cfg_dflt, cfg_user, path)
      rv = {}
      cfg_dflt.each() do |k, v|
        # if v == nil && cfg_user[k] == nil
        #   raise(Puppet::ParseError, "Missing required field '#{path}.#{k}'.")
        # end
        if v != nil && cfg_user[k] != nil && v.class() != cfg_user[k].class()
          raise(Puppet::ParseError, "Invalid format of config hash.")
        end
        #print ">>>>>>>>>>>>>>>>>>>>>#{v.class} -#{k}-\n"
        rv[k] = case v.class.to_s
          when "Hash"     then cfg_user[k] ? generate_config__process_hash(v,cfg_user[k], path.clone.insert(-1, k)) : v
          when "Array"    then cfg_user[k].empty?() ? v : cfg_user[k]
          when "String"   then cfg_user[k] ? cfg_user[k] : v
          when "NilClass" then cfg_user[k] ? cfg_user[k] : v
          else v
        end
      end
      return rv
    end
    rv = generate_config__process_hash(generate_default_quantum_config(), @given_config, [])
  end
end

Puppet::Parser::Functions::newfunction(:sanitize_quantum_config, :type => :rvalue, :doc => <<-EOS
    This function get Hash of Quantum configuration
    and sanitize it.

    Example call this:
    $config = sanitize_quantum_config(parse_json($quantum_json_config))

    EOS
  ) do |argv|

  given_config = Mrnt_Quantum.sanitize_hash(argv[0])
  q_conf = Mrnt_Quantum.new(self, given_config)
  return q_conf.generate_config()
end


# vim: set ts=2 sw=2 et :