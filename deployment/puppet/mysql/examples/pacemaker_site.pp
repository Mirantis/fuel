node 'mysqlcent3' {
  class {'mysql::server':
    galera_node_address => '192.168.122.89',
    custom_setup_class  => 'pacemaker_mysql'
  }
}
node 'mysqlcent4' {
  class {'mysql::server':
    galera_node_address => '192.168.122.8',
    custom_setup_class  => 'pacemaker_mysql'
  }
}

