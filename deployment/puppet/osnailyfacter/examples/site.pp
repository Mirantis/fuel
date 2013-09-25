# Import setting from yaml fact
$fuel_settings = parseyaml($::astute_settings_yaml)

$openstack_version = {
  'keystone'   => 'latest',
  'glance'     => 'latest',
  'horizon'    => 'latest',
  'nova'       => 'latest',
  'novncproxy' => 'latest',
  'cinder'     => 'latest',
}

tag("${::fuel_settings['deployment_id']}::${::fuel_settings['environment']}")

#Stages configuration
stage {'first': } ->
stage {'openstack-custom-repo': } ->
stage {'netconfig': } ->
stage {'corosync_setup': } ->
stage {'cluster_head': } ->
stage {'openstack-firewall': } ->
Stage['main'] ->
stage {'glance-image': }

if $::fuel_settings['nodes'] {

  $nodes_hash = $::fuel_settings['nodes']
  $node = filter_nodes($::nodes_hash, 'name', $::hostname)

  if empty($::node) {
    fail("Node ${::hostname} is not defined in the hash structure!")
  }

  $default_gateway  = $::node[0]['default_gateway']
  $internal_address = $::node[0]['internal_address']
  $internal_netmask = $::node[0]['internal_netmask']
  $public_address   = $::node[0]['public_address']
  $public_netmask   = $::node[0]['public_netmask']
  $storage_address  = $::node[0]['storage_address']
  $storage_netmask  = $::node[0]['storage_netmask']
  $public_br        = $::node[0]['public_br']
  $internal_br      = $::node[0]['internal_br']
  $base_syslog_hash = $::fuel_settings['base_syslog']
  $syslog_hash      = $::fuel_settings['syslog']

  $use_quantum = $::fuel_settings['quantum']
  
  if $use_quantum {
    $public_int   = $::public_br
    $internal_int = $::internal_br
  } else {
    $public_int   = $::fuel_settings['public_interface']
    $internal_int = $::fuel_settings['management_interface']
  }

}

# This parameter specifies the verbosity level of log messages
# in openstack components config.
# Debug would have set DEBUG level and ignore verbose settings, if any.
# Verbose would have set INFO level messages
# In case of non debug and non verbose - WARNING, default level would have set.
# Note: if syslog on, this default level may be configured (for syslog) with syslog_log_level option.
$verbose = $::fuel_settings['verbose']
$debug = $::fuel_settings['debug']

### Syslog ###
# Enable error messages reporting to rsyslog. Rsyslog must be installed in this case.
$use_syslog = true

# Default log level would have been used, if non verbose and non debug
$syslog_log_level = 'ERROR'

# Syslog facilities for main openstack services, choose any, may overlap if needed
# local0 is reserved for HA provisioning and orchestration services,
# local1 is reserved for openstack-dashboard
$syslog_log_facility_glance   = 'LOCAL2'
$syslog_log_facility_cinder   = 'LOCAL3'
$syslog_log_facility_quantum  = 'LOCAL4'
$syslog_log_facility_nova     = 'LOCAL6'
$syslog_log_facility_keystone = 'LOCAL7'

$nova_rate_limits = {
  'POST' => 1000,
  'POST_SERVERS' => 1000,
  'PUT' => 1000, 'GET' => 1000,
  'DELETE' => 1000
}

$cinder_rate_limits = {
  'POST' => 1000,
  'POST_SERVERS' => 1000,
  'PUT' => 1000, 'GET' => 1000,
  'DELETE' => 1000
}

case $::operatingsystem {
  'redhat' : {
    $queue_provider = 'qpid'
    $custom_mysql_setup_class = 'pacemaker_mysql'
  }
  default: {
    $queue_provider = 'rabbitmq'
    $custom_mysql_setup_class = 'galera'
  }
}

if $::fuel_settings['quantum'] {
  $quantum_hash   = $::fuel_settings['quantum_access']
  $quantum_params = $::fuel_settings['quantum_parameters']
  $novanetwork_params  = {}
} else {
  $quantum_hash = {}
  $quantum_params = {}
  $novanetwork_params  = $::fuel_settings['novanetwork_parameters']
}

