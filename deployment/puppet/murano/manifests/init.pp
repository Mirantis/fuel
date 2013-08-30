# Class murano
#
#  murano base package & configuration
#
class murano(
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

  include murano::params

  File {
    require => Package['murano-common'],
  }

  group { 'murano':
    name    => 'murano',
  }

  user { 'murano':
    name    => 'murano',
    gid     => 'murano',
    groups  => ['murano'],
    system  => true,
  }

  file { '/etc/murano/':
    ensure  => directory,
    owner   => 'murano',
    group   => 'murano',
    mode    => '0750',
  }
}
