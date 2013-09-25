require 'spec_helper'

class QuantumConfig
  def initialize(init_v)
    @def_v = {}
    @def_v.replace(init_v)
    @def_config = {
      :amqp => {
        :provider => "rabbitmq",
        :username => "nova",
        :passwd => "nova",
        :hosts => "#{@def_v[:management_vip]}:5672",
        :control_exchange => "quantum",
        :heartbeat => 60,
        :protocol => "tcp",
        :rabbit_virtual_host => "/",
        :ha_mode => true,
      },
      :database => {
        :provider => "mysql",
        :host => "#{@def_v[:management_vip]}",
        :port => 3306,
        :database => "quantum",
        :username => "quantum",
        :passwd   => "quantum",
        :reconnects => -1,
        :reconnect_interval => 2,
      },
      :keystone => {
        :auth_host => "#{@def_v[:management_vip]}",
        :auth_port => 35357,
        :auth_region => 'RegionOne',
        :auth_protocol => "http",
        :auth_api_version => "v2.0",
        :admin_tenant_name => "services",
        :admin_user => "quantum",
        :admin_password => "quantum_pass",
        :admin_email => "quantum@localhost",
        :signing_dir => "/var/lib/quantum/keystone-signing",
      },
      :server => {
        :api_url => "http://#{@def_v[:management_vip]}:9696",
        :api_protocol => "http",
        :bind_host => "#{@def_v[:management_vip]}",
        :bind_port => 9696,
        :agent_down_time => 15,
        :allow_bulk      => true,
        :control_exchange=> 'quantum',
      },
      :metadata => {
        :nova_metadata_ip => "#{@def_v[:management_vip]}",
        :nova_metadata_port => 8775,
        :metadata_ip => "169.254.169.254",
        :metadata_port => 8775,
        :metadata_proxy_shared_secret => "secret-word",
      },
      :L2 => {
        :base_mac => "fa:16:3e:00:00:00",
        :mac_generation_retries => 32,
        :segmentation_type => "gre",
        :enable_tunneling=>true,
        :tunnel_id_ranges => "3000:65535",
        :bridge_mappings => ["physnet1:br-ex", "physnet2:br-prv"],
        :network_vlan_ranges => ["physnet1", "physnet2:3000:4094"],
        :integration_bridge => "br-int",
        :tunnel_bridge => "br-tun",
        :int_peer_patch_port => "patch-tun",
        :tun_peer_patch_port => "patch-int",
        :local_ip => "#{@def_v[:management_vip]}",
      },
      :L3 => {
        :router_id => nil,
        :gateway_external_network_id => nil,
        :use_namespaces => true,
        :allow_overlapping_ips => false,
        :network_auto_schedule => true,
        :router_auto_schedule  => true,
        :public_bridge => "br-ex",
        #:public_network => "net04_ext",
        :send_arp_for_ha => 8,
        :resync_interval => 40,
        :resync_fuzzy_delay => 5,
        :dhcp_agent => {
          :enable_isolated_metadata => false,
          :enable_metadata_network => false,
          :lease_duration => 120
        }
      },
      :predefined_routers => {
        :router04 => {
          :tenant => 'admin',
          :virtual => false,
          :external_network => "net04_ext",
          :internal_networks => ["net04"],
        }
      },
      :predefined_networks => {
        :net04_ext => {
          :shared => false,
          :L2 => {
            :router_ext   => true,
            :network_type => 'flat',
            :physnet      => 'physnet1',
            :segment_id   => nil,
          },
          :L3 => {
            :subnet => "10.100.100.0/24",
            :gateway => "10.100.100.1",
            :nameservers => [],
            :floating => "10.100.100.130:10.100.100.254",
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
            :subnet => "192.168.111.0/24",
            :gateway => "192.168.111.1",
            :nameservers => ["8.8.4.4", "8.8.8.8"],
            :floating => nil,
          },
        },
      },
      :root_helper => "sudo quantum-rootwrap /etc/quantum/rootwrap.conf",
    }
    @def_config[:keystone][:auth_url] = "http://#{@def_v[:management_vip]}:35357/v2.0"
  end

  def get_def_config()
    return Marshal.load(Marshal.dump(@def_config))
  end

  def get_def(k)
    return @def_v[k]
  end

  # def get_config(mix)
  #   cfg = {}
  #   cfg.replace(@def_config)
  # end

end