if $fuel_settings['cinder_nodes'] {
   $cinder_nodes_array   = $::fuel_settings['cinder_nodes']
}
else {
  $cinder_nodes_array = []
}

$nova_hash            = $::fuel_settings['nova']
$mysql_hash           = $::fuel_settings['mysql']
$rabbit_hash          = $::fuel_settings['rabbit']
$glance_hash          = $::fuel_settings['glance']
$keystone_hash        = $::fuel_settings['keystone']
$swift_hash           = $::fuel_settings['swift']
$cinder_hash          = $::fuel_settings['cinder']
$access_hash          = $::fuel_settings['access']
$nodes_hash           = $::fuel_settings['nodes']
$mp_hash              = $::fuel_settings['mp']

$vlan_start           = $novanetwork_params['vlan_start']
$network_manager      = "nova.network.manager.${novanetwork_params['network_manager']}"
$network_size         = $novanetwork_params['network_size']
$num_networks         = $novanetwork_params['num_networks']
$tenant_network_type  = $quantum_params['tenant_network_type']
$segment_range        = $quantum_params['segment_range']

if !$rabbit_hash['user'] {
  $rabbit_hash['user'] = 'nova'
}
$rabbit_user = $rabbit_hash['user']

$auto_assign_floating_ip = $::fuel_settings['auto_assign_floating_ip']

if $::use_quantum {
  $floating_hash = $::fuel_settings['floating_network_range']
} else {
  $floating_hash = {}
  $floating_ips_range = $::fuel_settings['floating_network_range']
}

$controller = filter_nodes($::nodes_hash, 'role', 'controller')
$controller_node_address = $::controller[0]['internal_address']
$controller_node_public = $::controller[0]['public_address']

if ($::fuel_settings['cinder']) {
  if (member($::cinder_nodes_array, 'all')) {
    $is_cinder_node = true
  } elsif (member($::cinder_nodes_array, $::hostname)) {
    $is_cinder_node = true
  } elsif (member($::cinder_nodes_array, $::internal_address)) {
    $is_cinder_node = true
  } elsif ($node[0]['role'] =~ /controller/ ) {
    $is_cinder_node = member($::cinder_nodes_array, 'controller')
  } else {
    $is_cinder_node = member($::cinder_nodes_array, $node[0]['role'])
  }
} else {
  $is_cinder_node = false
}

$cinder_iscsi_bind_addr = $::storage_address

# do not edit the below line
validate_re($::queue_provider,  'rabbitmq|qpid')

$network_config = {
  'vlan_start'     => $vlan_start,
}

$sql_connection = "mysql://nova:${::nova_hash['db_password']}@${::controller_node_address}/nova"
$mirror_type    = 'external'
$multi_host     = true

Exec { logoutput => true }

$quantum_host            = $controller_node_address
$quantum_sql_connection  = "mysql://${quantum_db_user}:${quantum_db_password}@${quantum_host}/${quantum_db_dbname}"
$quantum_metadata_proxy_shared_secret = $quantum_params['metadata_proxy_shared_secret']
$quantum_gre_bind_addr = $::internal_address

#TODO: awoodward fix static $use_ceph
$use_ceph = false

if ($::use_ceph) {
  $primary_mons   = $::controller
  $primary_mon    = $::controller[0]['name']
  $glance_backend = 'ceph'

  class { 'ceph' : 
    primary_mon  => $::primary_mon,
    cluster_node_address => $::controller_node_address,
  }

} else {
  $glance_backend = 'file'
}

# NODES SECTION #
node default {
  case $::fuel_settings['deployment_mode'] {
    'singlenode': {
      class { 'osnailyfacter::cluster_simple' :}
      class { 'osnailyfacter::os_common' :}
    }
    'multinode': {
      class { 'osnailyfacter::cluster_simple' :}
      class { 'osnailyfacter::os_common': }
    }
    /^(ha|ha_compact)$/: {
      class { 'osnailyfacter::cluster_ha' :}
      class { 'osnailyfacter::os_common' :}
    }
    'ha_full': {
      class { 'osnailyfacter::cluster_ha_full' :}
      class { 'osnailyfacter::os_common' :}
    }
    'rpmcache': {
      class { 'osnailyfacter::rpmcache' :}
    }
  }
}
