#
# == Class: openstack::ceilometer
#
# Installs and configures Ceilometer
#

class openstack::ceilometer (
  $rabbit_password,
  $keystone_password   = 'ceilometer_pass',
  $metering_secret     = 'ceilometer',
  $verbose             = 'False',
  $debug               = 'False',
  $db_type             = 'mysql',
  $db_host             = 'localhost',
  $db_user             = 'ceilometer',
  $db_password         = 'ceilometer_pass',
  $db_dbname           = 'ceilometer',
  $queue_provider      = 'rabbitmq',
  $rabbit_host         = '127.0.0.1',
  $rabbit_nodes        = false,
  $rabbit_port         = 5672,
  $rabbit_userid       = 'guest',
  $rabbit_ha_virtual_ip   = false,
  $qpid_host           = '127.0.0.1',
  $qpid_nodes          = false,
  $qpid_port           = 5672,
  $qpid_userid         = 'guest',
  $qpid_password       = 'qpid_pw',
  $keystone_host       = '127.0.0.1',
  $on_controller       = false,
  $on_compute          = false,
) {

  # Add the base ceilometer class & parameters
  # This class is required by ceilometer agents & api classes
  # The metering_secret parameter is mandatory
  class { '::ceilometer':
    package_ensure  => $::openstack_version['ceilometer'],
    queue_provider  => $queue_provider,
    rabbit_host     => $rabbit_host,
    rabbit_nodes    => $rabbit_nodes,
    rabbit_port     => $rabbit_port,
    rabbit_userid   => $rabbit_userid,
    rabbit_password => $rabbit_password,
    qpid_host       => $qpid_host,
    qpid_nodes      => $qpid_nodes,
    qpid_port       => $qpid_port,
    qpid_userid     => $qpid_userid,
    qpid_password   => $qpid_password,
    metering_secret => $metering_secret,
    verbose         => $verbose,
    debug           => $debug,
  }

  class { '::ceilometer::client': }

  if ($on_controller) {
    # Configure the ceilometer database
    # Only needed if ceilometer::agent::central or ceilometer::api are declared
    class { '::ceilometer::db':
      database_connection => "${db_type}://${db_user}:${db_password}@${db_host}/${db_dbname}",
    }

    # Install the ceilometer-api service
    # The keystone_password parameter is mandatory
    class { '::ceilometer::api':
      keystone_host     => $keystone_host,
      keystone_password => $keystone_password,
    }

    class { '::ceilometer::collector': }

    class { '::ceilometer::agent::central':
      auth_host     => $keystone_host,
      auth_password => $keystone_password,
    }
  }

  if ($on_compute) {
    # Install compute agent
    class { 'ceilometer::agent::compute':
      auth_host     => $keystone_host,
      auth_password => $keystone_password,
    }
  }
}
