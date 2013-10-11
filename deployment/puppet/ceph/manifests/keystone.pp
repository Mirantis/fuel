#ceph::keystone will configure keystone with ceph parts
class ceph::keystone (
  $pub_ip    = $::ceph::rgw_pub_ip,
  $adm_ip    = $::ceph::rgw_adm_ip,
  $int_ip    = $::ceph::rgw_int_ip,
  $rgw_port  = $::ceph::rgw_port,
  $use_ssl   = $::ceph::use_ssl,
  $directory = $::ceph::rgw_nss_db_path,
  $httpd_ssl = $::ceph::params::dir_httpd_ssl,
) {
  if ($use_ssl) {
    exec {'copy OpenSSL certificates':
      command => "scp -r ${directory}/* ${::ceph::primary_mon}:${directory} && \
                  ssh ${::ceph::primary_mon} '/etc/init.d/radosgw restart'",
    }
    exec {"generate SSL certificate on ${name}":
      command => "openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${httpd_ssl}apache.key -out ${httpd_ssl}apache.crt -subj '/C=RU/ST=Russia/L=Saratov/O=Mirantis/OU=CA/CN=localhost'",
      returns => [0,1],
    }
  }

  keystone_service {'swift':
    ensure      => present,
    type        => 'object-store',
    description => 'Openstack Object-Store Service',
  }

  keystone_endpoint {'swift':
    ensure       => present,
    region       => 'RegionOne',
    public_url   => "http://${pub_ip}:${rgw_port}/swift/v1",
    admin_url    => "http://${adm_ip}:${rgw_port}/swift/v1",
    internal_url => "http://${int_ip}:${rgw_port}/swift/v1",
  }

  if ! defined(Class['keystone']) {
    service { 'keystone':
      ensure => 'running',
      enable => true,
    }
  }
}
