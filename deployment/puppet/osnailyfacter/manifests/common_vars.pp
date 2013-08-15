
if $quantum == 'true'
{
  $quantum_hash   = parsejson($::quantum_access)
  $quantum_params = parsejson($::quantum_parameters)
  $novanetwork_params  = {}

}
else
{
  $quantum_hash = {}
  $quantum_params = {}
  $novanetwork_params  = parsejson($::novanetwork_parameters)
}

if $cinder_nodes {
   $cinder_nodes_array = parsejson($::cinder_nodes)
}
else {
  $cinder_nodes_array = []
}


$nova_hash            = parsejson($::nova)
$mysql_hash           = parsejson($::mysql)
$rabbit_hash          = parsejson($::rabbit)
$glance_hash          = parsejson($::glance)
$keystone_hash        = parsejson($::keystone)
$swift_hash           = parsejson($::swift)
$cinder_hash          = parsejson($::cinder)
$access_hash          = parsejson($::access)
$nodes_hash           = parsejson($::nodes)
$mp_hash              = parsejson($::mp)
$network_manager      = "nova.network.manager.${novanetwork_params['network_manager']}"
$network_size         = $novanetwork_params['network_size']
$num_networks         = $novanetwork_params['num_networks']
$tenant_network_type  = $quantum_params['tenant_network_type']
$segment_range        = $quantum_params['segment_range']
$vlan_start           = $novanetwork_params['vlan_start']

if !$rabbit_hash[user]
{
  $rabbit_hash[user] = 'nova'
}

$rabbit_user          = $rabbit_hash['user']

if $quantum {
$floating_hash =  $::floating_network_range
}


  $nodes_hash = parsejson($nodes)
  $base_syslog_hash     = parsejson($::base_syslog)
  $syslog_hash          = parsejson($::syslog)

  $node = filter_nodes($nodes_hash,'name',$::hostname)
  if empty($node) {
    fail("Node $::hostname is not defined in the hash structure")
  }


$node = filter_nodes($nodes_hash,'name',$::hostname)
if empty($node) {
  fail("Node $::hostname is not defined in the hash structure")
}

$vips = { # Do not convert to ARRAY, It cant work in 2.7
  public_old => {
    nic    => $::public_int,
    ip     => $public_vip,
  },
  management_old => {
    nic    => $::internal_int,
    ip     => $management_vip,
  },
}

$vip_keys = keys($vips)

if ($cinder) {
  if (member($cinder_nodes_array,'all')) {
    $is_cinder_node = true
  } elsif (member($cinder_nodes_array,$::hostname)) {
    $is_cinder_node = true
  } elsif (member($cinder_nodes_array,$internal_address)) {
    $is_cinder_node = true
  } elsif ($node[0]['role'] =~ /controller/ ) {
    $is_cinder_node = member($cinder_nodes_array,'controller')
  } else {
    $is_cinder_node = member($cinder_nodes_array,$node[0]['role'])
  }
} else {
  $is_cinder_node = false
}

$quantum_sql_connection  = "mysql://${quantum_db_user}:${quantum_db_password}@${quantum_host}/${quantum_db_dbname}"
$quantum_host            = $management_vip

##REFACTORING NEEDED


##TODO: simply parse nodes array
$controllers = merge_arrays(filter_nodes($nodes_hash,'role','primary-controller'), filter_nodes($nodes_hash,'role','controller'))
$controller_internal_addresses = nodes_to_hash($controllers,'name','internal_address')
$controller_public_addresses = nodes_to_hash($controllers,'name','public_address')
$controller_storage_addresses = nodes_to_hash($controllers,'name','storage_address')
$controller_hostnames = keys($controller_internal_addresses)
$controller_nodes = sort(values($controller_internal_addresses))
$mountpoints = filter_hash($mp_hash,'point')
$quantum_metadata_proxy_shared_secret = $quantum_params['metadata_proxy_shared_secret']
$quantum_gre_bind_addr = $::internal_address

$swift_local_net_ip      = $::storage_address

$cinder_iscsi_bind_addr = $::storage_address

if $auto_assign_floating_ip == 'true' {
  $bool_auto_assign_floating_ip = true
} else {
  $bool_auto_assign_floating_ip = false
}

$network_config = {
  'vlan_start'     => $vlan_start,
}

if $node[0]['role'] == 'primary-controller' {
  $primary_controller = true
} else {
  $primary_controller = false
}



$multi_host              = true
$manage_volumes          = false
$glance_backend          = 'swift'
$quantum_netnode_on_cnt  = true
$swift_loopback = false 
$mirror_type = 'external'
Exec { logoutput => true }

$swift_proxy_nodes = merge_arrays(filter_nodes($nodes_hash,'role','primary-swift-proxy'),filter_nodes($nodes,'role','swift-proxy'))
$swift_proxies = nodes_to_hash($swift_proxy_nodes,'name','storage_address')
$swift_storages = filter_nodes($nodes_hash, 'role', 'storage')

if $node[0]['role'] == 'primary-swift-proxy' {
  $primary_proxy = true
} else {
  $primary_proxy = false
}

$master_swift_proxy_nodes = filter_nodes($nodes_hash,'role','primary-swift-proxy')
$master_swift_proxy_ip = $master_swift_proxy_nodes[0]['internal_address']

