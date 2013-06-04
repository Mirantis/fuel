#
class quantum (
  $rabbit_password,
  $enabled                = true,
  $package_ensure         = 'present',
  $verbose                = 'False',
  $debug                  = 'False',
  $bind_host              = '0.0.0.0',
  $bind_port              = '9696',
  $core_plugin            = 'quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2',
  $auth_strategy          = 'keystone',
  $base_mac               = 'fa:16:3e:00:00:00',
  $mac_generation_retries = 16,
  $dhcp_lease_duration    = 120,
  $allow_bulk             = 'True',
  $allow_overlapping_ips  = 'False',
  $rpc_backend            = 'quantum.openstack.common.rpc.impl_kombu',
  $control_exchange       = 'quantum',
  $rabbit_host            = 'localhost',
  $rabbit_port            = '5672',
  $rabbit_user            = 'guest',
  $rabbit_virtual_host    = '/',
  $rabbit_ha_virtual_ip   = false,
  $server_ha_mode         = false,
  $use_syslog = false
) {
  include 'quantum::params'

  Package['quantum'] -> Quantum_config<||>
  Package['quantum'] -> Quantum_api_config<||>

  file {'/etc/quantum':
    ensure  => directory,
    owner   => 'quantum',
    group   => 'root',
    mode    => 770,
    require => Package['quantum']
  }

  package {'quantum':
    name   => $::quantum::params::package_name,
    ensure => $package_ensure
  }

  if is_array($rabbit_host) and size($rabbit_host) > 1 {
    if $rabbit_ha_virtual_ip {
      $rabbit_hosts = "${rabbit_ha_virtual_ip}:${rabbit_port}"
    } else {
      $rabbit_hosts = inline_template("<%= @rabbit_host.map {|x| x + ':' + @rabbit_port}.join ',' %>")
    }
    Quantum_config['DEFAULT/rabbit_ha_queues'] -> Service<| title == 'quantum-server' |>
    Quantum_config['DEFAULT/rabbit_ha_queues'] -> Service<| title == 'quantum-plugin-ovs-service' |>
    Quantum_config['DEFAULT/rabbit_ha_queues'] -> Service<| title == 'quantum-l3' |>
    Quantum_config['DEFAULT/rabbit_ha_queues'] -> Service<| title == 'quantum-dhcp-agent' |>
    quantum_config {
      'DEFAULT/rabbit_ha_queues': value => 'True';
      'DEFAULT/rabbit_hosts':     value => $rabbit_hosts;
    }
  } else {
    quantum_config {
      'DEFAULT/rabbit_host': value => is_array($rabbit_host) ? { false => $rabbit_host, true => join($rabbit_host) };
      'DEFAULT/rabbit_port': value => $rabbit_port;
    }
  }

  if $server_ha_mode {
    $real_bind_host = $bind_host
  } else {
    $real_bind_host = '0.0.0.0'
  }

  quantum_config {
    'DEFAULT/verbose':                value => $verbose;
    'DEFAULT/debug':                  value => $debug;
    'DEFAULT/bind_host':              value => $real_bind_host;
    'DEFAULT/bind_port':              value => $bind_port;
    'DEFAULT/auth_strategy':          value => $auth_strategy;
    'DEFAULT/core_plugin':            value => $core_plugin;
    'DEFAULT/base_mac':               value => $base_mac;
    'DEFAULT/mac_generation_retries': value => $mac_generation_retries;
    'DEFAULT/dhcp_lease_duration':    value => $dhcp_lease_duration;
    'DEFAULT/allow_bulk':             value => $allow_bulk;
    'DEFAULT/allow_overlapping_ips':  value => $allow_overlapping_ips;
    'DEFAULT/rpc_backend':            value => $rpc_backend;
    'DEFAULT/control_exchange':       value => $control_exchange;
    'DEFAULT/rabbit_userid':          value => $rabbit_user;
    'DEFAULT/rabbit_password':        value => $rabbit_password;
    'DEFAULT/rabbit_virtual_host':    value => $rabbit_virtual_host;
  }

  if $use_syslog {
    quantum_config {'DEFAULT/log_config': value => "/etc/quantum/logging.conf";}
    file { "quantum-logging.conf":
      content => template('quantum/logging.conf.erb'),
      path => "/etc/quantum/logging.conf",
      owner => "quantum",
      group => "quantum",
    }
  } else {
    quantum_config {'DEFAULT/log_config': ensure=> absent;}
  }

  # SELINUX=permissive
}
