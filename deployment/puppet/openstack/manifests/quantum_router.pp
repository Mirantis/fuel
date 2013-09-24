#This class installs quantum WITHOUT quantum api server which is installed on controller nodes
# [use_syslog] Rather or not service should log to syslog. Optional.
# [syslog_log_facility] Facility for syslog, if used. Optional. Note: duplicating conf option
#       wouldn't have been used, but more powerfull rsyslog features managed via conf template instead
# [syslog_log_level] logging level for non verbose and non debug mode. Optional.

class openstack::quantum_router (
  $rabbit_password,
  $internal_address         = $::ipaddress_br_mgmt,
  $public_interface         = "br-ex",
  $private_interface        = "br-mgmt",
  $create_networks          = true,
  $queue_provider           = 'rabbitmq',
  $rabbit_user              = 'nova',
  $rabbit_nodes             = ['127.0.0.1'],
  $rabbit_ha_virtual_ip     = false,
  $qpid_password            = 'qpid_pw',
  $qpid_user                = 'nova',
  $qpid_nodes               = ['127.0.0.1'],
  $verbose                  = 'False',
  $debug                    = 'False',
  $enabled                  = true,
  $ensure_package           = present,
  $quantum                  = false,
  $quantum_config           = {},
  $quantum_network_node     = false,
  $use_syslog               = false,
  $syslog_log_facility      = 'LOCAL4',
  $syslog_log_level         = 'WARNING',
  $ha_mode                  = false,
  $service_provider         = 'generic',
) {
    class { '::quantum':
      quantum_config       => $quantum_config,
      queue_provider       => $queue_provider,
      verbose              => $verbose,
      debug                => $debug,
      use_syslog           => $use_syslog,
      syslog_log_facility  => $syslog_log_facility,
      syslog_log_level     => $syslog_log_level,
      server_ha_mode       => $ha_mode,
    }
    #todo: add quantum::server here (into IF)
    class { 'quantum::plugins::ovs':
      quantum_config      => $quantum_config,
      #bridge_mappings     => ["physnet1:br-ex","physnet2:br-prv"],
    }


    if $quantum_network_node {
      class { 'quantum::agents::ovs':
        #bridge_uplinks   => ["br-prv:${private_interface}"],
        bridge_mappings  => ['physnet2:br-prv'],
        enable_tunneling => $enable_tunneling,
        local_ip         => $internal_address,
        service_provider => $service_provider
      }
      # Quantum metadata agent starts only under pacemaker
      # and co-located with l3-agent
      class {'quantum::agents::metadata':
        verbose          => $verbose,
        debug            => $debug,
        service_provider => $service_provider,
        auth_tenant      => 'services',
        auth_user        => 'quantum',
        auth_url         => $admin_auth_url,
        auth_region      => 'RegionOne',
        auth_password    => $quantum_user_password,
        shared_secret    => $quantum_metadata_proxy_shared_secret,
        metadata_ip      => $nova_api_vip,
      }
      class { 'quantum::agents::dhcp':
        verbose          => $verbose,
        debug            => $debug,
        use_namespaces   => $use_namespaces,
        service_provider => $service_provider,
        auth_url         => $admin_auth_url,
        auth_tenant      => 'services',
        auth_user        => 'quantum',
        auth_password    => $quantum_user_password,
      }
      class { 'quantum::agents::l3':
       #enabled             => $quantum_l3_enable,
        verbose             => $verbose,
        debug               => $debug,
        use_namespaces      => $use_namespaces,
        service_provider    => $service_provider,
        fixed_range         => $fixed_range,
        floating_range      => $floating_range,
        ext_ipinfo          => $external_ipinfo,
        tenant_network_type => $tenant_network_type,
        create_networks     => $create_networks,
        segment_range       => $segment_range,
        auth_url            => $admin_auth_url,
        auth_tenant         => 'services',
        auth_user           => 'quantum',
        auth_password       => $quantum_user_password,
        metadata_ip         => $internal_address,
        nova_api_vip        => $nova_api_vip,
      }
    }

    if !defined(Sysctl::Value['net.ipv4.ip_forward']) {
      sysctl::value { 'net.ipv4.ip_forward': value => '1'}
    }

}

