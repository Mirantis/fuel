class osnailyfacter::cluster_ha {


##PARAMETERS DERIVED FROM YAML FILE


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
   $cinder_nodes_array   = parsejson($::cinder_nodes)
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
$floating_ips_range   = parsejson($::floating_network_range)
$network_manager      = "nova.network.manager.${novanetwork_params['network_manager']}"
$network_size         = $novanetwork_params['network_size']
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
else {
  $floating_hash = parsejson($::floating_network_range)
}

##CALCULATED PARAMETERS


##NO NEED TO CHANGE

$node = filter_nodes($nodes_hash,'name',$::hostname)
if empty($node) {
  fail("Node $::hostname is not defined in the hash structure")
}

$vips = { # Do not convert to ARRAY, It can't work in 2.7
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
$controller_nodes = values($controller_internal_addresses)
$controller_node_public  = $management_vip
$swift_proxies = $controller_internal_addresses
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


if !$verbose 
{
 $verbose = 'true'
}

if !$debug
{
 $debug = 'true'
}


if $node[0]['role'] == 'primary-controller' {
  $primary_proxy = true
} else {
  $primary_proxy = false
}
if $node[0]['role'] == 'primary-controller' {
  $primary_controller = true
} else {
  $primary_controller = false
}
$master_swift_proxy_nodes = filter_nodes($nodes_hash,'role','primary-controller')
$master_swift_proxy_ip = $master_swift_proxy_nodes[0]['internal_address']
#$master_hostname = $master_swift_proxy_nodes[0]['name']

#HARDCODED PARAMETERS

$multi_host              = true
$manage_volumes          = false
$glance_backend          = 'swift'
$quantum_netnode_on_cnt  = true
$swift_loopback = 'loopback'
$mirror_type = 'external'
Exec { logoutput => true }




class compact_controller (
  $quantum_network_node = $quantum_netnode_on_cnt
) {

  class { 'openstack::controller_ha':
    controller_public_addresses   => $controller_public_addresses,
    controller_internal_addresses => $controller_internal_addresses,
    internal_address              => $internal_address,
    public_interface              => $::public_int,
    internal_interface            => $::internal_int,
    private_interface             => $fixed_interface,
    internal_virtual_ip           => $management_vip,
    public_virtual_ip             => $public_vip,
    primary_controller            => $primary_controller,
    floating_range                => $quantum ? { 'true' =>$floating_hash, default=>false},
    fixed_range                   => $fixed_network_range,
    multi_host                    => $multi_host,
    network_manager               => $network_manager,
    num_networks                  => $num_networks,
    network_size                  => $network_size,
    network_config                => $network_config,
    verbose                       => $verbose,
    debug                         => $debug,
    queue_provider                => $::queue_provider,
    qpid_password                 => $rabbit_hash[password],
    qpid_user                     => $rabbit_hash[user],
    qpid_nodes                    => [$management_vip],
    auto_assign_floating_ip       => $bool_auto_assign_floating_ip,
    mysql_root_password           => $mysql_hash[root_password],
    admin_email                   => $access_hash[email],
    admin_user                    => $access_hash[user],
    admin_password                => $access_hash[password],
    keystone_db_password          => $keystone_hash[db_password],
    keystone_admin_token          => $keystone_hash[admin_token],
    keystone_admin_tenant         => $access_hash[tenant],
    glance_db_password            => $glance_hash[db_password],
    glance_user_password          => $glance_hash[user_password],
    nova_db_password              => $nova_hash[db_password],
    nova_user_password            => $nova_hash[user_password],
    rabbit_password               => $rabbit_hash[password],
    rabbit_user                   => $rabbit_hash[user],
    rabbit_nodes                  => $controller_nodes,
    memcached_servers             => $controller_nodes,
    export_resources              => false,
    glance_backend                => $glance_backend,
    swift_proxies                 => $controller_internal_addresses,
    quantum                       => $quantum,
    quantum_user_password         => $quantum_hash[user_password],
    quantum_db_password           => $quantum_hash[db_password],
    quantum_network_node          => $quantum_network_node,
    quantum_netnode_on_cnt        => $quantum_netnode_on_cnt,
    quantum_gre_bind_addr         => $quantum_gre_bind_addr,
    quantum_external_ipinfo       => $external_ipinfo,
    tenant_network_type           => $tenant_network_type,
    segment_range                 => $segment_range,
    cinder                        => true,
    cinder_user_password          => $cinder_hash[user_password],
    cinder_iscsi_bind_addr        => $cinder_iscsi_bind_addr,
    cinder_db_password            => $cinder_hash[db_password],
    manage_volumes                => false,
    galera_nodes                  => $controller_nodes,
    custom_mysql_setup_class => $custom_mysql_setup_class,
    mysql_skip_name_resolve       => true,
    use_syslog                    => true,
    syslog_log_level              => $syslog_log_level,
    syslog_log_facility_glance   => $syslog_log_facility_glance,
    syslog_log_facility_cinder => $syslog_log_facility_cinder,
    syslog_log_facility_quantum => $syslog_log_facility_quantum,
    syslog_log_facility_nova => $syslog_log_facility_nova,
    syslog_log_facility_keystone => $syslog_log_facility_keystone,
    nova_rate_limits        => $nova_rate_limits,
    cinder_rate_limits      => $cinder_rate_limits,
    horizon_use_ssl         => $::horizon_use_ssl,
    use_unicast_corosync    => $::use_unicast_corosync,
  }

#  class { "::rsyslog::client":
#    log_local => true,
#    log_auth_local => true,
#    rservers => $rservers,
#  }

  class { 'swift::keystone::auth':
     password         => $swift_hash[user_password],
     public_address   => $public_vip,
     internal_address => $management_vip,
     admin_address    => $management_vip,
  }
}

class virtual_ips () {
  cluster::virtual_ips { $vip_keys:
    vips => $vips,
  }
}



  case $role {
    /controller/ : {
      include osnailyfacter::test_controller

 $swift_zone = $node[0]['swift_zone']

  class { '::cluster': stage => 'corosync_setup' } ->
  class { 'virtual_ips':
    stage => 'corosync_setup'
  }
  include ::haproxy::params
  class { 'cluster::haproxy':
    global_options   => merge($::haproxy::params::global_options, {'log' => "/dev/log local0"}),
    defaults_options => merge($::haproxy::params::defaults_options, {'mode' => 'http'}),
    stage => 'cluster_head',
  }

      class { compact_controller: }
      class { 'openstack::swift::storage_node':
        storage_type          => 'loopback',
        loopback_size         => '5243780',
        swift_zone            => $swift_zone,
        swift_local_net_ip    => $storage_address,
        master_swift_proxy_ip   => $master_swift_proxy_ip,
        sync_rings            => ! $primary_proxy
      }
      if $primary_proxy {
        ring_devices {'all':
          storages => $controllers
      }
      class { 'openstack::swift::proxy':
        swift_user_password     => $swift_hash[user_password],
        swift_proxies           => $controller_internal_addresses,
        primary_proxy           => $primary_proxy,
        controller_node_address => $management_vip,
        swift_local_net_ip      => $swift_local_net_ip,
        master_swift_proxy_ip   => $master_swift_proxy_ip
      }
      #TODO: PUT this configuration stanza into nova class
      nova_config { 'DEFAULT/start_guests_on_host_boot': value => $start_guests_on_host_boot }
      nova_config { 'DEFAULT/use_cow_images': value => $use_cow_images }
      nova_config { 'DEFAULT/compute_scheduler_driver': value => $compute_scheduler_driver }

      if $primary_controller {
        class { 'openstack::img::cirros':
          os_username => shellescape($access_hash[user]),
          os_password => shellescape($access_hash[password]),
          os_tenant_name => shellescape($access_hash[tenant]),
          os_auth_url => "http://${management_vip}:5000/v2.0/",
          img_name    => "TestVM",
          stage          => 'glance-image',
        }
        if !$quantum
        {
          nova_floating_range{ $floating_ips_range:
            ensure          => 'present',
            pool            => 'nova',
            username        => $access_hash[user],
            api_key         => $access_hash[password],
            auth_method     => 'password',
            auth_url        => "http://${management_vip}:5000/v2.0/",
            authtenant_name => $access_hash[tenant],
          }
        }
        Class[glance::api]                    -> Class[openstack::img::cirros]
        Class[openstack::swift::storage_node] -> Class[openstack::img::cirros]
        Class[openstack::swift::proxy]        -> Class[openstack::img::cirros]
        Service[swift-proxy]                  -> Class[openstack::img::cirros]
      }
    }
   }

    "compute" : {
      include osnailyfacter::test_compute

      class { 'openstack::compute':
        public_interface       => $public_int,
        private_interface      => $fixed_interface,
        internal_address       => $internal_address,
        libvirt_type           => $libvirt_type,
        fixed_range            => $fixed_network_range,
        network_manager        => $network_manager,
        network_config         => $network_config,
        multi_host             => $multi_host,
        sql_connection         => "mysql://nova:${nova_hash[db_password]}@${management_vip}/nova",
        rabbit_nodes           => $controller_nodes,
        rabbit_password        => $rabbit_hash[password],
        rabbit_user            => $rabbit_hash[user],
        rabbit_ha_virtual_ip   => $management_vip,
        auto_assign_floating_ip => $bool_auto_assign_floating_ip,
        glance_api_servers     => "${management_vip}:9292",
        vncproxy_host          => $public_vip,
        verbose                => $verbose,
        debug                  => $debug,
        vnc_enabled            => true,
        manage_volumes         => $cinder ? { false => $manage_volumes, default =>$is_cinder_node },
        nova_user_password     => $nova_hash[user_password],
        cache_server_ip        => $controller_nodes,
        service_endpoint       => $management_vip,
        cinder                 => true,
        cinder_iscsi_bind_addr => $cinder_iscsi_bind_addr,
        cinder_user_password   => $cinder_hash[user_password],
        cinder_db_password     => $cinder_hash[db_password],
        db_host                => $management_vip,
        quantum                => $quantum,
        quantum_host           => $quantum_host,
        quantum_sql_connection => $quantum_sql_connection,
        quantum_user_password  => $quantum_hash[user_password],
        tenant_network_type    => $tenant_network_type,
        segment_range          => $segment_range,
        use_syslog             => true,
        syslog_log_level       => $syslog_log_level,
        syslog_log_facility_quantum => $syslog_log_facility_quantum,
        syslog_log_facility_cinder => $syslog_log_facility_cinder,
        nova_rate_limits       => $nova_rate_limits,
        state_path             => $nova_hash[state_path],
      }

#      class { "::rsyslog::client":
#        log_local => true,
#        log_auth_local => true,
#        rservers => $rservers,
#      }
      #TODO: PUT this configuration stanza into nova class
      nova_config { 'DEFAULT/start_guests_on_host_boot': value => $start_guests_on_host_boot }
      nova_config { 'DEFAULT/use_cow_images': value => $use_cow_images }
      nova_config { 'DEFAULT/compute_scheduler_driver': value => $compute_scheduler_driver }
    }

    "cinder" : {
      include keystone::python
      package { 'python-amqp':
        ensure => present
      }
      class { 'openstack::cinder':
        sql_connection       => "mysql://cinder:${cinder_hash[db_password]}@${management_vip}/cinder?charset=utf8",
        glance_api_servers   => "${management_vip}:9292",
        rabbit_password      => $rabbit_hash[password],
        rabbit_host          => false,
        rabbit_nodes         => $management_vip,
        volume_group         => 'cinder',
        manage_volumes       => true,
        enabled              => true,
        auth_host            => $management_vip,
        iscsi_bind_host      => $storage_address,
        cinder_user_password => $cinder_hash[user_password],
        syslog_log_facility  => $syslog_log_facility_cinder,
        syslog_log_level     => $syslog_log_level,
        debug                => $debug ? { 'true' => 'True', default=>'False' },
        verbose              => $verbose ? { 'false' => 'False', default=>'True' },
        use_syslog           => true,
      }
#      class { "::rsyslog::client":
#        log_local => true,
#        log_auth_local => true,
#        rservers => $rservers,
#      }
    }
  }
}
