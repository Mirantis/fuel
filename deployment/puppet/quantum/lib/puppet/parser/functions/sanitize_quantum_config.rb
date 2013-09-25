require 'ipaddr'


class MrntQuantum
  #class method
  def self.sanitize_array(aa)
    rv = []
    aa.each do |v|
      rv.insert(-1,  case v.class.to_s
          when "Hash"  then sanitize_hash(v)
          when "Array" then sanitize_array(v)
          else v
        end
      )
    end
    return rv
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

  def default_amqp_provider()
    "rabbitmq"
  end

  def default_netmask()
    "/24"
  end

  def get_management_vip()
    @scope.lookupvar('management_vip')
  end

  def get_amqp_vip(port)
    #todo myst give string like  "hostname1:5672, hostname2:5672" # rabbit_nodes.map {|x| x + ':5672'}.join ','
    #calculated from $controller_nodes
    vip = @scope.lookupvar('amqp_vip') || @scope.lookupvar('management_vip')
    port ? "#{vip}:#{port}"  :  vip
  end

  def get_database_vip()
    @scope.lookupvar('management_vip')
  end

  # classmethod
  def self.get_amqp_config(cfg)
    rv = cfg.clone()
    case cfg[:hosts].class.to_s()
      when "String"
        hosts = cfg[:hosts].split(',').map!{|x| x.split(':')}.map!{|x| [x[0], x[1] || cfg[:port].to_s]}
      when "Array"
        hosts = cfg[:hosts].map!{|x| x.split(':')}.map!{|x| [x[0], x[1] || cfg[:port].to_s]}
      else
        raise(Puppet::ParseError, "unsupported hosts field format in AMQP configure \"#{cfg['hosts']}\".")
    end
    case cfg[:provider]
      when 'rabbitmq', 'qpid'
        if cfg[:ha_mode]
          rv[:hosts] = hosts.map{|x| x.map!{|y| y.strip}.join(':')}.join(',')
        else
          rv[:hosts] = hosts[0][0].strip()
          if hosts[0][1].strip() != cfg[:port].to_s()
            rv[:port] = hosts[0][1].to_i()
          end
        end
      else
        raise(Puppet::ParseError, "unsupported AMQP provider \"#{cfg['provider']}\".")
    end
    return rv
  end

  # classmethod
  def self.get_quantum_srv_api_url(srvsh)
    "#{srvsh[:api_protocol]}://#{srvsh[:bind_host]}:#{srvsh[:bind_port]}"
  end

  # classmethod
  def self.get_keystone_auth_url(kshash)
    "#{kshash[:auth_protocol]}://#{kshash[:auth_host]}:#{kshash[:auth_port]}/#{kshash[:auth_api_version]}"
  end

  def get_quantum_srv_vip()
    @scope.lookupvar('quantum_vip') || @scope.lookupvar('management_vip')
  end

  def get_quantum_gre_vip()
    @scope.lookupvar('management_vip')
  end

  def get_bridge_name(bb)
    #todo: Import bridge names from network-roles
    case bb
      when 'management'  then 'br-mgmt'
      when 'public'  then 'br-ex'
      when 'private' then 'br-prv'
      when 'tunnel'  then 'br-tun'
      when 'integration' then 'br-int'
    end
  end

  def get_default_routers()
    {
      :router04 => {
        :tenant => 'admin',
        :virtual => false,  # Virtual router should not be create
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
        :shared => false,
        :L2 => {
          :router_ext   => true,
          :network_type => 'flat',
          :physnet      => 'physnet1',
          :segment_id   => nil,
        },
        :L3 => {
          :subnet => "#{net_ext}.0/24",
          :gateway => "#{net_ext}.1",
          :nameservers => [],
          :floating => "#{net_ext}.130:#{net_ext}.254",
        },
      },
      :net04 => {
        :shared => false,
        :L2 => {
          :router_ext   => false,
          :network_type => 'gre', # or vlan
          :physnet      => 'physnet2',
          :segment_id   => nil,
        },
        :L3 => {
          :subnet => "#{net_int}.0/24",
          :gateway => "#{net_int}.1",
          :nameservers => ["8.8.4.4", "8.8.8.8"],
          :floating => nil,
        },
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
        :hosts => get_amqp_vip(5672),
        :ha_mode => true,
        :control_exchange => "quantum",
        :heartbeat => 60,
        :protocol => "tcp",
        :rabbit_virtual_host => "/",
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
        :auth_region => 'RegionOne',
        :auth_url => nil, # will be calculated later
        :auth_host => get_management_vip(),
        :auth_port => 35357,
        :auth_protocol => "http",
        :auth_api_version => "v2.0",
        :admin_tenant_name => "services",
        :admin_user => "quantum",
        :admin_password => "quantum_pass",
        :admin_email => "quantum@localhost",
        :signing_dir => "/var/lib/quantum/keystone-signing",
      },
      :server => {
        :api_url => nil, # will be calculated later
        :api_protocol => "http",
        :bind_host => get_quantum_srv_vip(),
        :bind_port => 9696,
        :agent_down_time => 15,
        :allow_bulk      => true,
        :control_exchange=> 'quantum',
      },
      :metadata => {
        :nova_metadata_ip => get_management_vip(),
        :nova_metadata_port => 8775,
        :metadata_ip => '169.254.169.254',
        :metadata_port => 8775,
        :metadata_proxy_shared_secret => "secret-word",
      },
      :L2 => {
        :base_mac => "fa:16:3e:00:00:00",
        :mac_generation_retries => 32,
        :segmentation_type => "gre",
        :tunnel_id_ranges => "3000:65535",
        :bridge_mappings => ["physnet1:#{get_bridge_name('public')}", "physnet2:#{get_bridge_name('private')}"],
        :network_vlan_ranges => ["physnet1", "physnet2:3000:4094"],
        :integration_bridge => get_bridge_name('integration'),
        :tunnel_bridge => get_bridge_name('tunnel'),
        :int_peer_patch_port => "patch-tun",
        :tun_peer_patch_port => "patch-int",
        :local_ip => get_quantum_gre_vip(),
      },
      :L3 => {
        :router_id => nil,
        :gateway_external_network_id => nil,
        :use_namespaces => true,
        :allow_overlapping_ips => false,
        :network_auto_schedule => true,
        :router_auto_schedule  => true,
        :public_bridge => get_bridge_name('public'),
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
    rv[:keystone][:auth_url] = MrntQuantum.get_keystone_auth_url(rv[:keystone])
    rv[:server][:api_url] = MrntQuantum.get_quantum_srv_api_url(rv[:server])
    rv[:amqp] = MrntQuantum.get_amqp_config(rv[:amqp])
    return rv
  end

  def initialize(scope, cfg)
    @scope = scope
    @given_config = cfg
  end

  def generate_config()
    rv = _generate_config(generate_default_quantum_config(), @given_config, [])
  end

  private

  def _generate_config(cfg_dflt, cfg_user, path)
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
        when "Hash"     then cfg_user[k] ? _generate_config(v,cfg_user[k], path.clone.insert(-1, k)) : v
        when "Array"    then cfg_user[k].empty?() ? v : cfg_user[k]
        when "String"   then cfg_user[k] ? cfg_user[k] : v
        when "NilClass" then cfg_user[k] ? cfg_user[k] : v
        else v
      end
    end
    return rv
  end

end


Puppet::Parser::Functions::newfunction(:sanitize_quantum_config, :type => :rvalue, :doc => <<-EOS
    This function get Hash of Quantum configuration
    and sanitize it.

    Example call this:
    $config = sanitize_quantum_config(parse_json($quantum_json_config))

    EOS
  ) do |argv|

  given_config = MrntQuantum.sanitize_hash(argv[0])
  q_conf = MrntQuantum.new(self, given_config)
  return q_conf.generate_config()
end

# vim: set ts=2 sw=2 et :