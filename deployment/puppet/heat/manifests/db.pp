class heat::db (
  $sql_connection = 'mysql://heat:heat@localhost/heat'
) {

  notify {"Heat DB init ${heat_version_rh} ":}

  include heat::params

  Package<| title == 'heat-common' |> -> Class['heat::db']
  Class['heat::db::mysql']            -> Class['heat::db']
  Class['heat::cli']                  -> Class['heat::db']



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
      onlyif      => "test -f $::heat::params::db_sync_command",
      subscribe   => [Package['heat-engine'], Package['heat-api'],],
    }

# Lagacy part - support old rpms  before 2013.2.xx withour heat-manage tool
  exec { 'python -m heat.db.sync':
      command     => $::heat::params::legacy_db_sync_command,
      path        => '/usr/bin',
      user        => 'heat',
      refreshonly => true,
      logoutput   => on_failure,
      unless      => "test -f $::heat::params::db_sync_command",
      subscribe   => [Package['heat-engine'], Package['heat-api'],],
    }

}
