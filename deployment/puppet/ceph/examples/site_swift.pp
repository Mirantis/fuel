Exec { logoutput => true, path => ['/usr/bin', '/usr/sbin', '/sbin', '/bin'] }

stage {'openstack-custom-repo': before => Stage['main']}
$mirror_type="default"
class { 'openstack::mirantis_repos': stage => 'openstack-custom-repo', type=>$mirror_type }



#
# Example file for building out a multi-node environment
#
# This example creates nodes of the following roles:
#   swift_storage - nodes that host storage servers
#   swift_proxy - nodes that serve as a swift proxy
#   swift_ringbuilder - nodes that are responsible for
#     rebalancing the rings
#
# This example assumes a few things:
#   * the multi-node scenario requires a puppetmaster
#   * it assumes that networking is correctly configured
#
# These nodes need to be brought up in a certain order
#
# 1. storage nodes
# 2. ringbuilder
# 3. run the storage nodes again (to synchronize the ring db)
# 4. run the proxy
# 5. test that everything works!!
# this site manifest serves as an example of how to
# deploy various swift environments

$nodes_harr = [
  {
    'name' => 'swiftproxy-01',
    'role' => 'primary-swift-proxy',
    'internal_address' => '192.168.122.100',
    'public_address'   => '192.168.122.100',
  },
  {
    'name' => 'swift-01',
    'role' => 'storage',
    'internal_address' => '192.168.122.100',
    'public_address'   => '192.168.122.100',
    'swift_zone'       => 1,
    'mountpoints'=> "1 2\n 2 1",
    'storage_local_net_ip' => '192.168.122.100',
  },
  {
    'name' => 'swift-02',
    'role' => 'storage',
    'internal_address' => '192.168.122.101',
    'public_address'   => '192.168.122.101',
    'swift_zone'       => 2,
    'mountpoints'=> "1 2\n 2 1",
    'storage_local_net_ip' => '192.168.122.101',
  },
  {
    'name' => 'swift-03',
    'role' => 'storage',
    'internal_address' => '192.168.122.102',
    'public_address'   => '192.168.122.102',
    'swift_zone'       => 3,
    'mountpoints'=> "1 2\n 2 1",
    'storage_local_net_ip' => '192.168.122.102',
  }
]

$nodes = $nodes_harr
$internal_netmask = '255.255.255.0'
$public_netmask = '255.255.255.0'


$node = filter_nodes($nodes,'name',$::hostname)
if empty($node) {
  fail("Node $::hostname is not defined in the hash structure")
}
$internal_address = $node[0]['internal_address']
$public_address = $node[0]['public_address']

$swift_local_net_ip      = $internal_address

#if $node[0]['role'] == 'primary-swift-proxy' {
#  $primary_proxy = true
#} else {
#  $primary_proxy = false
#}
$master_swift_proxy_nodes = filter_nodes($nodes,'role','primary-swift-proxy')
$master_swift_proxy_ip = $master_swift_proxy_nodes[0]['internal_address']

$swift_proxy_nodes = merge_arrays(filter_nodes($nodes,'role','primary-swift-proxy'),filter_nodes($nodes,'role','swift-proxy'))
$swift_proxies = nodes_to_hash($swift_proxy_nodes,'name','internal_address')

$nv_physical_volume     = ['vdb','vdc'] 
$swift_loopback = false
$swift_user_password     = 'swift'

$verbose                = true
$admin_email          = 'dan@example_company.com'
$keystone_db_password = 'keystone'
$keystone_admin_token = 'keystone_token'
$admin_user           = 'admin'
$admin_password       = 'nova'


node keystone {
  # set up mysql server
#  class { 'mysql::server':
#    config_hash => {
#      # the priv grant fails on precise if I set a root password
#      # TODO I should make sure that this works
#      # 'root_password' => $mysql_root_password,
#      'bind_address'  => '0.0.0.0'
#    }
# }
  # set up all openstack databases, users, grants
#  class { 'keystone::db::mysql':
#    password => $keystone_db_password,
#}

  # in stall and configure the keystone service
  class { 'keystone':
    admin_token  => $keystone_admin_token,
    # we are binding keystone on all interfaces
    # the end user may want to be more restrictive
    bind_host    => '0.0.0.0',
    verbose  => $verbose,
    debug    => $verbose,
    catalog_type => 'sql',
  }

  # set up keystone database
  # set up the keystone config for mysql
  class { 'openstack::db::mysql':
    keystone_db_password => $keystone_db_password,
    nova_db_password => $keystone_db_password,
    mysql_root_password => $keystone_db_password,
    cinder_db_password => $keystone_db_password,
    glance_db_password => $keystone_db_password,
    quantum_db_password => $keystone_db_password,
  }
  # set up keystone admin users
  class { 'keystone::roles::admin':
    email    => $admin_email,
    password => $admin_password,
  }
  # configure the keystone service user and endpoint
  class { 'swift::keystone::auth':
    password => $swift_user_password,
    address  => "192.168.122.100",
  }
}

# The following specifies 3 swift storage nodes
node /swift-[\d+]/ {

  include stdlib
  class { 'operatingsystem::checksupported':
      stage => 'setup'
  }

  $swift_zone = $node[0]['swift_zone']

  class { 'openstack::swift::storage_node':
#    storage_type           => $swift_loopback,
    swift_zone             => $swift_zone,
    swift_local_net_ip     => $swift_local_net_ip,
    master_swift_proxy_ip  => $master_swift_proxy_ip,
#    nv_physical_volume     => $nv_physical_volume,
    storage_devices	   => $nv_physical_volume,
    storage_base_dir	   => '/dev/',
    db_host                => $internal_virtual_ip,
    service_endpoint       => $internal_virtual_ip,
    cinder		   => false
  }

}

node /swiftproxy-[\d+]/ inherits keystone {
  include stdlib
  class { 'operatingsystem::checksupported':
      stage => 'setup'
  }
   $primary_proxy = true
  if $primary_proxy {
    ring_devices {'all':
      storages => filter_nodes($nodes, 'role', 'storage')
    }
  }

  class { 'openstack::swift::proxy':
    swift_user_password     => $swift_user_password,
    swift_proxies           => $swift_proxies,
    primary_proxy           => $primary_proxy,
    controller_node_address => "192.168.122.100",
    swift_local_net_ip      => "192.168.122.100",
    master_swift_proxy_ip   => "192.168.122.100",
  }
}
