class neutron::plugins::nicira (
  $neutron_config = {},
  $ip_address = $::ipaddress,
  $on_compute = false;
)
{
  if ! on_compute {
    Anchor<| title=='neutron-server-config-done' |> ->
      Anchor['neutron-plugin-nicira']

    Anchor['neutron-plugin-nicira-done'] ->
      Anchor<| title=='neutron-server-done' |>

  }
  anchor {'neutron-plugin-nicira':}

  if ! on_compute {
    Quantum_plugin_ovs<||> ~> Service<| title == 'neutron-server' |>
  }
  $br_int = $neutron_config['L2']['integration_bridge']

  
  l2_ovs_bridge { $br_int:
    external_ids => "bridge-id=${br_int}",
    in_band      => true,
    fail_mode    => 'secure',
  } ->
  l2_ovs_nicira { $::hostname:
    ensure => present,
    nsx_username => $neutron_config['nicira']['nsx_username'],
    nsx_password => $neutron_config['nicira']['nsx_password'],
    nsx_endpoint => $neutron_config['nicira']['nvp_controllers'],
    transport_zone_uuid => $neutron_config['nicira']['transport_zone_uuid'],
    ip_address => $ip_address,
    connector_type => $neutron_config['nicira']['connector_type'],
    integration_bridge => $br_int,
  }

  if ! on_compute {
    if ! defined(File['/etc/neutron']) {
      file {'/etc/neutron':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
      }
    }

    File['/etc/neutron'] ->
    file {'/etc/neutron/plugins':
      ensure  => directory,
      mode    => '0755',
    } ->
    file {'/etc/neutron/plugins/openvswitch':
      ensure  => directory,
      mode    => '0755',
    } ->
    file { '/etc/neutron/plugin.ini':
      ensure  => link,
      target  => '/etc/neutron/plugins/nicira/nvp.ini',
    }
  #  neutron_plugin_nicira {
  #    'DATABASE/sql_connection':      value => $neutron_config['database']['url'];
  #    'DATABASE/sql_max_retries':     value => $neutron_config['database']['reconnects'];
  #    'DATABASE/reconnect_interval':  value => $neutron_config['database']['reconnect_interval'];
  #  } ->
    neutron_plugin_nicira {
      'DEFAULT/default_tz_uuid':            value => $neutron_config['nicira']['transport_zone_uuid'];
      'DEFAULT/nvp_user':                   value => $neutron_config['nicira']['nsx_username'];
      'DEFAULT/nvp_password':               value => $neutron_config['nicira']['nsx_password'];
      'DEFAULT/req_timeout':                value => 30;
      'DEFAULT/http_timeout':               value => 10;
      'DEFAULT/retries':                    value => 2;
      'DEFAULT/redirects':                  value => 2; 
      'DEFAULT/nvp_controllers':            value => $neutron_config['nicira']['nvp_controllers']; 
      'DEFAULT/default_l3_gw_service_uuid': value => $neutron_config['nicira']['l3_gw_service_uuid'];
      'quotas/quota_network_gateway':       value => -1;
      'nvp/max_lp_per_bridged_ls':          value => 5000;
      'nvp/max_lp_per_overlay_ls':          value => 256;
      'nvp/metadata_mode':                  value => 'dhcp_host_route';
      'nvp/default_transport_type':         value => $neutron_config['nicira']['connector_type'];
    }
  
  }
  anchor {'neutron-plugin-nicira-done':}
}
