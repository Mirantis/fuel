# Class savanna
#
#  savanna base package & configuration
#
class savanna(
  $package_ensure     = 'present',
  $verbose            = 'False',
  $debug              = 'False',
  $rabbit_host        = '127.0.0.1',
  $rabbit_port        = 5672,
  $rabbit_hosts       = undef,
  $rabbit_userid      = 'guest',
  $rabbit_password    = '',
  $rabbit_virtualhost = '/',
) {

  include savanna::params

  File {
    require => Package['savanna-common'],
  }

  group { 'savanna':
    name    => 'savanna',
    require => Package['savanna-common'],
  }

  user { 'savanna':
    name    => 'savanna',
    gid     => 'savanna',
    groups  => ['savanna'],
    system  => true,
    require => Package['savanna-common'],
  }

  file { '/etc/savanna/':
    ensure  => directory,
    owner   => 'savanna',
    group   => 'savanna',
    mode    => '0750',
  }

  package { 'savanna-common':
    ensure => $package_ensure,
    name   => $::savanna::params::common_package_name,
  }

#  Package['savanna-common'] -> savanna_config<||>

}
