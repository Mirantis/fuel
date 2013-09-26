class osnailyfacter::os_common {

  class { 'l23network' :
    use_ovs => $::use_quantum,
    stage   => 'netconfig'
  }

  if $::fuel_settings['deployment_source'] == 'cli' {
    class { 'osnailyfacter::node_netconfig' :
      mgmt_ipaddr     => $::internal_address,
      mgmt_netmask    => $::internal_netmask,
      public_ipaddr   => $::public_address,
      public_netmask  => $::public_netmask,
      default_gateway => $::default_gateway,
      stage           => 'netconfig',
    }
  } else {
    class { 'osnailyfacter::network_setup' :
      stage => 'netconfig',
    }
  }

  class { 'openstack::firewall' :
    stage => 'openstack-firewall',
  }

  $base_syslog_rserver  = {
    'remote_type' => 'udp',
    'server'      => $::base_syslog_hash['syslog_server'],
    'port'        => $::base_syslog_hash['syslog_port']
  }

  $syslog_rserver = {
    'remote_type' => $::syslog_hash['syslog_transport'],
    'server'      => $::syslog_hash['syslog_server'],
    'port'        => $::syslog_hash['syslog_port'],
  }

  if $::syslog_hash['syslog_server'] != "" and $::syslog_hash['syslog_port'] != "" and $::syslog_hash['syslog_transport'] != "" {
    $rservers = [$base_syslog_rserver, $syslog_rserver]
  } else {
    $rservers = [$base_syslog_rserver]
  }

  if $::use_syslog {
    class { "::openstack::logging":
      stage          => 'first',
      role           => 'client',
      show_timezone  => true,
      # log both locally include auth, and remote
      log_remote     => true,
      log_local      => true,
      log_auth_local => true,
      # keep four weekly log rotations, force rotate if 300M size have exceeded
      rotation       => 'weekly',
      keep           => '4',
      # should be > 30M
      limitsize      => '300M',
      # remote servers to send logs to
      rservers       => $rservers,
      # should be true, if client is running at virtual node
      virtual        => true,
      # facilities
      syslog_log_facility_glance   => $::syslog_log_facility_glance,
      syslog_log_facility_cinder   => $::syslog_log_facility_cinder,
      syslog_log_facility_quantum  => $::syslog_log_facility_quantum,
      syslog_log_facility_nova     => $::syslog_log_facility_nova,
      syslog_log_facility_keystone => $::syslog_log_facility_keystone,
      # Rabbit doesn't support syslog directly, should be >= syslog_log_level,
      # otherwise none rabbit's messages would have gone to syslog
      rabbit_log_level => $::syslog_log_level,
      # debug mode
      debug          => $::debug,
    }
  }

  # Workaround for fuel bug with firewall
  firewall { '003 remote rabbitmq ' :
    sport   => [ 4369, 5672, 41055, 55672, 61613 ],
    source  => $::fuel_settings['master_ip'],
    proto   => 'tcp',
    action  => 'accept',
    require => Class['openstack::firewall'],
  }

}
