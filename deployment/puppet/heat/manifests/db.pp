# Configures the heat database
# This class will install the required libraries depending on the driver
# specified in the connection_string parameter
#
# == Parameters
#  [*database_connection*]
#    the connection string. format: [driver]://[user]:[password]@[host]/[database]
#
class heat::db (
  $sql_connection = 'mysql://heat:heat@localhost/heat'
) {

  include heat::params

  Package<| title == 'heat-common' |> -> Class['heat::db']

  validate_re($sql_connection,
    '(mysql):\/\/(\S+:\S+@\S+\/\S+)?')

  case $sql_connection {
    /^mysql:\/\//: {
      $backend_package = false
      include mysql::python
    }
    default: {
      fail('Unsupported backend configured')
    }
  }

  if $backend_package and !defined(Package[$backend_package]) {
    package {'heat-backend-package':
      ensure => present,
      name   => $backend_package,
    }
  }

  heat_engine_config {
    'DEFAULT/sql_connection': value => $sql_connection;
  }

  exec { 'heat-manage db_sync':
      command     => $::heat::params::db_sync_command,
      path        => '/usr/bin',
      user        => 'heat',
      refreshonly => true,
      logoutput   => on_failure,
    }

}
