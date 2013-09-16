# Installs & configure the savanna API service

class savanna::dashboard (
  $enabled            = true,
  $settings_py        = '/usr/share/openstack-dashboard/openstack_dashboard/settings.py',
  $local_settings     = '/etc/openstack-dashboard/local_settings',
  $savanna_url_string = "SAVANNA_URL = 'http://localhost:8386/v1.0'"
) {


  include savanna::params

  if $enabled {
    $service_ensure = 'running'
    $line_in_settings_py__ensure = 'present'
    $package_ensure = 'installed'

  } else {
    $service_ensure = 'stopped'
    $line_in_settings_py_ensure = 'absent'
    $package_ensure = 'absent'
  }



  file { "$settings_py":
     alias => "horizon_settings",
     ensure => present,
     notify => Service['httpd'],

  }

  file_line{'savanna'          : path => $settings_py,    line => "HORIZON_CONFIG['dashboards'].append('savanna')", ensure => $line_in_settings_py_ensure, }
  file_line{'savannadashboard' : path => $settings_py,    line => "INSTALLED_APPS.append('savannadashboard')",      ensure => $line_in_settings_py_ensure, }
  file_line{'savannaurl'       : path => $local_settings, line => "${savanna_url_string}",                          ensure => $line_in_settings_py_ensure, notify => Service['httpd'], }

  package { 'savanna_dashboard':
    ensure => $package_ensure,
    name   => $::savanna::params::savanna_dashboard_package_name,
    notify => Service['httpd'],
  }


  service { 'httpd':
    ensure     => running,
    name       => httpd,
    enable     => $enabled,
  }


}
