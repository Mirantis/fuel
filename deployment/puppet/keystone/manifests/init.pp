#
# Module for managing keystone config.
#
# == Parameters
#
#   [package_ensure] Desired ensure state of packages. Optional. Defaults to present.
#     accepts latest or specific versions.
#   [bind_host] Host that keystone binds to.
#   [bind_port] Port that keystone binds to.
#   [public_port]
#   [compute_port]
#   [admin_port]
#   [admin_port] Port that can be used for admin tasks.
#   [admin_token] Admin token that can be used to authenticate as a keystone
#     admin. Required.
#   [verbose] Rather keystone should log at verbose level. Optional.
#     Defaults to False.
#   [debug] Rather keystone should log at debug level. Optional.
#     Defaults to False.
#   [use_syslog] Rather or not keystone should log to syslog. Optional.
#     Defaults to False.
#   [catalog_type] Type of catalog that keystone uses to store endpoints,services. Optional.
#     Defaults to sql. (Also accepts template)
#   [token_format] Format keystone uses for tokens. Optional. Defaults to PKI.
#     Supports PKI and UUID.
#   [cache_dir] Directory created when token_format is PKI. Optional.
#     Defaults to /var/cache/keystone.
#   [enabled] If the keystone services should be enabled. Optioal. Default to true.
#   [sql_conneciton] Url used to connect to database.
#   [idle_timeout] Timeout when db connections should be reaped.
#
# == Dependencies
#  None
#
# == Examples
#
#   class { 'keystone':
#     log_verbose => 'True',
#     admin_token => 'my_special_token',
#   }
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2012 Puppetlabs Inc, unless otherwise noted.
#
class keystone(
  $admin_token,
  $package_ensure = 'present',
  $bind_host      = '0.0.0.0',
  $public_port    = '5000',
  $admin_port     = '35357',
  $compute_port   = '8774',
  $verbose        = false,
  $debug          = false,
  $use_syslog     = false,
  $catalog_type   = 'sql',
  $token_format   = 'PKI',
  $cache_dir      = '/var/cache/keystone',
  $enabled        = true,
  $sql_connection = 'sqlite:////var/lib/keystone/keystone.db',
  $idle_timeout   = '200'
) {

  validate_re($catalog_type,   'template|sql')
  validate_re($token_format,  'UUID|PKI')

  File['/etc/keystone/keystone.conf'] -> Keystone_config<||> ~> Service['keystone']
  Keystone_config<||> ~> Exec<| title == 'keystone-manage db_sync'|>
  Keystone_config<||> ~> Exec<| title == 'keystone-manage pki_setup'|>

  # TODO implement syslog features
  if ( $use_syslog != false) {
    fail('use syslog currently only accepts false')
  }

  include keystone::params

  File {
    ensure  => present,
    owner   => 'keystone',
    group   => 'keystone',
    require => Package['keystone'],
    notify  => Service['keystone'],
  }

  package { 'keystone':
    name   => $::keystone::params::package_name,
    ensure => $package_ensure,
  }

  group { 'keystone':
    ensure  => present,
    system  => true,
    require => Package['keystone'],
  }

  user { 'keystone':
    ensure  => 'present',
    gid     => 'keystone',
    system  => true,
    require => Package['keystone'],
  }

  file { ['/etc/keystone', '/var/log/keystone', '/var/lib/keystone']:
    ensure  => directory,
    mode    => '0750',
  }

  file { '/etc/keystone/keystone.conf':
    mode    => '0600',
  }

  # default config
  keystone_config {
    'DEFAULT/admin_token':  value => $admin_token;
    'DEFAULT/bind_host':    value => $bind_host;
    'DEFAULT/public_port':  value => $public_port;
    'DEFAULT/admin_port':   value => $admin_port;
    'DEFAULT/compute_port': value => $compute_port;
    'DEFAULT/verbose':      value => $verbose;
    'DEFAULT/debug':        value => $debug;
  }

  if($sql_connection =~ /mysql:\/\/\S+:\S+@\S+\/\S+/) {
    require 'mysql::python'
  } elsif($sql_connection =~ /postgresql:\/\/\S+:\S+@\S+\/\S+/) {

  } elsif($sql_connection =~ /sqlite:\/\//) {

  } else {
    fail("Invalid db connection ${sql_connection}")
  }

  # db connection config
  keystone_config {
    'sql/connection':   value => $sql_connection;
    'sql/idle_timeout': value => $idle_timeout;
  }

  # configure based on the catalog backend
  if($catalog_type == 'template') {
    keystone_config {
      'catalog/driver':
        value => 'keystone.catalog.backends.templated.TemplatedCatalog';
      'catalog/template_file':
        value => '/etc/keystone/default_catalog.templates';
    }
  } elsif($catalog_type == 'sql' ) {
    keystone_config { 'catalog/driver':
      value => ' keystone.catalog.backends.sql.Catalog'
    }
  }

  keystone_config { 'signing/token_format': value => $token_format }
  if($token_format  == 'PKI') {
    file { $cache_dir:
      ensure => directory,
    }
    exec { 'keystone-manage pki_setup':
      path        => '/usr/bin',
      user        => 'keystone',
      refreshonly => true,
      creates     => '/etc/keystone/ssl/private/signing_key.pem',
      notify      => Service['keystone'],
      subscribe   => Package['keystone'],
      require     => User['keystone'],
    }
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  service { 'keystone':
    name       => $::keystone::params::service_name,
    ensure     => $service_ensure,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    provider   => $::keystone::params::service_provider,
  }

  if $enabled {
    # this probably needs to happen more often than just when the db is
    # created
    exec { 'keystone-manage db_sync':
      path        => '/usr/bin',
      user        => 'keystone',
      refreshonly => true,
      notify      => Service['keystone'],
      subscribe   => Package['keystone'],
      require     => User['keystone'],
    }
  }
}
