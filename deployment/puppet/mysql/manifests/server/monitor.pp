class mysql::server::monitor (
  $mysql_monitor_username,
  $mysql_monitor_password,
  $mysql_monitor_hostname,
  $connection_host = false,
  $connection_port = false,
  $connection_user = false,
  $connection_pass = false,
) {

  Class['mysql::server'] -> Class['mysql::server::monitor']

  database_user{ "${mysql_monitor_username}@${mysql_monitor_hostname}":
    connection_host => $connection_host,
    connection_port => $connection_port,
    connection_user => $connection_user,
    connection_pass => $connection_pass,
    password_hash   => mysql_password($mysql_monitor_password),
    ensure          => present,
  }

  database_grant { "${mysql_monitor_username}@${mysql_monitor_hostname}":
    connection_host => $connection_host,
    connection_port => $connection_port,
    connection_user => $connection_user,
    connection_pass => $connection_pass,
    privileges      => [ 'process_priv', 'super_priv' ],
    require         => Mysql_user["${mysql_monitor_username}@${mysql_monitor_hostname}"],
  }

}
