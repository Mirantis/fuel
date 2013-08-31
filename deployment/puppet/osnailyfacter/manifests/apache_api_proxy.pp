# Proxy realization via apache
class osnailyfacter::apache_api_proxy inherits osnailyfacter::params {

  $apache_site_dir = $osnailyfacter::params::apache_site_dir

  # Allow connection to the apache for ostf tests
  firewall {'007 tinyproxy':
    dport   => [ 8888 ],
    source  => $master_ip,
    proto   => 'tcp',
    action  => 'accept',
    require => Class['openstack::firewall'],
  }

  file { "${apache_site_dir}/api_proxy.conf":
    content => template('osnailyfacter/api_proxy.conf.erb'),
    require => Package['httpd'],
    notify  => Service['httpd'],
  }
}

