# Class ceilometer
#
#  ceilometer base package & configuration
#
# == parameters
#  [*metering_secret*]
#    secret key for signing messages. Mandatory.
#  [*package_ensure*]
#    ensure state for package. Optional. Defaults to 'present'
#  [*verbose*]
#    should the daemons log verbose messages. Optional. Defaults to 'False'
#  [*debug*]
#    should the daemons log debug messages. Optional. Defaults to 'False'
#  [*rabbit_host*]
#    ip or hostname of the rabbit server. Optional. Defaults to '127.0.0.1'
#  [*rabbit_port*]
#    port of the rabbit server. Optional. Defaults to 5672.
#  [*rabbit_hosts*]
#    array of host:port (used with HA queues). Optional. Defaults to undef.
#    If defined, will remove rabbit_host & rabbit_port parameters from config
#  [*rabbit_userid*]
#    user to connect to the rabbit server. Optional. Defaults to 'guest'
#  [*rabbit_password*]
#    password to connect to the rabbit_server. Optional. Defaults to empty.
#  [*rabbit_virtual_host*]
#    virtualhost to use. Optional. Defaults to '/'
#
class ceilometer(
  $metering_secret     = false,
  $package_ensure      = 'present',
  $verbose             = 'False',
  $debug               = 'False',
  $queue_provider      = 'rabbitmq',
  $rabbit_host         = '127.0.0.1',
  $rabbit_nodes        = false,
  $rabbit_port         = 5672,
  $rabbit_userid       = 'guest',
  $rabbit_password     = '',
  $rabbit_virtual_host = '/',
  $qpid_host           = '127.0.0.1',
  $qpid_nodes          = false,
  $qpid_port           = 5672,
  $qpid_userid         = 'nova',
  $qpid_password       = 'qpid_pw',
) {

  validate_string($metering_secret)

  include ceilometer::params

  File {
    require => Package['ceilometer-common'],
  }

  group { 'ceilometer':
    name    => 'ceilometer',
    require => Package['ceilometer-common'],
  }

  user { 'ceilometer':
    name    => 'ceilometer',
    gid     => 'ceilometer',
    groups  => ['nova'],
    system  => true,
    require => Package['ceilometer-common'],
  }

  file { '/etc/ceilometer/':
    ensure  => directory,
    owner   => 'ceilometer',
    group   => 'ceilometer',
    mode    => '0750',
  }

  file { '/etc/ceilometer/ceilometer.conf':
    owner   => 'ceilometer',
    group   => 'ceilometer',
    mode    => '0640',
  }

  package { 'ceilometer-common':
    ensure => $package_ensure,
    name   => $::ceilometer::params::common_package_name,
  }

  Package['ceilometer-common'] -> Ceilometer_config<||>

  # Configure RPC
  case $queue_provider {
    'rabbitmq': {
      ceilometer_config {
        'DEFAULT/rabbit_userid': value => $rabbit_userid;
        'DEFAULT/rabbit_password': value => $rabbit_password;
        'DEFAULT/rabbit_virtual_host': value => $rabbit_virtual_host;
        'DEFAULT/rpc_backend':
          value => 'ceilometer.openstack.common.rpc.impl_kombu';
      }
      if $rabbit_nodes {
        ceilometer_config {
          'DEFAULT/rabbit_ha_queues': value => true;
          'DEFAULT/rabbit_hosts':
            value => is_ip_address($rabbit_nodes) ? {
                       true  => "${rabbit_nodes}:${rabbit_port}",
                       false => join($rabbit_nodes, ','),
                     }
        }
      } else {
        ceilometer_config {
          'DEFAULT/rabbit_ha_queues': value => false;
          'DEFAULT/rabbit_host': value => $rabbit_host;
          'DEFAULT/rabbit_port': value => $rabbit_port;
          'DEFAULT/rabbit_hosts': value => "${rabbit_host}:${rabbit_port}"
        }
      }
    }

    'qpid': {
      ceilometer_config {
        'DEFAULT/qpid_username': value => $qpid_userid;
        'DEFAULT/qpid_password': value => $qpid_password;
        'DEFAULT/rpc_backend':
          value => 'ceilometer.openstack.common.rpc.impl_qpid';
      }
      if $qpid_nodes {
        ceilometer_config { 'DEFAULT/qpid_hosts':
          value => is_ip_address($qpid_nodes) ? {
                     true  => "${qpid_nodes}:${qpid_port}",
                     false => join($qpid_nodes, ','),
                   }
        }
      } else {
        ceilometer_config {
          'DEFAULT/qpid_hostname': value => $qpid_host;
          'DEFAULT/qpid_port': value => $qpid_port;
        }
      }
    }
  }

  ceilometer_config {
    'DEFAULT/metering_secret'        : value => $metering_secret;
    #(H) 'publisher_rpc/metering_secret'  : value => $metering_secret;
    'DEFAULT/debug'                  : value => $debug;
    'DEFAULT/verbose'                : value => $verbose;
    'DEFAULT/log_dir'                : value => $::ceilometer::params::log_dir;
    # Fix a bad default value in ceilometer.
    # Fixed in https: //review.openstack.org/#/c/18487/
    'DEFAULT/glance_control_exchange': value => 'glance';
    # Add glance-notifications topic.
    # Fixed in glance https://github.com/openstack/glance/commit/2e0734e077ae
    # Fix will be included in Grizzly
    'DEFAULT/notification_topics'    :
      value => 'notifications,glance_notifications';
  }

}
