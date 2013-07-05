# Class: mysql::server
#
# manages the installation of the mysql server.  manages the package, service,
# my.cnf
#
# Parameters:
#   [*package_name*] - name of package
#   [*service_name*] - name of service
#   [*config_hash*]  - hash of config parameters that need to be set.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::server (
  $custom_setup_class = undef,
  $package_name     = $mysql::params::server_package_name,
  $package_ensure   = 'present',
  $service_name     = $mysql::params::service_name,
  $service_provider = $mysql::params::service_provider,
  $config_hash      = {},
  $enabled          = true,
  $galera_cluster_name = undef,
  $primary_controller = primary_controller,
  $galera_node_address = undef,
  $galera_nodes = undef,
  $mysql_skip_name_resolve = false,
  $use_syslog              = false,
  $manage_service   = true,
  $galera_cluster_name = undef,
  $primary_controller = primary_controller,
  $galera_node_address = undef,
  $galera_nodes = undef,
  $mysql_skip_name_resolve = false,
) inherits mysql::params {

  if ($custom_setup_class == undef) {
    include mysql
  Class['mysql::server'] -> Class['mysql::config']
    Class['mysql']         -> Class['mysql::server']

  $config_class = { 'mysql::config' => $config_hash }

  create_resources( 'class', $config_class )
#    exec { "debug-mysql-server-installation" :
#      command     => "/usr/bin/yum -d 10 -e 10 -y install MySQL-server-5.5.28-6 2>&1 | tee mysql_install.log",
#      before => Package["mysql-server"],
#      logoutput => true,
#    }
    if !defined(Package[mysql-client]) {
      package { 'mysql-client':
        name   => $package_name,
       #ensure => $mysql::params::client_version,
      }
    }
  package { 'mysql-server':
    #ensure => $package_ensure,
    name   => $package_name,
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }
    Package[mysql-client] -> Package[mysql-server]

  if $manage_service {
    service { 'mysqld':
      ensure   => $service_ensure,
      name     => $service_name,
      enable   => $enabled,
      require  => Package['mysql-server'],
      provider => $service_provider,
    }
  }
  elsif ($custom_setup_class == 'galera')  {
    Class['galera'] -> Class['mysql::server']
    class { 'galera':
      cluster_name       => $galera_cluster_name,
      primary_controller => $primary_controller,
      node_address       => $galera_node_address,
      node_addresses     => $galera_nodes,
      skip_name_resolve  => $mysql_skip_name_resolve,
      use_syslog         => $use_syslog,
    }
#    require($galera_class)
  }
  
   else {
    require($custom_setup_class)
  }
}
