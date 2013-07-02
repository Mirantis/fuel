class { 'mysql::server':
  config_hash => {
    'root_password' => 'password',
  }
}

database_grant{'test1@localhost/redmine':
  privileges => [update],
  require    => Class['mysql::server'],
}
