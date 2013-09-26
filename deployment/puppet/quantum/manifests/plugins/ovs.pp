class quantum::plugins::ovs (
  $quantum_config       = {},
) {


  # todo: Remove plugin section, add plugin to server class

  include 'quantum::params'
  include 'l23network::params'
  
  Anchor<| title=='quantum-server-config-done' |> ->
    Anchor['quantum-plugin-ovs']
  Anchor['quantum-plugin-ovs-done'] ->
    Anchor<| title=='quantum-server-done' |>

  anchor {'quantum-plugin-ovs':}

  Quantum_plugin_ovs<||> ~> Service<| title == 'quantum-server' |>
  # not need!!!
  # agent starts after server
  # Quantum_plugin_ovs<||> ~> Service<| title == 'quantum-ovs-agent' |>

  case $quantum_config['database']['provider'] {
    /(?i:mysql)/: {
      require 'mysql::python'
    }
    /(?i:postgresql)/: {
      $backend_package = 'python-psycopg2'
    }
    /(?i:sqlite)/: {
      $backend_package = 'python-pysqlite2'
    }
    defeault: {
      fail('Unsupported backend configured')
    }
  }

  if ! defined(File['/etc/quantum']) {
    file {'/etc/quantum':
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
    }
  }
  package { 'quantum-plugin-ovs':
    name    => $::quantum::params::ovs_server_package,
  } ->
  File['/etc/quantum'] ->
  file {'/etc/quantum/plugins':
    ensure  => directory,
    mode    => '0755',
  } ->
  file {'/etc/quantum/plugins/openvswitch':
    ensure  => directory,
    mode    => '0755',
  } ->
  file { '/etc/quantum/plugin.ini':
    ensure  => link,
    target  => '/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini',
  }
  quantum_plugin_ovs {
    'DATABASE/sql_connection':      value => $quantum_config['database']['url'];
    'DATABASE/sql_max_retries':     value => $quantum_config['database']['reconnects'];
    'DATABASE/reconnect_interval':  value => $quantum_config['database']['reconnect_interval'];
  } ->
  quantum_plugin_ovs {
    'OVS/integration_bridge':       value => $quantum_config['database']['L2']['integration_bridge'];
    'OVS/tenant_network_type':      value => $quantum_config['database']['L2']['segmentation_type'];
    'OVS/enable_tunneling':         value => $quantum_config['database']['L2']['enable_tunneling'];
    'AGENT/polling_interval':       value => $quantum_config['polling_interval'];
    'AGENT/root_helper':            value => $quantum_config['root_helper'];
  }

  case $quantum_config['database']['L2']['segmentation_type'] {
    'gre': {
      quantum_plugin_ovs {
        'OVS/tunnel_bridge':     value => $quantum_config['database']['L2']['tunnel_bridge'];
        'OVS/tunnel_id_ranges':  value => $quantum_config['database']['L2']['tunnel_id_ranges'];
      }
    }
    'vlan': {
      quantum_plugin_ovs {
        'OVS/network_vlan_ranges':  value => $quantum_config['database']['L2']['network_vlan_ranges'];
        'OVS/bridge_mappings':      value => $quantum_config['database']['L2']['bridge_mappings'];
      }

      if ! (defined(Package["$::quantum::params::vlan_package"]) or defined(Package["$::l23network::params::lnx_vlan_tools"])) {
        package {"$::l23network::params::lnx_vlan_tools":
          name    => "$::l23network::params::lnx_vlan_tools",
          ensure  => latest,
        } -> Package['quantum-plugin-ovs']
      }
    }
    default: {
      fail("Unsupported segmentation type: ${::osfamily}/${quantum_config['database']['L2']['segmentation_type']}")
    }
  }

  File['/etc/quantum/plugin.ini'] ->
    Quantum_plugin_ovs<||> ->
      Anchor<| title=='quantum-server-config-done' |>

  File['/etc/quantum/plugin.ini'] ->
    Anchor['quantum-plugin-ovs-done']
  Anchor['quantum-plugin-ovs'] -> Anchor['quantum-plugin-ovs-done']

  anchor {'quantum-plugin-ovs-done':}
}
#
###
