include booleans

if $quantum
{
  $quantum_hash   = parsejson($::quantum_access)
  $quantum_params = parsejson($::quantum_parameters)
  $novanetwork_params  = {}
  $floating_hash =  $::floating_network_range
}
else
{
  $quantum_hash = {}
  $quantum_params = {}
  $novanetwork_params  = parsejson($::novanetwork_parameters)
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
$nodes_hash           = parsejson($nodes)
$base_syslog_hash     = parsejson($::base_syslog)
$syslog_hash          = parsejson($::syslog)
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
$node = filter_nodes($nodes_hash,'name',$::hostname)
if empty($node) {
  fail("Node $::hostname is not defined in the hash structure")
}
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


##TODO: simply parse nodes array
$controllers = merge_arrays(filter_nodes($nodes_hash,'role','primary-controller'), filter_nodes($nodes_hash,'role','controller'))
$controller_internal_addresses = nodes_to_hash($controllers,'name','internal_address')
$controller_public_addresses = nodes_to_hash($controllers,'name','public_address')
$controller_storage_addresses = nodes_to_hash($controllers,'name','storage_address')
$controller_hostnames = keys($controller_internal_addresses)
$controller_nodes = sort(values($controller_internal_addresses))
$quantum_metadata_proxy_shared_secret = $quantum_params['metadata_proxy_shared_secret']
$quantum_gre_bind_addr = $::internal_address

$mountpoints = filter_hash($mp_hash,'point')


$network_config = {
  'vlan_start'     => $vlan_start,
}


$multi_host              = true
$manage_volumes          = false
$glance_backend          = 'swift'
$quantum_netnode_on_cnt  = true
$swift_loopback = false 
$mirror_type = 'external'
Exec { logoutput => true }

