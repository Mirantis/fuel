#
# [fuel_logs] remote logging mode for Fuel.
#

class rsyslog::server (
  $enable_tcp                = true,
  $enable_udp                = true,
  $server_dir                = '/srv/log/',
  $custom_config             = undef,
  $fuel_logs                 = true,
  $high_precision_timestamps = false,
  $escapenewline             = false
) inherits rsyslog {

    file { $rsyslog::params::server_conf:
        ensure  => present,
        owner   => root,
        group   => $rsyslog::params::run_group,
        content => $custom_config ? {
            ''      => template("${module_name}/server.conf.erb"),
            default => template($custom_config),
        },
        require => Class['rsyslog::config'],
        notify  => Class['rsyslog::service'],
    }
}
