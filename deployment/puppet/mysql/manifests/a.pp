   service { 'mysqld_stopped':
      name     => 'mysql',
      ensure   => 'stopped',
      enable   => false,
      #require  => Package['mysql-server'],
      provider => 'redhat',
    }
