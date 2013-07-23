#
class nova::metadata_api (
  $enabled           = true,
  $ensure_package    = 'present',
  $auth_strategy     = 'keystone',
  $admin_auth_url    = 'http://127.0.0.1:35357/v2.0',
  $admin_tenant_name = 'services',
  $admin_user        = 'nova',
  $auth_password     = 'quantum_pass',
  $service_endpoint  = '127.0.0.1',
  $listen_ip         = '0.0.0.0',
  $controller_nodes  = ['127.0.0.1'],
  $rpc_backend       = 'nova.rpc.impl_kombu',
  $queue_provider    = 'rabbitmq',
  $rabbit_user       = 'rabbit_user',
  $rabbit_password   = 'rabbit_password',
  $rabbit_ha_virtual_ip= false,
  $qpid_user         = 'nova',
  $qpid_password     = 'qpid_pw',
  $qpid_node        = false,
  $quantum_netnode_on_cnt= false,
) {

  include nova::params

  nova::generic_service { 'metadata-api':
     enabled        => true,
     package_name   => "$::nova::params::meta_api_package_name",
     service_name   => "$::nova::params::meta_api_service_name",
  }

  Package["$::nova::params::meta_api_package_name"] -> 
    Nova_config<||> ~> 
      Service["$::nova::params::meta_api_service_name"]

}
