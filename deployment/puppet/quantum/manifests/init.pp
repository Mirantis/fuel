#
# [use_syslog] Rather or not service should log to syslog. Optional.
# [syslog_log_facility] Facility for syslog, if used. Optional.
# [syslog_log_level] logging level for non verbose and non debug mode. Optional.
#
class quantum (
  $rabbit_password,
  $auth_password,
  $enabled                = true,
  $package_ensure         = 'present',
  $verbose                = 'False',
  $debug                  = 'False',
  $bind_host              = '0.0.0.0',
  $bind_port              = '9696',
  $core_plugin            = 'quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2',
  $auth_strategy          = 'keystone',
  $base_mac               = 'fa:16:3e:00:00:00',
  $mac_generation_retries = 16,
  $dhcp_lease_duration    = 120,
  $allow_bulk             = 'True',
  $allow_overlapping_ips  = 'False',
  $rpc_backend            = 'quantum.openstack.common.rpc.impl_kombu',
  $control_exchange       = 'quantum',
  $queue_provider         = 'rabbitmq',
  $rabbit_host            = 'localhost',
  $rabbit_port            = '5672',
  $rabbit_user            = 'guest',
  $rabbit_virtual_host    = '/',
  $rabbit_ha_virtual_ip   = false,
  $qpid_user              = 'guest',
  $qpid_port              = '5672',
  $qpid_password          = 'guest',
  $qpid_host              = 'localhost',
  $server_ha_mode         = false,
  $auth_type        = 'keystone',
  $auth_host        = 'localhost',
  $auth_port        = '35357',
  $auth_tenant      = 'services',
  $auth_user        = 'quantum',
  $log_file               = '/var/log/quantum/server.log',
  $log_dir          = '/var/log/quantum',
  $use_syslog = false,
  $syslog_log_facility    = 'LOCAL4',
  $syslog_log_level = 'WARNING',
  $network_auto_schedule  = true,
  $router_auto_schedule   = true,
  $agent_down_time        = 15,
) {
  include 'quantum::params'

  anchor {'quantum-init':}

  if ! defined(File['/etc/quantum']) {
    file {'/etc/quantum':
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => 755,
      #require => Package['quantum']
    }
  }

  package {'quantum':
    name   => $::quantum::params::package_name,
    ensure => $package_ensure
  }

  file {'q-agent-cleanup.py':
    path   => '/usr/bin/q-agent-cleanup.py',
    mode   => 755,
    owner  => root,
    group  => root,
    source => "puppet:///modules/quantum/q-agent-cleanup.py",
  } 

  file {'quantum-root':
    path => '/etc/sudoers.d/quantum-root',
    mode => 600,
    owner => root,
    group => root,
    source => "puppet:///modules/quantum/quantum-root",
    before => Package['quantum'],
  }

  file {'/var/cache/quantum':
    ensure  => directory,
    path   => '/var/cache/quantum',
    mode   => 755,
    owner  => quantum,
    group  => quantum,
  }
  case $queue_provider {
    'rabbitmq': {
      if is_array($rabbit_host) and size($rabbit_host) > 1 {
        if $rabbit_ha_virtual_ip {
          $rabbit_hosts = "${rabbit_ha_virtual_ip}:${rabbit_port}"
        } else {
          $rabbit_hosts = inline_template("<%= @rabbit_host.map {|x| x + ':' + @rabbit_port}.join ',' %>")
        }
        #Quantum_config['DEFAULT/rabbit_ha_queues'] -> Service<| title == 'quantum-server' |>
        #Quantum_config['DEFAULT/rabbit_ha_queues'] -> Service<| title == 'quantum-plugin-ovs-service' |>
        #Quantum_config['DEFAULT/rabbit_ha_queues'] -> Service<| title == 'quantum-l3' |>
        #Quantum_config['DEFAULT/rabbit_ha_queues'] -> Service<| title == 'quantum-dhcp-agent' |>
        quantum_config {
          'DEFAULT/rabbit_ha_queues': value => 'True';
          'DEFAULT/rabbit_hosts':     value => $rabbit_hosts;
        }
      } else {
        quantum_config {
          'DEFAULT/rabbit_host': value => is_array($rabbit_host) ? { false => $rabbit_host, true => join($rabbit_host) };
          'DEFAULT/rabbit_port': value => $rabbit_port;
        }
      }
      quantum_config {
        'DEFAULT/rpc_backend':            value => $rpc_backend;
        'DEFAULT/rabbit_userid':          value => $rabbit_user;
        'DEFAULT/rabbit_password':        value => $rabbit_password;
        'DEFAULT/rabbit_virtual_host':    value => $rabbit_virtual_host;
      }
    }
    'qpid': {
      if is_array($qpid_host) and size($qpid_host) > 1 {
        $qpid_hosts = inline_template("<%= @qpid_host.map {|x| x + ':' + @qpid_port}.join ',' %>")
        quantum_config {
          'DEFAULT/qpid_hosts':     value => $qpid_hosts;
        }
      } else {
        quantum_config {
          'DEFAULT/qpid_host': value => is_array($qpid_host) ? { false => $qpid_host, true => join($qpid_host) };
          'DEFAULT/qpid_port': value => $qpid_port;
        }
      }
      quantum_config {
        'DEFAULT/rpc_backend':          value => 'quantum.openstack.common.rpc.impl_qpid';
        'DEFAULT/qpid_username':        value => $qpid_user;
        'DEFAULT/qpid_password':        value => $qpid_password;
      }
    }
  }

  if $server_ha_mode {
    $real_bind_host = $bind_host
  } else {
    $real_bind_host = '0.0.0.0'
  }

  quantum_config {
    'DEFAULT/verbose':                value => $verbose;
    'DEFAULT/debug':                  value => $debug;
    'DEFAULT/bind_host':              value => $real_bind_host;
    'DEFAULT/bind_port':              value => $bind_port;
    'DEFAULT/auth_strategy':          value => $auth_strategy;
    'DEFAULT/core_plugin':            value => $core_plugin;
    'DEFAULT/base_mac':               value => $base_mac;
    'DEFAULT/mac_generation_retries': value => $mac_generation_retries;
    'DEFAULT/dhcp_lease_duration':    value => $dhcp_lease_duration;
    'DEFAULT/allow_bulk':             value => $allow_bulk;
    'DEFAULT/allow_overlapping_ips':  value => $allow_overlapping_ips;
    'DEFAULT/control_exchange':       value => $control_exchange;
    'DEFAULT/network_auto_schedule':  value => $network_auto_schedule;
    'DEFAULT/router_auto_schedule':   value => $router_auto_schedule;
    'DEFAULT/agent_down_time':        value => $agent_down_time;
    'keystone_authtoken/auth_host':         value => $auth_host;
    'keystone_authtoken/auth_port':         value => $auth_port;
    'keystone_authtoken/admin_tenant_name': value => $auth_tenant;
    'keystone_authtoken/admin_user':        value => $auth_user;
    'keystone_authtoken/admin_password':    value => $auth_password;
  }
  # logging for agents grabbing from stderr. It's workarround for bug in quantum-logging
  # server givs this parameters from command line
  # FIXME change init.d scripts for q&agents for non HA mode, change daemon launch commands (CENTOS/RHEL):
  # FIXME quantum-server:
  # FIXME	daemon --user quantum --pidfile $pidfile "$exec --config-file $config --config-file /etc/$prog/plugin.ini &>>/var/log/quantum/server.log & echo \$!
  # FIXME quantum-ovs-cleanup:
  # FIXME	daemon --user quantum $exec --config-file /etc/$proj/$proj.conf --config-file $config &>>/var/log/$proj/$plugin.log
  # quantum-ovs/metadata/l3/dhcp/-agents:
  # FIXME	daemon --user quantum --pidfile $pidfile "$exec --config-file /etc/$proj/$proj.conf --config-file $config &>>/var/log/$proj/$plugin.log & echo \$! > $pidfile"

  quantum_config {
      'DEFAULT/log_file':   ensure=> absent;
      'DEFAULT/logfile':    ensure=> absent;
  }
  if $use_syslog and !$debug =~ /(?i)(true|yes)/ {
    quantum_config {
        'DEFAULT/log_dir':    ensure=> absent;
        'DEFAULT/logdir':     ensure=> absent;
        'DEFAULT/log_config':   value => "/etc/quantum/logging.conf";
        'DEFAULT/use_stderr': ensure=> absent;
        'DEFAULT/use_syslog': value=> true;
        'DEFAULT/syslog_log_facility': value=> $syslog_log_facility;
    }
    file { "quantum-logging.conf":
      content => template('quantum/logging.conf.erb'),
      path  => "/etc/quantum/logging.conf",
      owner => "root",
      group => "root",
      mode  => 644,
    }
    file { "quantum-all.log":
      path => "/var/log/quantum-all.log",
    }
  } else {
    quantum_config {
    # logging for agents grabbing from stderr. It's workarround for bug in quantum-logging
      'DEFAULT/use_syslog': ensure=> absent;
      'DEFAULT/syslog_log_facility': ensure=> absent;
      'DEFAULT/log_config': ensure=> absent;
      # FIXME stderr should not be used unless quantum+agents init & OCF scripts would be fixed to redirect its output to stderr!
      #'DEFAULT/use_stderr': value => true;
      'DEFAULT/use_stderr': ensure=> absent;
      'DEFAULT/log_dir': value => $log_dir;
    }
    file { "quantum-logging.conf":
      content => template('quantum/logging.conf-nosyslog.erb'),
      path  => "/etc/quantum/logging.conf",
      owner => "root",
      group => "quantum",
      mode  => 640,
    }
  }
  # We must setup logging before start services under pacemaker
  File['quantum-logging.conf'] -> Service<| title == 'quantum-server' |>
  File['quantum-logging.conf'] -> Anchor<| title == 'quantum-ovs-agent' |>
  File['quantum-logging.conf'] -> Anchor<| title == 'quantum-l3' |>
  File['quantum-logging.conf'] -> Anchor<| title == 'quantum-dhcp-agent' |>
  File <| title=='/etc/quantum' |> -> File <| title=='quantum-logging.conf' |>

  if defined(Anchor['quantum-server-config-done']) {
    $endpoint_quantum_main_configuration = 'quantum-server-config-done'
  } else {
    $endpoint_quantum_main_configuration = 'quantum-init-done'
  }

  # FIXME remove explicit --log-config from init scripts cuz it breaks logging!
  exec {'init-dirty-hack':
    command => "sed -i 's/\-\-log\-config=\$loggingconf//g' /etc/init.d/quantum-*",
    path    => ["/sbin", "/bin", "/usr/sbin", "/usr/bin"],
    refreshonly => true,
  }

  Anchor['quantum-init'] ->
    Package['quantum'] ->
     Exec['init-dirty-hack'] ->
      File['/var/cache/quantum'] ->
        Quantum_config<||> ->
          Quantum_api_config<||> ->
            Anchor[$endpoint_quantum_main_configuration]

  anchor {'quantum-init-done':}
}
