# Class: mysql::server
#
# manages the installation of the mysql server.  manages the package, service,
# my.cnf
#
# Parameters:
#   [*package_name*] - name of package
#   [*service_name*] - name of service
#   [*config_hash*]  - hash of config parameters that need to be set.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::server (
  $custom_setup_class = undef,
  $package_name     = $mysql::params::server_package_name,
  $package_ensure   = 'present',
  $service_name     = $mysql::params::service_name,
  $service_provider = $mysql::params::service_provider,
  $config_hash      = {},
  $enabled          = true,
  $galera_cluster_name = undef,
  $primary_controller = primary_controller,
  $galera_node_address = undef,
  $galera_nodes = undef,
  $mysql_skip_name_resolve = false,
  $use_syslog              = false,
  $server_id         = $mysql::params::server_id,
  $replication_roles = "SELECT, PROCESS, FILE, SUPER, REPLICATION CLIENT, REPLICATION SLAVE, RELOAD",
  $rep_user = 'replicator',
  $rep_pass = 'replicant666',
) inherits mysql::params {
    
  if ($custom_setup_class == undef) {
    include mysql
    Class['mysql::server'] -> Class['mysql::config']
    Class['mysql']         -> Class['mysql::server']

    create_resources( 'class', { 'mysql::config' => $config_hash })
#    exec { "debug-mysql-server-installation" :
#      command     => "/usr/bin/yum -d 10 -e 10 -y install MySQL-server-5.5.28-6 2>&1 | tee mysql_install.log",
#      before => Package["mysql-server"],
#      logoutput => true,
#    }
    if !defined(Package[mysql-client]) {
      package { 'mysql-client':
        name   => $package_name,
       #ensure => $mysql::params::client_version,
      }
    }
    package { 'mysql-server':
      name   => $package_name,
     #ensure => $mysql::params::server_version,
     #require=> Package['mysql-shared'],
    }
    Package[mysql-client] -> Package[mysql-server]
 
    service { 'mysqld':
      name     => $service_name,
      ensure   => $enabled ? { true => 'running', default => 'stopped' },
      enable   => $enabled,
      require  => Package['mysql-server'],
      provider => $service_provider,
    }
  }
  elsif ($custom_setup_class == 'pacemaker_mysql')  {
    include mysql
    Package[mysql-server] -> Class['mysql::config']
    Package[mysql-client] -> Package[mysql-server]
    Cs_commit['mysql']    -> Service['mysqld']
    Cs_property <||> -> Cs_shadow <||>
    Cs_shadow['mysql']    -> Service['mysqld']
    Cs_commit <| title == 'internal-vip' |> -> Cs_shadow['mysql']

    $config_hash['custom_setup_class'] = $custom_setup_class
    $allowed_hosts = '%'
    #$allowed_hosts = 'localhost'



    create_resources( 'class', { 'mysql::config' => $config_hash })
    Class['mysql::config'] -> Cs_resource['p_mysql']

    if !defined(Package[mysql-client]) {
      package { 'mysql-client':
        name   => $package_name,
      }
    }

    package { 'mysql-server':
      name   => $package_name,
    }

 
    Class['openstack::corosync'] -> Cs_resource['p_mysql']

#    #cs_rsc_defaults { "resource-stickiness":
#    #  ensure => present,
#    #  value  => '110',
#    #}->
#    cs_commit { 'mysqlvip' : cib => "mysqlvip" } ->

  file { "/tmp/repl_create.sql" :
    ensure  => present,
    content => template("mysql/repl_create.sql.erb"),
  } ->

    cs_shadow { 'mysql': cib => 'mysql' } ->
    cs_resource { "p_mysql":
      ensure          => present,
      primitive_class => 'ocf',
      provided_by     => 'heartbeat',
      primitive_type  => 'mysql',
      cib             => 'mysql',
      multistate_hash => {'type'=>'master'},
      ms_metadata     => {'notify'=>"true"},
      parameters      => {
        'binary' => "/usr/bin/mysqld_safe",
        'test_table'         => 'mysql.user',
        'replication_user'   => $rep_user,
        'replication_passwd' => $rep_pass,
        'additional_parameters' => '"--init-file=/tmp/repl_create.sql"',
      },
      operations   => {
        'monitor'  => { 'interval' => '20', 'timeout'  => '30' },
        'start'    => { 'timeout' => '360' },
        'stop'     => { 'timeout' => '360' },
        'promote'  => { 'timeout' => '360' },
        'demote'   => { 'timeout' => '360' },
        'notify'   => { 'timeout' => '360' },
      }
    }->


    cs_commit { 'mysql': cib => 'mysql' } ->

    service { 'mysqld':
      name     => "p_${service_name}",
      ensure   => 'running',
      enable   => true,
      require  => [Package['mysql-server'], Cs_commit['mysql']],
      provider => 'pacemaker',
    }

    #Tie internal-vip to p_mysql
    cs_colocation { 'mysql_to_internal-vip': 
      primitives => ['internal-vip','master_p_mysql:Master'],
      score      => 'INFINITY',
      require    => [Cs_resource['p_mysql'], Cs_commit['mysql']],
    } 

  }
  elsif ($custom_setup_class == 'galera')  {
    Class['galera'] -> Class['mysql::server']
    class { 'galera':
      cluster_name       => $galera_cluster_name,
      primary_controller => $primary_controller,
      node_address       => $galera_node_address,
      node_addresses     => $galera_nodes,
      skip_name_resolve  => $mysql_skip_name_resolve,
      use_syslog         => $use_syslog,
    }
#    require($galera_class)
  }
  
   else {
    require($custom_setup_class)
  }
}

