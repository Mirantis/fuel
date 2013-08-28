define mysql::db_new (
  $user,
  $password,
  $charset     = 'utf8',
  $host        = 'localhost',
  $grant       = 'all',
  $sql         = '',
  $enforce_sql = false,
  $ensure      = 'present'
) {
  #input validation
  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")

  package { 'mysql_client':
    name   => 'MySQL-client',
    ensure => 'present',
  }


  database { $name:
    ensure   => $ensure,
    charset  => $charset,
    provider => 'mysql',
    require  => Package['mysql_client'],
    before   => Database_user["${user}@${host}"],
  }

  $user_resource = {
    ensure        => $ensure,
    password_hash => mysql_password($password),
    provider      => 'mysql'
  }
  ensure_resource('database_user', "${user}@${host}", $user_resource)

  if $ensure == 'present' {
    database_grant { "${user}@${host}/${name}":
      privileges => $grant,
      provider   => 'mysql',
      require    => Database_user["${user}@${host}"],
    }

    $refresh = ! $enforce_sql

    if $sql {
      exec{ "${name}-import":
        command     => "/usr/bin/mysql ${name} < ${sql}",
        logoutput   => true,
        environment => "HOME=${root_home}",
        refreshonly => $refresh,
        require     => Database_grant["${user}@${host}/${name}"],
        subscribe   => Database[$name],
      }
    }
  }
}