describe 'sanitize_quantum_config' , :type => :puppet_function do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  before :each do
    # node      = Puppet::Node.new("floppy", :environment => 'production')
    # @compiler = Puppet::Parser::Compiler.new(node)
    # @scope    = Puppet::Parser::Scope.new(@compiler)
    # @topscope = @scope.compiler.topscope
    # @scope.parent = @topscope
    # Puppet::Parser::Functions.function(:create_resources)
    @q_config = QuantumConfig.new({
      :management_vip => '192.168.0.254'
    })
    Puppet::Parser::Scope.any_instance.stubs(:lookupvar).with('quantum_vip').returns(@q_config.get_def(:management_vip))
    Puppet::Parser::Scope.any_instance.stubs(:lookupvar).with('database_vip').returns(@q_config.get_def(:management_vip))
    Puppet::Parser::Scope.any_instance.stubs(:lookupvar).with('management_vip').returns(@q_config.get_def(:management_vip))
    Puppet::Parser::Scope.any_instance.stubs(:lookupvar).with('amqp_vip').returns(@q_config.get_def(:management_vip))
  end

  it 'should exist' do
    Puppet::Parser::Functions.function('sanitize_quantum_config').should == 'function_sanitize_quantum_config'
  end

  it 'should return default config if incoming hash is empty' do
    res_cfg = @q_config.get_def_config()
    should run.with_params({}).and_return(res_cfg)
  end

  it 'should return default config if default config given as incoming' do
    cfg = @q_config.get_def_config()
    res_cfg = cfg.clone()
    should run.with_params(cfg).and_return(res_cfg)
  end

  it 'should substitute default values if missing required field in config' do
    cfg = @q_config.get_def_config()
    res_cfg = @q_config.get_def_config()
    cfg[:L3].delete(:dhcp_agent)
    should run.with_params(cfg).and_return(res_cfg)
  end

  it 'should can substitute values in deep level' do
    cfg = @q_config.get_def_config()
    cfg[:amqp][:provider] = "XXXXXXXXXXxxxx"
    cfg[:L2][:base_mac] = "aa:aa:aa:00:00:00"
    cfg[:L2][:integration_bridge] = "xx-xxx"
    cfg[:L2][:local_ip] = "9.9.9.9"
    cfg[:predefined_networks][:net04_ext][:L3][:nameservers] = ["127.0.0.1"]
    res_cfg = Marshal.load(Marshal.dump(cfg))
    should run.with_params(cfg).and_return(res_cfg)
  end

end


require "#{File.expand_path(File.dirname(__FILE__))}/../../lib/puppet/parser/functions/sanitize_quantum_config.rb"

describe MrntQuantum do
  describe '.get_keystone_auth_url' do
    it 'should return right auth url' do
      MrntQuantum.get_keystone_auth_url({
        :auth_protocol => 'http',
        :auth_host => 'localhost',
        :auth_port => '5000',
        :auth_api_version => 'v2.0'
      }).should == 'http://localhost:5000/v2.0'
    end
  end

  describe '.get_amqp_config' do
    it 'should return hash with amqp hosts declaration as string for HA mode' do
      MrntQuantum.get_amqp_config({
        :provider => 'rabbitmq',
        :hosts => "1.2.3.4:567  ,  2.3.4.5:678, 3.4.5.6,4.5.6.7:890",
        :port => 555,
        :ha_mode => true,
      }).should == {
        :ha_mode => true,
        :hosts => "1.2.3.4:567,2.3.4.5:678,3.4.5.6:555,4.5.6.7:890",
        :port => 555,
        :provider => "rabbitmq"
      }
    end
  end
  describe '.get_amqp_config' do
    it 'should return hash with amqp hosts declaration as array of string for HA mode' do
      MrntQuantum.get_amqp_config({
        :provider => 'rabbitmq',
        :hosts => ['1.2.3.4:567', '2.3.4.5:678', '3.4.5.6', '4.5.6.7:890'],
        :port => 555,
        :ha_mode => true,
      }).should == {
        :ha_mode => true,
        :hosts => "1.2.3.4:567,2.3.4.5:678,3.4.5.6:555,4.5.6.7:890",
        :port => 555,
        :provider => "rabbitmq"
      }
    end
  end
  describe '.get_amqp_config' do
    it 'should return hash with amqp hosts declaration as array of string without ports for HA mode' do
      MrntQuantum.get_amqp_config({
        :provider => 'rabbitmq',
        :hosts => ['1.2.3.4', '2.3.4.5', '3.4.5.6', '4.5.6.7'],
        :port => 555,
        :ha_mode => true,
      }).should == {
        :ha_mode => true,
        :hosts => "1.2.3.4:555,2.3.4.5:555,3.4.5.6:555,4.5.6.7:555",
        :port => 555,
        :provider => "rabbitmq"
      }
    end
  end
  describe '.get_amqp_config' do
    it 'should return hash with amqp host declaration as string without port for solo mode' do
      MrntQuantum.get_amqp_config({
        :provider => 'rabbitmq',
        :hosts => '1.2.3.4:567',
        :port => 555,
        :ha_mode => false,
      }).should == {
        :ha_mode => false,
        :hosts => "1.2.3.4",
        :port => 567,
        :provider => "rabbitmq"
      }
    end
  end
  describe '.get_amqp_config' do
    it 'should return hash with amqp host declaration as string without port for solo mode' do
      MrntQuantum.get_amqp_config({
        :provider => 'rabbitmq',
        :hosts => '1.2.3.4',
        :port => 555,
        :ha_mode => false,
      }).should == {
        :ha_mode => false,
        :hosts => "1.2.3.4",
        :port => 555,
        :provider => "rabbitmq"
      }
    end
  end
end

# vim: set ts=2 sw=2 et :