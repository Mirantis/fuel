# Class: rabbitmq::server
#
# This module manages the installation and config of the rabbitmq server
#   it has only been tested on certain version of debian-ish systems
# Parameters:
#  [*port*] - port where rabbitmq server is hosted
#  [*delete_guest_user*] - rather or not to delete the default user
#  [*version*] - version of rabbitmq-server to install
#  [*package_name*] - name of rabbitmq package
#  [*service_name*] - name of rabbitmq service
#  [*service_ensure*] - desired ensure state for service
#  [*stomp_port*] - port stomp should be listening on
#  [*node_ip_address*] - ip address for rabbitmq to bind to
#  [*config*] - contents of config file
#  [*env_config*] - contents of env-config file
# Requires:
#  stdlib
# Sample Usage:
#
#  
#
#
# [Remember: No empty lines between comments and class definition]
class rabbitmq::server(
  $port = '5672',
  $inet_dist_listen_min = '41055',
  $inet_dist_listen_max = '41055',
  $delete_guest_user = false,
  $package_name = 'rabbitmq-server',
  $version = 'UNSET',
  $service_name = 'rabbitmq-server',
  $service_ensure = 'running',
  $config_stomp = false,
  $stomp_port = '6163',
  $node_ip_address = 'UNSET', #getvar("::ipaddress_${::internal_interface}"),
  $config='UNSET',
  $config_cluster = false,
  $cluster_disk_nodes = [], 
  $env_config='UNSET'
) {

  validate_bool($delete_guest_user, $config_stomp)
  validate_re($port, '\d+')
  validate_re($stomp_port, '\d+')

  if $version == 'UNSET' {
    $version_real = '2.4.1'
    $pkg_ensure_real   = 'present'
  } else {
    $version_real = $version
    $pkg_ensure_real   = $version
  }
  if $config == 'UNSET' {
    $config_real = template("${module_name}/rabbitmq.config")
  } else {
    $config_real = $config
  }
  if $env_config == 'UNSET' {
    $env_config_real = template("${module_name}/rabbitmq-env.conf.erb")
  } else {
    $env_config_real = $env_config
  }

  $plugin_dir = "/usr/lib/rabbitmq/lib/rabbitmq_server-${version_real}/plugins"
  $erlang_cookie_content = 'EOKOWXQREETZSHFNTPEY'

  if $::osfamily == 'RedHat' {
    stdlib::safe_package {'qpid-cpp-server': ensure => 'purged' }
    Package['qpid-cpp-server'] -> Package[$package_name]
  }

  package { $package_name:
    ensure => $pkg_ensure_real,
    notify => Class['rabbitmq::service'],
  }

  file { '/etc/rabbitmq':
    ensure  => directory,
    owner   => '0',
    group   => '0',
    mode    => '0644',
    require => Package[$package_name],
  }

  file { 'rabbitmq.config':
    ensure  => file,
    path    => '/etc/rabbitmq/rabbitmq.config',
    content => $config_real,
    owner   => '0',
    group   => '0',
    mode    => '0644',
    notify  => Class['rabbitmq::service'],
    require => File['erlang_cookie']
  }

  file { 'rabbitmq-env.config':
    ensure  => file,
    path    => '/etc/rabbitmq/rabbitmq-env.conf',
    content => $env_config_real,
    owner   => '0',
    group   => '0',
    mode    => '0644',
    notify  => Class['rabbitmq::service'],
  }
  
  case $::osfamily {
    'RedHat' : {
  file { 'rabbitmq-server':
    ensure  => present,
    path    => '/etc/init.d/rabbitmq-server',
        source => 'puppet:///modules/rabbitmq/rabbitmq-server_redhat',
    replace => true,
    owner   => '0',
    group   => '0',
    mode    => '0755',
    #notify  => Class['rabbitmq::service'],
    require => Package[$package_name],
  }
    }
    'Debian' : {
      file { 'rabbitmq-server':
        ensure  => present,
        path    => '/etc/init.d/rabbitmq-server',
        source => 'puppet:///modules/rabbitmq/rabbitmq-server_ubuntu',
        replace => true,
        owner   => '0',
        group   => '0',
        mode    => '0755',
        #notify  => Class['rabbitmq::service'],
        require => Package[$package_name],
      }
    }
  }
  
  class { 'rabbitmq::service':
    service_name => $service_name,
    ensure       => $service_ensure,
  }

  exec { 'rabbitmq_stop':
    command => '/etc/init.d/rabbitmq-server stop; /bin/rm -rf /var/lib/rabbitmq/mnesia',
    require => Package[$package_name],
    unless  => "/bin/grep -qx ${erlang_cookie_content} /var/lib/rabbitmq/.erlang.cookie"
  }

  file { 'erlang_cookie':
    path =>"/var/lib/rabbitmq/.erlang.cookie",
    owner   => rabbitmq,
    group   => rabbitmq,
    mode    => '0400',
    content => $erlang_cookie_content,
    replace => true,
    #notify  => Class['rabbitmq::service'],
    require => Exec['rabbitmq_stop'],
  }

  if $delete_guest_user {
    # delete the default guest user
    rabbitmq_user{ 'guest':
      ensure   => absent,
      provider => 'rabbitmqctl',
    }
  }

}
